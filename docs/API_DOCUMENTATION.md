# توثيق API - تطبيق لقاء شات

## 📖 نظرة عامة

يستخدم تطبيق لقاء شات Supabase كخدمة خلفية شاملة توفر:
- قاعدة بيانات PostgreSQL
- نظام مصادقة متكامل
- تخزين الملفات
- Real-time subscriptions
- Edge Functions

## 🔐 المصادقة

### تسجيل الدخول
```dart
final response = await supabase.auth.signInWithPassword(
  email: 'user@example.com',
  password: 'password123',
);
```

### إنشاء حساب جديد
```dart
final response = await supabase.auth.signUp(
  email: 'user@example.com',
  password: 'password123',
  data: {'full_name': 'أحمد محمد'},
);
```

### تسجيل الخروج
```dart
await supabase.auth.signOut();
```

## 👤 إدارة الملفات الشخصية

### جلب الملف الشخصي
```dart
final profile = await supabase
    .from('profiles')
    .select()
    .eq('id', userId)
    .single();
```

### تحديث الملف الشخصي
```dart
await supabase
    .from('profiles')
    .update({
      'full_name': 'الاسم الجديد',
      'avatar_url': 'رابط الصورة',
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', userId);
```

## 🏠 إدارة الغرف

### جلب الغرف المتاحة
```dart
final rooms = await supabase
    .from('rooms')
    .select('*, profiles!rooms_owner_id_fkey(*)')
    .eq('is_active', true)
    .eq('privacy', 'public')
    .order('created_at', ascending: false);
```

### إنشاء غرفة جديدة
```dart
final room = await supabase
    .from('rooms')
    .insert({
      'name': 'اسم الغرفة',
      'description': 'وصف الغرفة',
      'type': 'voice', // voice, video, both
      'privacy': 'public', // public, private, invite_only
      'participant_limit': 10,
      'owner_id': currentUserId,
      'settings': {},
    })
    .select()
    .single();
```

### الانضمام للغرفة
```dart
await supabase
    .from('room_participants')
    .insert({
      'room_id': roomId,
      'user_id': currentUserId,
      'role': 'participant',
      'is_active': true,
    });
```

### مغادرة الغرفة
```dart
await supabase
    .from('room_participants')
    .update({
      'is_active': false,
      'left_at': DateTime.now().toIso8601String(),
    })
    .eq('room_id', roomId)
    .eq('user_id', currentUserId);
```

## 💬 إدارة الرسائل

### جلب رسائل الغرفة
```dart
final messages = await supabase
    .from('chat_messages')
    .select('*, profiles!chat_messages_sender_id_fkey(*)')
    .eq('room_id', roomId)
    .eq('is_deleted', false)
    .order('created_at', ascending: false)
    .limit(50);
```

### إرسال رسالة
```dart
final message = await supabase
    .from('chat_messages')
    .insert({
      'room_id': roomId,
      'sender_id': currentUserId,
      'content': 'محتوى الرسالة',
      'message_type': 'text',
    })
    .select('*, profiles!chat_messages_sender_id_fkey(*)')
    .single();
```

### حذف رسالة
```dart
await supabase
    .from('chat_messages')
    .update({'is_deleted': true})
    .eq('id', messageId)
    .eq('sender_id', currentUserId);
```

## 🔔 إدارة الدعوات

### إرسال دعوة للغرفة
```dart
await supabase
    .from('room_invitations')
    .insert({
      'room_id': roomId,
      'inviter_id': currentUserId,
      'invitee_id': targetUserId,
      'message': 'رسالة الدعوة',
      'expires_at': DateTime.now().add(Duration(days: 7)).toIso8601String(),
    });
```

### قبول الدعوة
```dart
await supabase.rpc('accept_room_invitation', params: {
  'invitation_id': invitationId,
});
```

### جلب الدعوات المعلقة
```dart
final invitations = await supabase
    .from('room_invitations')
    .select('*, rooms(*), profiles!room_invitations_inviter_id_fkey(*)')
    .eq('invitee_id', currentUserId)
    .eq('status', 'pending')
    .gt('expires_at', DateTime.now().toIso8601String());
```

## 🚫 إدارة الحظر

### حظر مستخدم
```dart
await supabase
    .from('blocked_users')
    .insert({
      'blocker_id': currentUserId,
      'blocked_id': targetUserId,
      'reason': 'سبب الحظر',
    });
```

### إلغاء حظر مستخدم
```dart
await supabase
    .from('blocked_users')
    .delete()
    .eq('blocker_id', currentUserId)
    .eq('blocked_id', targetUserId);
```

### جلب قائمة المحظورين
```dart
final blockedUsers = await supabase
    .from('blocked_users')
    .select('*, profiles!blocked_users_blocked_id_fkey(*)')
    .eq('blocker_id', currentUserId);
```

