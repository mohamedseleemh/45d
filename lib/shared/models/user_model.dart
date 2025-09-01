class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isOnline;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.lastSeen,
    this.isOnline = false,
    this.metadata,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'] as String)
          : null,
      isOnline: json['is_online'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'last_seen': lastSeen?.toIso8601String(),
      'is_online': isOnline,
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastSeen,
    bool? isOnline,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      metadata: metadata ?? this.metadata,
    );
  }

  /// الحصول على الاسم المعروض
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return email.split('@').first;
  }

  /// الحصول على الأحرف الأولى للاسم
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// التحقق من كون المستخدم متصل حالياً
  bool get isCurrentlyOnline {
    if (!isOnline) return false;
    if (lastSeen == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    // اعتبار المستخدم متصل إذا كان آخر ظهور خلال 5 دقائق
    return difference.inMinutes <= 5;
  }

  /// الحصول على نص حالة الاتصال
  String get onlineStatusText {
    if (isCurrentlyOnline) {
      return 'متصل الآن';
    } else if (lastSeen != null) {
      final now = DateTime.now();
      final difference = now.difference(lastSeen!);
      
      if (difference.inMinutes < 60) {
        return 'آخر ظهور منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'آخر ظهور منذ ${difference.inHours} ساعة';
      } else {
        return 'آخر ظهور منذ ${difference.inDays} يوم';
      }
    }
    return 'غير متصل';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, isOnline: $isOnline)';
  }
}