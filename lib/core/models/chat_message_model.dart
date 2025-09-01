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

  bool get isSystemMessage => messageType == 'system';
  bool get isFileMessage => messageType == 'file';
  bool get isTextMessage => messageType == 'text';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, content: $content, messageType: $messageType)';
  }
}