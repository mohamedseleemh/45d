import 'user_model.dart';

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

  /// التحقق من الأدوار
  bool get isOwner => role == 'owner';
  bool get isModerator => role == 'moderator';
  bool get isParticipant => role == 'participant';
  bool get hasModeratorRights => isOwner || isModerator;

  /// الحصول على نص الدور بالعربية
  String get roleInArabic {
    switch (role) {
      case 'owner':
        return 'مالك الغرفة';
      case 'moderator':
        return 'مشرف';
      case 'participant':
        return 'مشارك';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على اسم المشارك
  String get participantName {
    return user?.displayName ?? 'مستخدم مجهول';
  }

  /// الحصول على صورة المشارك
  String? get participantAvatar {
    return user?.avatarUrl;
  }

  /// الحصول على الأحرف الأولى لاسم المشارك
  String get participantInitials {
    return user?.initials ?? 'م';
  }

  /// التحقق من كون المشارك متصل
  bool get isOnline {
    return user?.isCurrentlyOnline ?? false;
  }

  /// الحصول على مدة المشاركة
  Duration get participationDuration {
    final endTime = leftAt ?? DateTime.now();
    return endTime.difference(joinedAt);
  }

  /// الحصول على نص مدة المشاركة
  String get participationDurationText {
    final duration = participationDuration;
    
    if (duration.inDays > 0) {
      return '${duration.inDays} يوم';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} ساعة';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} دقيقة';
    } else {
      return 'أقل من دقيقة';
    }
  }

  /// الحصول على حالة المشارك
  String get statusText {
    if (!isActive) return 'غادر الغرفة';
    if (isMuted) return 'مكتوم';
    if (isOnline) return 'متصل';
    return 'غير متصل';
  }

  /// التحقق من إمكانية التحكم في المشارك
  bool canBeControlledBy(RoomParticipantModel controller) {
    // المالك يمكنه التحكم في الجميع
    if (controller.isOwner) return true;
    
    // المشرف يمكنه التحكم في المشاركين العاديين فقط
    if (controller.isModerator && isParticipant) return true;
    
    return false;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomParticipantModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomParticipantModel(id: $id, userId: $userId, role: $role, isActive: $isActive, participantName: $participantName)';
  }
}