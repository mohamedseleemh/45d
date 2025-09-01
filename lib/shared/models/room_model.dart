import 'user_model.dart';

class RoomModel {
  final String id;
  final String name;
  final String? description;
  final String type; // 'voice', 'video', 'both'
  final String privacy; // 'public', 'private', 'invite_only'
  final String ownerId;
  final int participantLimit;
  final int currentParticipants;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final Map<String, dynamic> settings;
  final UserModel? owner;

  const RoomModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.privacy,
    required this.ownerId,
    required this.participantLimit,
    this.currentParticipants = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.settings = const {},
    this.owner,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      privacy: json['privacy'] as String,
      ownerId: json['owner_id'] as String,
      participantLimit: json['participant_limit'] as int,
      currentParticipants: json['current_participants'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      imageUrl: json['image_url'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      owner: json['profiles'] != null 
          ? UserModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'privacy': privacy,
      'owner_id': ownerId,
      'participant_limit': participantLimit,
      'current_participants': currentParticipants,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image_url': imageUrl,
      'settings': settings,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? privacy,
    String? ownerId,
    int? participantLimit,
    int? currentParticipants,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    Map<String, dynamic>? settings,
    UserModel? owner,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      privacy: privacy ?? this.privacy,
      ownerId: ownerId ?? this.ownerId,
      participantLimit: participantLimit ?? this.participantLimit,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      settings: settings ?? this.settings,
      owner: owner ?? this.owner,
    );
  }

  /// التحقق من امتلاء الغرفة
  bool get isFull => currentParticipants >= participantLimit;
  
  /// التحقق من نوع الخصوصية
  bool get isPublic => privacy == 'public';
  bool get isPrivate => privacy == 'private';
  bool get isInviteOnly => privacy == 'invite_only';
  
  /// التحقق من نوع الغرفة
  bool get isVoiceOnly => type == 'voice';
  bool get isVideoOnly => type == 'video';
  bool get supportsBoth => type == 'both';

  /// الحصول على نص نوع الغرفة بالعربية
  String get typeInArabic {
    switch (type) {
      case 'voice':
        return 'صوت فقط';
      case 'video':
        return 'فيديو فقط';
      case 'both':
        return 'صوت وفيديو';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على نص الخصوصية بالعربية
  String get privacyInArabic {
    switch (privacy) {
      case 'public':
        return 'عامة';
      case 'private':
        return 'خاصة';
      case 'invite_only':
        return 'بدعوة فقط';
      default:
        return 'غير محدد';
    }
  }

  /// الحصول على نسبة الامتلاء
  double get fillPercentage {
    if (participantLimit == 0) return 0.0;
    return currentParticipants / participantLimit;
  }

  /// الحصول على نص عدد المشاركين
  String get participantCountText {
    return '$currentParticipants/$participantLimit مشارك';
  }

  /// التحقق من إمكانية الانضمام
  bool get canJoin {
    return isActive && !isFull && (isPublic || isPrivate);
  }

  /// الحصول على لون الحالة
  String get statusColor {
    if (!isActive) return 'inactive';
    if (isFull) return 'full';
    if (currentParticipants > participantLimit * 0.8) return 'almost_full';
    return 'available';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'RoomModel(id: $id, name: $name, type: $type, privacy: $privacy, participants: $currentParticipants/$participantLimit)';
  }
}