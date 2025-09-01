/*
  # Additional Features for Leqaa Chat Application

  1. New Tables
    - `room_invitations` - Track room invitations
      - `id` (uuid, primary key)
      - `room_id` (uuid, references rooms)
      - `inviter_id` (uuid, references profiles)
      - `invitee_id` (uuid, references profiles)
      - `status` (text, 'pending'|'accepted'|'declined')
      - `created_at` (timestamptz, default now())
      - `expires_at` (timestamptz)

    - `blocked_users` - User blocking system
      - `id` (uuid, primary key)
      - `blocker_id` (uuid, references profiles)
      - `blocked_id` (uuid, references profiles)
      - `reason` (text, optional)
      - `created_at` (timestamptz, default now())

    - `room_recordings` - Store room recordings
      - `id` (uuid, primary key)
      - `room_id` (uuid, references rooms)
      - `file_url` (text, required)
      - `duration_seconds` (integer)
      - `file_size_bytes` (bigint)
      - `created_at` (timestamptz, default now())

    - `user_preferences` - User settings and preferences
      - `id` (uuid, primary key, references profiles)
      - `theme_mode` (text, 'light'|'dark'|'system')
      - `language` (text, default 'ar')
      - `notifications_enabled` (boolean, default true)
      - `auto_join_audio` (boolean, default true)
      - `auto_join_video` (boolean, default false)
      - `preferred_quality` (text, 'low'|'medium'|'high')
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())

  2. Security
    - Enable RLS on all new tables
    - Add appropriate policies for each table
    - Implement privacy controls

  3. Indexes
    - Add performance indexes for common queries
    - Optimize for real-time operations
*/

-- Create room_invitations table
CREATE TABLE IF NOT EXISTS room_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  inviter_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  invitee_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  message text,
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '7 days'),
  UNIQUE(room_id, invitee_id)
);

-- Create blocked_users table
CREATE TABLE IF NOT EXISTS blocked_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(blocker_id, blocked_id)
);

-- Create room_recordings table
CREATE TABLE IF NOT EXISTS room_recordings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  file_url text NOT NULL,
  file_name text NOT NULL,
  duration_seconds integer DEFAULT 0,
  file_size_bytes bigint DEFAULT 0,
  recording_type text DEFAULT 'full' CHECK (recording_type IN ('full', 'audio_only', 'highlights')),
  is_public boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Create user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
  id uuid PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  theme_mode text DEFAULT 'light' CHECK (theme_mode IN ('light', 'dark', 'system')),
  language text DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  notifications_enabled boolean DEFAULT true,
  auto_join_audio boolean DEFAULT true,
  auto_join_video boolean DEFAULT false,
  preferred_quality text DEFAULT 'medium' CHECK (preferred_quality IN ('low', 'medium', 'high')),
  show_participant_names boolean DEFAULT true,
  enable_background_blur boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE room_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_recordings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Room invitations policies
CREATE POLICY "Users can view their own invitations"
  ON room_invitations
  FOR SELECT
  TO authenticated
  USING (invitee_id = auth.uid() OR inviter_id = auth.uid());

CREATE POLICY "Users can send invitations to rooms they own or moderate"
  ON room_invitations
  FOR INSERT
  TO authenticated
  WITH CHECK (
    inviter_id = auth.uid() AND
    room_id IN (
      SELECT room_id FROM room_participants 
      WHERE user_id = auth.uid() 
      AND role IN ('owner', 'moderator')
      AND is_active = true
    )
  );

CREATE POLICY "Users can update their own invitations"
  ON room_invitations
  FOR UPDATE
  TO authenticated
  USING (invitee_id = auth.uid());

-- Blocked users policies
CREATE POLICY "Users can view their own blocked list"
  ON blocked_users
  FOR SELECT
  TO authenticated
  USING (blocker_id = auth.uid());

CREATE POLICY "Users can block other users"
  ON blocked_users
  FOR INSERT
  TO authenticated
  WITH CHECK (blocker_id = auth.uid() AND blocked_id != auth.uid());

CREATE POLICY "Users can unblock users they blocked"
  ON blocked_users
  FOR DELETE
  TO authenticated
  USING (blocker_id = auth.uid());

