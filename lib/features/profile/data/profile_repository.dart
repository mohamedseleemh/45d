import '../../../core/services/supabase_service.dart';
import '../../../shared/models/user_model.dart';

/// مستودع الملف الشخصي - يدير بيانات المستخدم والتفضيلات
class ProfileRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// جلب الملف الشخصي للمستخدم
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في جلب الملف الشخصي: ${e.toString()}');
    }
  }

  /// تحديث الملف الشخصي
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('خطأ في تحديث الملف الشخصي: ${e.toString()}');
    }
  }

  /// جلب تفضيلات المستخدم
  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('user_preferences')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // إنشاء تفضيلات افتراضية
        return await _createDefaultPreferences(userId);
      }

      return response;
    } catch (e) {
      throw Exception('خطأ في جلب التفضيلات: ${e.toString()}');
    }
  }

  /// إنشاء تفضيلات افتراضية
  Future<Map<String, dynamic>> _createDefaultPreferences(String userId) async {
    try {
      final defaultPreferences = {
        'id': userId,
        'theme_mode': 'light',
        'language': 'ar',
        'notifications_enabled': true,
        'auto_join_audio': true,
        'auto_join_video': false,
        'preferred_quality': 'medium',
        'show_participant_names': true,
        'enable_background_blur': false,
      };

      final response = await _supabaseService.client
          .from('user_preferences')
          .insert(defaultPreferences)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('خطأ في إنشاء التفضيلات: ${e.toString()}');
    }
  }

  /// تحديث تفضيلات المستخدم
  Future<Map<String, dynamic>> updateUserPreferences({
    required String userId,
    String? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? autoJoinAudio,
    bool? autoJoinVideo,
    String? preferredQuality,
    bool? showParticipantNames,
    bool? enableBackgroundBlur,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (themeMode != null) updates['theme_mode'] = themeMode;
      if (language != null) updates['language'] = language;
      if (notificationsEnabled != null) updates['notifications_enabled'] = notificationsEnabled;
      if (autoJoinAudio != null) updates['auto_join_audio'] = autoJoinAudio;
      if (autoJoinVideo != null) updates['auto_join_video'] = autoJoinVideo;
      if (preferredQuality != null) updates['preferred_quality'] = preferredQuality;
      if (showParticipantNames != null) updates['show_participant_names'] = showParticipantNames;
      if (enableBackgroundBlur != null) updates['enable_background_blur'] = enableBackgroundBlur;
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from('user_preferences')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('خطأ في تحديث التفضيلات: ${e.toString()}');
    }
  }

  /// جلب الغرف المملوكة للمستخدم
  Future<List<Map<String, dynamic>>> getUserOwnedRooms(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('rooms')
          .select('*, profiles!rooms_owner_id_fkey(*)')
          .eq('owner_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('خطأ في جلب الغرف المملوكة: ${e.toString()}');
    }
  }

  /// جلب الغرف التي شارك فيها المستخدم
  Future<List<Map<String, dynamic>>> getUserParticipatedRooms(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('room_participants')
          .select('*, rooms!room_participants_room_id_fkey(*, profiles!rooms_owner_id_fkey(*))')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('خطأ في جلب الغرف المشارك فيها: ${e.toString()}');
    }
  }

  /// تحديث حالة الاتصال
  Future<void> updateOnlineStatus({
    required String userId,
    required bool isOnline,
  }) async {
    try {
      await _supabaseService.client
          .from('profiles')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      // تجاهل أخطاء تحديث حالة الاتصال
    }
  }
}