## 📊 الإحصائيات والتحليلات

### جلب إحصائيات الغرفة
```dart
final stats = await supabase.rpc('get_room_stats', params: {
  'room_uuid': roomId,
});
```

### جلب إحصائيات المستخدم
```dart
final userStats = await supabase
    .from('room_participants')
    .select('room_id')
    .eq('user_id', userId)
    .eq('is_active', true);

final totalRooms = userStats.length;
```

## 🔄 Real-time Subscriptions

### الاشتراك في رسائل الغرفة
```dart
final subscription = supabase
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
      callback: (payload) {
        // معالجة الرسالة الجديدة
        final newMessage = ChatMessageModel.fromJson(payload.newRecord);
        handleNewMessage(newMessage);
      },
    )
    .subscribe();
```

### الاشتراك في تحديثات المشاركين
```dart
final subscription = supabase
    .channel('room_participants_$roomId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'room_participants',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) {
        // معالجة تغيير المشاركين
        handleParticipantChange(payload);
      },
    )
    .subscribe();
```

## 📁 تخزين الملفات

### رفع صورة الملف الشخصي
```dart
final file = File(imagePath);
final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
    .from('profile-images')
    .upload(fileName, file);

final imageUrl = supabase.storage
    .from('profile-images')
    .getPublicUrl(fileName);
```

### رفع صورة الغرفة
```dart
final fileName = '${roomId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

await supabase.storage
    .from('room-images')
    .upload(fileName, file);
```

## ⚙️ إعدادات المستخدم

### حفظ التفضيلات
```dart
await supabase
    .from('user_preferences')
    .upsert({
      'id': userId,
      'theme_mode': 'dark',
      'language': 'ar',
      'notifications_enabled': true,
      'auto_join_audio': true,
      'preferred_quality': 'high',
    });
```

### جلب التفضيلات
```dart
final preferences = await supabase
    .from('user_preferences')
    .select()
    .eq('id', userId)
    .maybeSingle();
```

## 🔍 البحث والفلترة

### البحث في الغرف
```dart
final rooms = await supabase
    .from('rooms')
    .select('*, profiles!rooms_owner_id_fkey(*)')
    .ilike('name', '%$searchQuery%')
    .eq('is_active', true)
    .order('created_at', ascending: false);
```

### فلترة الغرف حسب النوع
```dart
final voiceRooms = await supabase
    .from('rooms')
    .select('*, profiles!rooms_owner_id_fkey(*)')
    .eq('type', 'voice')
    .eq('is_active', true);
```

## 🛡️ الأمان والخصوصية

### Row Level Security (RLS)

جميع الجداول محمية بـ RLS:

```sql
-- مثال: سياسة الوصول للملفات الشخصية
CREATE POLICY "Users can view all profiles"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);
```

### التحقق من الأذونات

```dart
// التحقق من إذن الكاميرا
final hasPermission = await Permission.camera.isGranted;
if (!hasPermission) {
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    throw PermissionException.cameraPermissionDenied();
  }
}
```

## 📈 مراقبة الأداء

### تسجيل مقاييس الأداء
```dart
AppPerformanceMonitor.instance.startOperation('load_rooms');
// تنفيذ العملية
AppPerformanceMonitor.instance.endOperation('load_rooms');
```

### مراقبة استخدام الذاكرة
```dart
final memoryUsage = await getMemoryUsage();
AppLogger.memoryUsage('room_interface', memoryUsage);
```

## 🐛 معالجة الأخطاء

### أنواع الأخطاء الشائعة

1. **أخطاء الشبكة:**
```dart
try {
  await apiCall();
} on SocketException {
  throw NetworkException.noConnection();
} on TimeoutException {
  throw NetworkException.timeout();
}
```

2. **أخطاء المصادقة:**
```dart
try {
  await signIn();
} on AuthException catch (e) {
  if (e.message.contains('Invalid login credentials')) {
    throw AuthenticationException.invalidCredentials();
  }
}
```

3. **أخطاء الأذونات:**
```dart
final permission = await Permission.microphone.request();
if (permission.isDenied) {
  throw PermissionException.microphonePermissionDenied();
}
```

## 📱 دعم المنصات

### Android
- الحد الأدنى: API 23 (Android 6.0)
- الهدف: API 34 (Android 14)
- الأذونات المطلوبة: CAMERA, RECORD_AUDIO, INTERNET

### iOS
- الحد الأدنى: iOS 11.0
- الهدف: iOS 17.0
- الأذونات المطلوبة: Camera, Microphone, Notifications

### Web
- دعم محدود للميزات الصوتية والمرئية
- يتطلب HTTPS للوصول للكاميرا والميكروفون

---

**ملاحظة:** يتم تحديث هذا التوثيق مع كل إصدار جديد من التطبيق.