-- Room recordings policies
CREATE POLICY "Room owners can view their room recordings"
  ON room_recordings
  FOR SELECT
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms WHERE owner_id = auth.uid()
    ) OR
    is_public = true
  );

CREATE POLICY "Room owners can create recordings"
  ON room_recordings
  FOR INSERT
  TO authenticated
  WITH CHECK (
    room_id IN (
      SELECT id FROM rooms WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Room owners can update their recordings"
  ON room_recordings
  FOR UPDATE
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms WHERE owner_id = auth.uid()
    )
  );

CREATE POLICY "Room owners can delete their recordings"
  ON room_recordings
  FOR DELETE
  TO authenticated
  USING (
    room_id IN (
      SELECT id FROM rooms WHERE owner_id = auth.uid()
    )
  );

-- User preferences policies
CREATE POLICY "Users can view their own preferences"
  ON user_preferences
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Users can insert their own preferences"
  ON user_preferences
  FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update their own preferences"
  ON user_preferences
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid());

-- Functions for invitation management
CREATE OR REPLACE FUNCTION accept_room_invitation(invitation_id uuid)
RETURNS void AS $$
DECLARE
  invitation_record room_invitations%ROWTYPE;
BEGIN
  -- Get invitation details
  SELECT * INTO invitation_record
  FROM room_invitations
  WHERE id = invitation_id
  AND invitee_id = auth.uid()
  AND status = 'pending'
  AND expires_at > now();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid or expired invitation';
  END IF;

  -- Update invitation status
  UPDATE room_invitations
  SET status = 'accepted'
  WHERE id = invitation_id;

  -- Add user to room participants
  INSERT INTO room_participants (room_id, user_id, role, is_active)
  VALUES (invitation_record.room_id, auth.uid(), 'participant', true)
  ON CONFLICT (room_id, user_id) 
  DO UPDATE SET is_active = true, joined_at = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up expired invitations
CREATE OR REPLACE FUNCTION cleanup_expired_invitations()
RETURNS void AS $$
BEGIN
  DELETE FROM room_invitations
  WHERE expires_at < now()
  AND status = 'pending';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get room statistics
CREATE OR REPLACE FUNCTION get_room_stats(room_uuid uuid)
RETURNS json AS $$
DECLARE
  result json;
BEGIN
  SELECT json_build_object(
    'total_participants', COUNT(DISTINCT rp.user_id),
    'active_participants', COUNT(DISTINCT CASE WHEN rp.is_active THEN rp.user_id END),
    'total_messages', COUNT(DISTINCT cm.id),
    'last_activity', MAX(GREATEST(rp.joined_at, cm.created_at))
  ) INTO result
  FROM rooms r
  LEFT JOIN room_participants rp ON r.id = rp.room_id
  LEFT JOIN chat_messages cm ON r.id = cm.room_id
  WHERE r.id = room_uuid
  GROUP BY r.id;

  RETURN COALESCE(result, '{}'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_room_invitations_invitee_id ON room_invitations(invitee_id);
CREATE INDEX IF NOT EXISTS idx_room_invitations_room_id ON room_invitations(room_id);
CREATE INDEX IF NOT EXISTS idx_room_invitations_status ON room_invitations(status);
CREATE INDEX IF NOT EXISTS idx_room_invitations_expires_at ON room_invitations(expires_at);

CREATE INDEX IF NOT EXISTS idx_blocked_users_blocker_id ON blocked_users(blocker_id);
CREATE INDEX IF NOT EXISTS idx_blocked_users_blocked_id ON blocked_users(blocked_id);

CREATE INDEX IF NOT EXISTS idx_room_recordings_room_id ON room_recordings(room_id);
CREATE INDEX IF NOT EXISTS idx_room_recordings_created_at ON room_recordings(created_at);

-- Add updated_at trigger for user_preferences
DROP TRIGGER IF EXISTS update_user_preferences_updated_at ON user_preferences;
CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Add constraint to prevent self-blocking
ALTER TABLE blocked_users ADD CONSTRAINT check_no_self_block 
  CHECK (blocker_id != blocked_id);

-- Add constraint to prevent self-invitation
ALTER TABLE room_invitations ADD CONSTRAINT check_no_self_invite 
  CHECK (inviter_id != invitee_id);