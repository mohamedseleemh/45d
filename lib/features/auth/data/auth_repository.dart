import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/user_model.dart';

/// مستودع المصادقة - يدير جميع عمليات تسجيل الدخول والخروج
class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// تسجيل دخول المستخدم
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('فشل في تسجيل الدخول');
      }

      // جلب بيانات الملف الشخصي
      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
    }
  }

  /// تسجيل مستخدم جديد
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user == null) {
        throw Exception('فشل في إنشاء الحساب');
      }

      // انتظار إنشاء الملف الشخصي تلقائياً عبر trigger
      await Future.delayed(Duration(seconds: 1));

      // جلب بيانات الملف الشخصي
      final profileData = await _supabaseService.client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profileData);
    } catch (e) {
      throw Exception('خطأ في إنشاء الحساب: ${e.toString()}');
    }
  }

  /// تسجيل خروج المستخدم
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw Exception('خطأ في تسجيل الخروج: ${e.toString()}');
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('خطأ في إعادة تعيين كلمة المرور: ${e.toString()}');
    }
  }

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  /// مراقبة تغييرات حالة المصادقة
  Stream<AuthState> get authStateChanges {
    return _supabaseService.authStateChanges;
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

  /// تحديث حالة الاتصال
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final user = getCurrentUser();
      if (user == null) return;

      await _supabaseService.client
          .from('profiles')
          .update({
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      // تجاهل الأخطاء في تحديث حالة الاتصال
    }
  }
}