import '../../../core/services/supabase_service.dart';
import '../../../shared/models/chat_message_model.dart';

/// مستودع المحادثة - يدير جميع عمليات الرسائل
class ChatRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// جلب رسائل الغرفة
  Future<List<ChatMessageModel>> getRoomMessages({
    required String roomId,
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      var query = _supabaseService.client
          .from('chat_messages')
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .limit(limit);

      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }

      final response = await query;

      return (response as List)
          .map((data) => ChatMessageModel.fromJson(data))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب الرسائل: ${e.toString()}');
    }
  }

  /// إرسال رسالة نصية
  Future<ChatMessageModel> sendTextMessage({
    required String roomId,
    required String content,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      final response = await _supabaseService.client
          .from('chat_messages')
          .insert({
            'room_id': roomId,
            'sender_id': user.id,
            'content': content,
            'message_type': 'text',
          })
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .single();

      return ChatMessageModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في إرسال الرسالة: ${e.toString()}');
    }
  }

  /// إرسال رسالة نظام
  Future<ChatMessageModel> sendSystemMessage({
    required String roomId,
    required String content,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      final response = await _supabaseService.client
          .from('chat_messages')
          .insert({
            'room_id': roomId,
            'sender_id': user.id,
            'content': content,
            'message_type': 'system',
          })
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .single();

      return ChatMessageModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في إرسال رسالة النظام: ${e.toString()}');
    }
  }

  /// حذف رسالة
  Future<void> deleteMessage(String messageId) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      await _supabaseService.client
          .from('chat_messages')
          .update({'is_deleted': true})
          .eq('id', messageId)
          .eq('sender_id', user.id);
    } catch (e) {
      throw Exception('خطأ في حذف الرسالة: ${e.toString()}');
    }
  }

  /// الاشتراك في رسائل الغرفة الجديدة
  RealtimeChannel subscribeToRoomMessages(
    String roomId,
    Function(ChatMessageModel) onNewMessage,
  ) {
    return _supabaseService.client
        .channel('room_messages_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) async {
            try {
              // جلب الرسالة مع بيانات المرسل
              final messageData = await _supabaseService.client
                  .from('chat_messages')
                  .select('*, profiles!chat_messages_sender_id_fkey(*)')
                  .eq('id', payload.newRecord['id'])
                  .single();

              final message = ChatMessageModel.fromJson(messageData);
              onNewMessage(message);
            } catch (e) {
              // تجاهل الأخطاء في الاشتراك
            }
          },
        )
        .subscribe();
  }

  /// البحث في الرسائل
  Future<List<ChatMessageModel>> searchMessages({
    required String roomId,
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('chat_messages')
          .select('*, profiles!chat_messages_sender_id_fkey(*)')
          .eq('room_id', roomId)
          .eq('is_deleted', false)
          .ilike('content', '%$searchQuery%')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((data) => ChatMessageModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في البحث في الرسائل: ${e.toString()}');
    }
  }

  /// جلب إحصائيات الغرفة
  Future<Map<String, dynamic>> getRoomStats(String roomId) async {
    try {
      final response = await _supabaseService.client
          .rpc('get_room_stats', params: {'room_uuid': roomId});

      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات الغرفة: ${e.toString()}');
    }
  }
}