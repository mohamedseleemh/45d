class RoomParticipantModel {
  final String id;
  final String roomId;
  final String userId;
  final String role; // 'owner', 'moderator', 'participant'
  final bool isActive;
  final bool isMuted;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final UserModel? user;

  const RoomParticipantModel({
    required this.id,
    required this.roomId,
    required this.userId,
    this.role = 'participant',
    this.isActive = true,
    this.isMuted = false,
    required this.joinedAt,
    this.leftAt,
    this.user,
  });

  factory RoomParticipantModel.fromJson(Map<String, dynamic> json) {
    return RoomParticipantModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'participant',
      isActive: json['is_active'] as bool? ?? true,
      isMuted: json['is_muted'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      leftAt: json['left_at'] != null 
          ? DateTime.parse(json['left_at'] as String)
          : null,
      user: json['profiles'] != null 
          ? UserModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'role': role,
      'is_active': isActive,
      'is_muted': isMuted,
      'joined_at': joinedAt.toIso8601String(),
      'left_at': leftAt?.toIso8601String(),
    };
  }

  RoomParticipantModel copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? role,
    bool? isActive,
    bool? isMuted,
    DateTime? joinedAt,
    DateTime? leftAt,
    UserModel? user,
  }) {
    return RoomParticipantModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isMuted: isMuted ?? this.isMuted,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      user: user ?? this.user,
    );
  }

  bool get isOwner => role == 'owner';
  bool get isModerator => role == 'moderator';
  bool get isParticipant => role == 'participant';
  bool get hasModeratorRights => isOwner || isModerator;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomParticipantModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomParticipantModel(id: $id, userId: $userId, role: $role, isActive: $isActive)';
  }
}