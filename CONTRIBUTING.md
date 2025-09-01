# دليل المساهمة - تطبيق لقاء شات

مرحباً بك في مجتمع لقاء شات! نحن نقدر مساهمتك في تطوير هذا التطبيق وجعله أفضل للجميع.

## 🤝 كيفية المساهمة

### 1. الإعداد الأولي

```bash
# استنساخ المشروع
git clone https://github.com/leqaa-chat/mobile-app.git
cd leqaa_chat

# إنشاء branch جديد
git checkout -b feature/new-feature-name

# تثبيت التبعيات
flutter pub get
```

### 2. أنواع المساهمات المرحب بها

#### 🐛 إصلاح الأخطاء
- تحديد وإصلاح الأخطاء الموجودة
- تحسين الأداء
- إصلاح مشاكل واجهة المستخدم

#### ✨ ميزات جديدة
- إضافة وظائف جديدة
- تحسين الميزات الموجودة
- دعم منصات جديدة

#### 📚 التوثيق
- تحسين التوثيق الموجود
- إضافة أمثلة وشروحات
- ترجمة التوثيق

#### 🧪 الاختبارات
- كتابة اختبارات جديدة
- تحسين التغطية
- اختبارات الأداء

### 3. معايير الكود

#### أسلوب الكتابة
```dart
// ✅ صحيح
class UserRepository {
  final SupabaseClient _client;
  
  UserRepository(this._client);
  
  /// جلب بيانات المستخدم
  Future<UserModel> getUser(String id) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.e('فشل في جلب بيانات المستخدم', error: e);
      rethrow;
    }
  }
}

// ❌ خطأ
class userrepository {
  var client;
  
  getuser(id) async {
    var data = await client.from('profiles').select().eq('id', id).single();
    return UserModel.fromJson(data);
  }
}
```

#### التسمية
- **الكلاسات:** `PascalCase` (مثل `UserRepository`)
- **المتغيرات والوظائف:** `camelCase` (مثل `getUserData`)
- **الملفات:** `snake_case` (مثل `user_repository.dart`)
- **الثوابت:** `SCREAMING_SNAKE_CASE` (مثل `MAX_RETRY_ATTEMPTS`)

#### التعليقات
```dart
/// وظيفة لحساب المسافة بين نقطتين
/// 
/// [point1] النقطة الأولى
/// [point2] النقطة الثانية
/// 
/// Returns المسافة بالبكسل
/// 
/// Throws [ArgumentError] إذا كانت النقاط null
double calculateDistance(Point point1, Point point2) {
  if (point1 == null || point2 == null) {
    throw ArgumentError('النقاط لا يمكن أن تكون null');
  }
  
  // تطبيق نظرية فيثاغورس
  return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2));
}
```

### 4. كتابة الاختبارات

#### اختبارات الوحدة
```dart
group('اختبارات UserRepository', () {
  late UserRepository repository;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = UserRepository(mockClient);
  });

  test('يجب إرجاع بيانات المستخدم عند النجاح', () async {
    // Arrange
    final userData = {'id': 'user123', 'name': 'أحمد'};
    when(mockClient.from('profiles')).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.eq('id', 'user123')).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.single()).thenAnswer((_) async => userData);

    // Act
    final result = await repository.getUser('user123');

    // Assert
    expect(result.id, equals('user123'));
    expect(result.name, equals('أحمد'));
  });

  test('يجب رمي استثناء عند فشل الطلب', () async {
    // Arrange
    when(mockClient.from('profiles')).thenThrow(Exception('Network error'));

    // Act & Assert
    expect(
      () => repository.getUser('user123'),
      throwsA(isA<Exception>()),
    );
  });
});
```

#### اختبارات الويدجت
```dart
testWidgets('يجب عرض اسم المستخدم في البطاقة', (WidgetTester tester) async {
  // Arrange
  final user = UserModel(id: '1', name: 'أحمد محمد');

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: UserCard(user: user),
    ),
  );

  // Assert
  expect(find.text('أحمد محمد'), findsOneWidget);
});
```

