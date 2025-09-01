import '../../../core/services/supabase_service.dart';
import '../../../shared/models/room_model.dart';
import '../../../shared/models/room_participant_model.dart';

/// مستودع الغرف - يدير جميع عمليات الغرف والمشاركين
class RoomsRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// جلب جميع الغرف المتاحة
  Future<List<RoomModel>> getRooms({
    String? searchQuery,
    String? roomType,
    String? privacy,
  }) async {
    try {
      var query = _supabaseService.client
          .from('rooms')
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .eq('is_active', true);

      // تطبيق الفلاتر
      if (roomType != null && roomType != 'all') {
        query = query.eq('type', roomType);
      }

      if (privacy != null && privacy != 'all') {
        query = query.eq('privacy', privacy);
      }

      // البحث في اسم الغرفة
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((data) => RoomModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب الغرف: ${e.toString()}');
    }
  }

  /// إنشاء غرفة جديدة
  Future<RoomModel> createRoom({
    required String name,
    required String description,
    required String type,
    required String privacy,
    required int participantLimit,
    String? imageUrl,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      final response = await _supabaseService.client
          .from('rooms')
          .insert({
            'name': name,
            'description': description,
            'type': type,
            'privacy': privacy,
            'participant_limit': participantLimit,
            'owner_id': user.id,
            'image_url': imageUrl,
            'settings': settings ?? {},
            'is_active': true,
          })
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .single();

      final room = RoomModel.fromJson(response);

      // إضافة المالك كمشارك
      await _supabaseService.client.from('room_participants').insert({
        'room_id': room.id,
        'user_id': user.id,
        'role': 'owner',
        'is_active': true,
      });

      return room;
    } catch (e) {
      throw Exception('خطأ في إنشاء الغرفة: ${e.toString()}');
    }
  }

  /// الانضمام لغرفة
  Future<void> joinRoom(String roomId) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      // التحقق من وجود الغرفة وإمكانية الانضمام
      final room = await _supabaseService.client
          .from('rooms')
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .eq('id', roomId)
          .eq('is_active', true)
          .single();

      final roomModel = RoomModel.fromJson(room);

      if (roomModel.isFull) {
        throw Exception('الغرفة ممتلئة');
      }

      // إضافة المستخدم كمشارك
      await _supabaseService.client.from('room_participants').insert({
        'room_id': roomId,
        'user_id': user.id,
        'role': 'participant',
        'is_active': true,
      });
    } catch (e) {
      throw Exception('خطأ في الانضمام للغرفة: ${e.toString()}');
    }
  }

  /// مغادرة الغرفة
  Future<void> leaveRoom(String roomId) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      await _supabaseService.client
          .from('room_participants')
          .update({
            'is_active': false,
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('خطأ في مغادرة الغرفة: ${e.toString()}');
    }
  }

  /// جلب مشاركي الغرفة
  Future<List<RoomParticipantModel>> getRoomParticipants(String roomId) async {
    try {
      final response = await _supabaseService.client
          .from('room_participants')
          .select('*, profiles!room_participants_user_id_fkey(*)')
          .eq('room_id', roomId)
          .eq('is_active', true)
          .order('joined_at', ascending: true);

      return (response as List)
          .map((data) => RoomParticipantModel.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب المشاركين: ${e.toString()}');
    }
  }

  /// تحديث إعدادات الغرفة
  Future<RoomModel> updateRoom({
    required String roomId,
    String? name,
    String? description,
    String? privacy,
    int? participantLimit,
    String? imageUrl,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (privacy != null) updates['privacy'] = privacy;
      if (participantLimit != null) updates['participant_limit'] = participantLimit;
      if (imageUrl != null) updates['image_url'] = imageUrl;
      if (settings != null) updates['settings'] = settings;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('rooms')
          .update(updates)
          .eq('id', roomId)
          .eq('owner_id', user.id)
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .single();

      return RoomModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تحديث الغرفة: ${e.toString()}');
    }
  }

  /// حذف الغرفة
  Future<void> deleteRoom(String roomId) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) throw Exception('المستخدم غير مصادق');

      await _supabaseService.client
          .from('rooms')
          .delete()
          .eq('id', roomId)
          .eq('owner_id', user.id);
    } catch (e) {
      throw Exception('خطأ في حذف الغرفة: ${e.toString()}');
    }
  }

  /// كتم/إلغاء كتم مشارك
  Future<void> toggleParticipantMute({
    required String roomId,
    required String participantId,
    required bool isMuted,
  }) async {
    try {
      await _supabaseService.client
          .from('room_participants')
          .update({'is_muted': isMuted})
          .eq('room_id', roomId)
          .eq('user_id', participantId);
    } catch (e) {
      throw Exception('خطأ في تغيير حالة الكتم: ${e.toString()}');
    }
  }

  /// إزالة مشارك من الغرفة
  Future<void> removeParticipant({
    required String roomId,
    required String participantId,
  }) async {
    try {
      await _supabaseService.client
          .from('room_participants')
          .update({
            'is_active': false,
            'left_at': DateTime.now().toIso8601String(),
          })
          .eq('room_id', roomId)
          .eq('user_id', participantId);
    } catch (e) {
      throw Exception('خطأ في إزالة المشارك: ${e.toString()}');
    }
  }

  /// الاشتراك في تحديثات الغرفة
  RealtimeChannel subscribeToRoom(
    String roomId,
    Function(Map<String, dynamic>) onParticipantUpdate,
  ) {
    return _supabaseService.subscribeToRoom(roomId, onParticipantUpdate);
  }
}