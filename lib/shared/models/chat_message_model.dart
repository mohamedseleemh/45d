import 'user_model.dart';

class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String messageType; // 'text', 'system', 'file'
  final bool isDeleted;
  final DateTime createdAt;
  final UserModel? sender;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.isDeleted = false,
    required this.createdAt,
    this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['profiles'] != null 
          ? UserModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? content,
    String? messageType,
    bool? isDeleted,
    DateTime? createdAt,
    UserModel? sender,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }

  /// التحقق من نوع الرسالة
  bool get isSystemMessage => messageType == 'system';
  bool get isFileMessage => messageType == 'file';
  bool get isTextMessage => messageType == 'text';

  /// الحصول على اسم المرسل
  String get senderName {
    return sender?.displayName ?? 'مستخدم مجهول';
  }

  /// الحصول على صورة المرسل
  String? get senderAvatar {
    return sender?.avatarUrl;
  }

  /// الحصول على الأحرف الأولى لاسم المرسل
  String get senderInitials {
    return sender?.initials ?? 'م';
  }

  /// التحقق من كون الرسالة حديثة (أقل من دقيقة)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inMinutes < 1;
  }

  /// الحصول على وقت الرسالة منسق
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// الحصول على تاريخ الرسالة منسق
  String get formattedDate {
    final now = DateTime.now();
    final messageDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (messageDate == today) {
      return 'اليوم';
    } else if (messageDate == yesterday) {
      return 'أمس';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// التحقق من اتجاه النص (عربي أم إنجليزي)
  TextDirection get textDirection {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(content) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// الحصول على معاينة مختصرة للرسالة
  String get preview {
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, content: $content, messageType: $messageType, sender: ${sender?.displayName})';
  }
}