### 5. عملية المراجعة

#### قائمة التحقق
- [ ] الكود يتبع معايير المشروع
- [ ] جميع الاختبارات تمر بنجاح
- [ ] التوثيق محدث
- [ ] لا توجد تحذيرات في `flutter analyze`
- [ ] الكود منسق بـ `dart format`

#### معايير القبول
1. **الوظيفة:** الكود يعمل كما هو متوقع
2. **الجودة:** كود نظيف وقابل للقراءة
3. **الاختبارات:** تغطية مناسبة للاختبارات
4. **الأداء:** لا يؤثر سلباً على الأداء
5. **الأمان:** لا يحتوي على ثغرات أمنية

### 6. إرشادات Git

#### رسائل Commit
```bash
# ✅ صحيح
git commit -m "feat: إضافة ميزة البحث في الغرف"
git commit -m "fix: إصلاح مشكلة انقطاع الصوت"
git commit -m "docs: تحديث دليل التطوير"

# ❌ خطأ
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes"
```

#### أنواع Commit
- `feat:` ميزة جديدة
- `fix:` إصلاح خطأ
- `docs:` تحديث التوثيق
- `style:` تنسيق الكود
- `refactor:` إعادة هيكلة الكود
- `test:` إضافة اختبارات
- `chore:` مهام صيانة

### 7. الإبلاغ عن الأخطاء

#### قالب تقرير الخطأ
```markdown
## وصف الخطأ
وصف واضح ومختصر للخطأ.

## خطوات إعادة الإنتاج
1. اذهب إلى '...'
2. اضغط على '....'
3. مرر لأسفل إلى '....'
4. شاهد الخطأ

## السلوك المتوقع
وصف واضح لما كان يجب أن يحدث.

## لقطات الشاشة
إذا أمكن، أضف لقطات شاشة لتوضيح المشكلة.

## معلومات البيئة:
- الجهاز: [مثل iPhone 12, Samsung Galaxy S21]
- نظام التشغيل: [مثل iOS 15.0, Android 12]
- إصدار التطبيق: [مثل 1.0.0]
- إصدار Flutter: [مثل 3.29.2]

## سياق إضافي
أي معلومات أخرى حول المشكلة.
```

### 8. طلب ميزة جديدة

#### قالب طلب الميزة
```markdown
## هل طلبك مرتبط بمشكلة؟ يرجى الوصف.
وصف واضح ومختصر للمشكلة. مثال: أشعر بالإحباط عندما [...]

## وصف الحل المطلوب
وصف واضح ومختصر لما تريده أن يحدث.

## وصف البدائل المفكر فيها
وصف واضح ومختصر لأي حلول أو ميزات بديلة فكرت فيها.

## سياق إضافي
أضف أي سياق أو لقطات شاشة أخرى حول طلب الميزة هنا.
```

## 🎯 أولويات التطوير

### عالية الأولوية
- إصلاح الأخطاء الحرجة
- تحسين الأمان
- تحسين الأداء
- إصلاح مشاكل إمكانية الوصول

### متوسطة الأولوية
- ميزات جديدة مطلوبة
- تحسين واجهة المستخدم
- تحسين التوثيق
- إضافة اختبارات

### منخفضة الأولوية
- تحسينات تجميلية
- ميزات تجريبية
- تحسينات الكود
- تحديث التبعيات

## 🏆 التقدير

### المساهمون المميزون
سيتم إدراج المساهمين المميزين في:
- ملف CONTRIBUTORS.md
- شاشة "حول التطبيق"
- الموقع الرسمي

### أنواع المساهمات المقدرة
- 💻 كتابة الكود
- 🐛 إصلاح الأخطاء
- 📖 التوثيق
- 🎨 التصميم
- 🧪 الاختبارات
- 🌍 الترجمة
- 💡 الأفكار والاقتراحات

## 📞 التواصل

