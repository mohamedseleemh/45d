/*
  # Initial Schema for Leqaa Chat Application

  1. New Tables
    - `profiles` - User profiles with extended information
      - `id` (uuid, primary key, references auth.users)
      - `full_name` (text)
      - `avatar_url` (text, optional)
      - `is_online` (boolean, default false)
      - `last_seen` (timestamptz)
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())

    - `rooms` - Chat rooms for voice/video calls
      - `id` (uuid, primary key)
      - `name` (text, required)
      - `description` (text, optional)
      - `type` (text, 'voice'|'video'|'both')
      - `privacy` (text, 'public'|'private'|'invite_only')
      - `owner_id` (uuid, references profiles)
      - `participant_limit` (integer, default 10)
      - `current_participants` (integer, default 0)
      - `is_active` (boolean, default true)
      - `image_url` (text, optional)
      - `settings` (jsonb, default '{}')
      - `created_at` (timestamptz, default now())
      - `updated_at` (timestamptz, default now())

    - `room_participants` - Track room membership
      - `id` (uuid, primary key)
      - `room_id` (uuid, references rooms)
      - `user_id` (uuid, references profiles)
      - `role` (text, 'owner'|'moderator'|'participant')
      - `is_active` (boolean, default true)
      - `is_muted` (boolean, default false)
      - `joined_at` (timestamptz, default now())
      - `left_at` (timestamptz, optional)

    - `chat_messages` - Text messages in rooms
      - `id` (uuid, primary key)
      - `room_id` (uuid, references rooms)
      - `sender_id` (uuid, references profiles)
      - `content` (text, required)
      - `message_type` (text, 'text'|'system'|'file')
      - `is_deleted` (boolean, default false)
      - `created_at` (timestamptz, default now())

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users
    - Implement proper access controls

  3. Functions and Triggers
    - Auto-update timestamps
    - Manage participant counts
    - Handle user presence
*/

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text,
  avatar_url text,
  is_online boolean DEFAULT false,
  last_seen timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create rooms table
CREATE TABLE IF NOT EXISTS rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  type text NOT NULL CHECK (type IN ('voice', 'video', 'both')),
  privacy text NOT NULL CHECK (privacy IN ('public', 'private', 'invite_only')),
  owner_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  participant_limit integer DEFAULT 10 CHECK (participant_limit > 0 AND participant_limit <= 100),
  current_participants integer DEFAULT 0,
  is_active boolean DEFAULT true,
  image_url text,
  settings jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create room_participants table
CREATE TABLE IF NOT EXISTS room_participants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role text DEFAULT 'participant' CHECK (role IN ('owner', 'moderator', 'participant')),
  is_active boolean DEFAULT true,
  is_muted boolean DEFAULT false,
  joined_at timestamptz DEFAULT now(),
  left_at timestamptz,
  UNIQUE(room_id, user_id)
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content text NOT NULL,
  message_type text DEFAULT 'text' CHECK (message_type IN ('text', 'system', 'file')),
  is_deleted boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view all profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Rooms policies
CREATE POLICY "Anyone can view public rooms"
  ON rooms
  FOR SELECT
  TO authenticated
  USING (privacy = 'public' OR owner_id = auth.uid());

CREATE POLICY "Room owners can update their rooms"
  ON rooms
  FOR UPDATE
  TO authenticated
  USING (owner_id = auth.uid());

CREATE POLICY "Authenticated users can create rooms"
  ON rooms
  FOR INSERT
  TO authenticated
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Room owners can delete their rooms"
  ON rooms
  FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid());

-- Room participants policies
CREATE POLICY "Users can view participants of rooms they're in"
  ON room_participants
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR 
    room_id IN (
      SELECT room_id FROM room_participants 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Users can join rooms"
  ON room_participants
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can leave rooms"
  ON room_participants
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- Chat messages policies
CREATE POLICY "Users can view messages in rooms they're in"
  ON chat_messages
  FOR SELECT
  TO authenticated
  USING (
    room_id IN (
      SELECT room_id FROM room_participants 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Users can send messages to rooms they're in"
  ON chat_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid() AND
    room_id IN (
      SELECT room_id FROM room_participants 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- Functions and Triggers

-- Function to handle user registration
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user registration
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to update room participant count
CREATE OR REPLACE FUNCTION update_room_participant_count()
RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.is_active = true THEN
    UPDATE rooms 
    SET current_participants = current_participants + 1,
        updated_at = now()
    WHERE id = NEW.room_id;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.is_active = true AND NEW.is_active = false THEN
      UPDATE rooms 
      SET current_participants = current_participants - 1,
          updated_at = now()
      WHERE id = NEW.room_id;
    ELSIF OLD.is_active = false AND NEW.is_active = true THEN
      UPDATE rooms 
      SET current_participants = current_participants + 1,
          updated_at = now()
      WHERE id = NEW.room_id;
    END IF;
  ELSIF TG_OP = 'DELETE' AND OLD.is_active = true THEN
    UPDATE rooms 
    SET current_participants = current_participants - 1,
        updated_at = now()
    WHERE id = OLD.room_id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for participant count updates
DROP TRIGGER IF EXISTS on_room_participant_change ON room_participants;
CREATE TRIGGER on_room_participant_change
  AFTER INSERT OR UPDATE OR DELETE ON room_participants
  FOR EACH ROW EXECUTE FUNCTION update_room_participant_count();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at columns
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_rooms_updated_at ON rooms;
CREATE TRIGGER update_rooms_updated_at
  BEFORE UPDATE ON rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_rooms_owner_id ON rooms(owner_id);
CREATE INDEX IF NOT EXISTS idx_rooms_privacy ON rooms(privacy);
CREATE INDEX IF NOT EXISTS idx_rooms_is_active ON rooms(is_active);
CREATE INDEX IF NOT EXISTS idx_room_participants_room_id ON room_participants(room_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_user_id ON room_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_room_participants_active ON room_participants(is_active);
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_profiles_is_online ON profiles(is_online);