### قنوات التواصل
- **GitHub Issues:** للأخطاء وطلبات الميزات
- **GitHub Discussions:** للنقاشات العامة
- **البريد الإلكتروني:** dev@leqaa-chat.com
- **Discord:** [رابط الخادم]

### أوقات الاستجابة
- **الأخطاء الحرجة:** خلال 24 ساعة
- **طلبات الميزات:** خلال أسبوع
- **الأسئلة العامة:** خلال 3 أيام

## 📋 قائمة المهام للمساهمين الجدد

### للمبتدئين
- [ ] إصلاح أخطاء إملائية في التوثيق
- [ ] إضافة تعليقات للكود
- [ ] تحسين رسائل الخطأ
- [ ] إضافة اختبارات بسيطة

### للمتوسطين
- [ ] إضافة ميزات UI جديدة
- [ ] تحسين الأداء
- [ ] إضافة اختبارات متقدمة
- [ ] تحسين معالجة الأخطاء

### للمتقدمين
- [ ] إعادة هيكلة الكود
- [ ] تحسين الأمان
- [ ] إضافة ميزات معقدة
- [ ] تحسين البنية التحتية

## 🎓 موارد التعلم

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### Supabase
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)

### WebRTC
- [WebRTC Documentation](https://webrtc.org/getting-started/)
- [Flutter WebRTC Plugin](https://pub.dev/packages/flutter_webrtc)

## ⚖️ قواعد السلوك

### المبادئ الأساسية
1. **الاحترام:** تعامل مع الجميع باحترام ولطف
2. **التعاون:** ساعد الآخرين وتقبل المساعدة
3. **الشمولية:** رحب بالجميع بغض النظر عن الخلفية
4. **البناء:** قدم نقد بناء ومفيد

### السلوكيات المقبولة
- استخدام لغة ترحيبية وشاملة
- احترام وجهات النظر المختلفة
- تقبل النقد البناء بأناقة
- التركيز على ما هو أفضل للمجتمع

### السلوكيات غير المقبولة
- استخدام لغة أو صور جنسية
- التنمر أو التعليقات المهينة
- المضايقة العامة أو الخاصة
- نشر معلومات خاصة للآخرين

## 🔍 عملية المراجعة

### خطوات المراجعة
1. **الفحص التلقائي:** CI/CD checks
2. **مراجعة الكود:** من قبل المشرفين
3. **اختبار الوظيفة:** التأكد من عمل الميزة
4. **مراجعة التوثيق:** التحقق من التوثيق
5. **الموافقة النهائية:** دمج في المشروع

### معايير القبول
- ✅ جميع الاختبارات تمر
- ✅ لا توجد تحذيرات في التحليل
- ✅ الكود منسق ونظيف
- ✅ التوثيق محدث
- ✅ لا يؤثر سلباً على الأداء

## 🎉 شكر خاص

نشكر جميع المساهمين الذين ساعدوا في تطوير هذا التطبيق:

- **المطورون الأساسيون:** فريق لقاء شات
- **المساهمون في الكود:** [قائمة المساهمين]
- **مختبرو البيتا:** المجتمع العربي للتطوير
- **المترجمون:** فريق الترجمة التطوعي

## 📈 خارطة الطريق

### الأهداف قصيرة المدى (3 أشهر)
- تحسين الأداء والاستقرار
- إضافة ميزات الأمان المتقدمة
- دعم المزيد من اللغات

### الأهداف متوسطة المدى (6 أشهر)
- تطبيق سطح المكتب
- ميزات الذكاء الاصطناعي
- تكامل مع خدمات خارجية

### الأهداف طويلة المدى (سنة)
- منصة شاملة للتواصل
- دعم المؤسسات والشركات
- ميزات الواقع المعزز

---

**شكراً لك على اهتمامك بالمساهمة في لقاء شات! مساهمتك تجعل التطبيق أفضل للجميع.**

للأسئلة أو المساعدة، لا تتردد في التواصل معنا عبر GitHub Issues أو البريد الإلكتروني.