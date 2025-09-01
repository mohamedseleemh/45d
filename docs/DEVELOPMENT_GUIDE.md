# دليل التطوير - تطبيق لقاء شات

## 📋 جدول المحتويات
1. [إعداد بيئة التطوير](#إعداد-بيئة-التطوير)
2. [هيكل المشروع](#هيكل-المشروع)
3. [أفضل الممارسات](#أفضل-الممارسات)
4. [إرشادات الكود](#إرشادات-الكود)
5. [الاختبارات](#الاختبارات)
6. [النشر](#النشر)

## 🛠️ إعداد بيئة التطوير

### المتطلبات الأساسية
- Flutter SDK (^3.29.2)
- Dart SDK (^3.6.0)
- Android Studio / VS Code
- Git

### خطوات الإعداد

1. **استنساخ المشروع:**
```bash
git clone <repository-url>
cd leqaa_chat
```

2. **تثبيت التبعيات:**
```bash
flutter pub get
```

3. **إعداد متغيرات البيئة:**
```bash
cp env.json.example env.json
# قم بتحديث القيم في env.json
```

4. **تشغيل التطبيق:**
```bash
flutter run --dart-define-from-file=env.json
```

## 🏗️ هيكل المشروع

```
lib/
├── main.dart                 # نقطة دخول التطبيق
├── core/                     # الوظائف الأساسية
│   ├── config/              # تكوين التطبيق
│   ├── constants/           # الثوابت
│   ├── exceptions/          # الاستثناءات المخصصة
│   ├── providers/           # موفري الحالة
│   ├── services/            # الخدمات الأساسية
│   └── utils/               # الأدوات المساعدة
├── features/                # الميزات الرئيسية
│   ├── auth/               # المصادقة
│   ├── rooms/              # إدارة الغرف
│   ├── chat/               # المحادثة
│   └── profile/            # الملف الشخصي
├── shared/                  # المكونات المشتركة
│   ├── models/             # النماذج
│   ├── widgets/            # الويدجت المشتركة
│   └── themes/             # الثيمات
├── presentation/            # شاشات التطبيق
│   ├── auth/               # شاشات المصادقة
│   ├── room_list/          # قائمة الغرف
│   ├── room_interface/     # واجهة الغرفة
│   ├── create_room/        # إنشاء غرفة
│   └── room_settings/      # إعدادات الغرفة
└── widgets/                # الويدجت العامة
```

## 📝 أفضل الممارسات

### 1. إدارة الحالة
- استخدم `Provider` لإدارة الحالة العامة
- فصل منطق الأعمال عن واجهة المستخدم
- استخدم `ChangeNotifier` للحالات البسيطة

```dart
class MyProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### 2. معالجة الأخطاء
- استخدم الاستثناءات المخصصة
- قدم رسائل خطأ واضحة بالعربية
- سجل الأخطاء للتحليل

```dart
try {
  await someOperation();
} on NetworkException catch (e) {
  showErrorMessage(e.message);
} catch (e) {
  AppLogger.e('خطأ غير متوقع', error: e);
  showErrorMessage('حدث خطأ غير متوقع');
}
```

### 3. الأمان
- شفّر البيانات الحساسة
- تحقق من صحة المدخلات
- استخدم HTTPS دائماً

### 4. الأداء
- استخدم `const` constructors عند الإمكان
- تجنب إعادة البناء غير الضرورية
- استخدم `ListView.builder` للقوائم الطويلة

## 🎨 إرشادات الكود

### تسمية الملفات والمجلدات
- استخدم `snake_case` للملفات والمجلدات
- استخدم `PascalCase` للكلاسات
- استخدم `camelCase` للمتغيرات والوظائف

### التعليقات
- اكتب التعليقات بالعربية
- وضح الغرض من الكود المعقد
- استخدم التوثيق للوظائف العامة

```dart
/// وظيفة لحساب المسافة بين نقطتين
/// 
/// [point1] النقطة الأولى
/// [point2] النقطة الثانية
/// 
/// Returns المسافة بالبكسل
double calculateDistance(Point point1, Point point2) {
  // تطبيق نظرية فيثاغورس
  return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2));
}
```

### إدارة الاستيراد
- رتب الاستيراد حسب النوع
- استخدم الاستيراد النسبي للملفات المحلية

```dart
// مكتبات Dart
import 'dart:async';
import 'dart:convert';

// مكتبات Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// مكتبات خارجية
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ملفات المشروع
import '../core/app_export.dart';
import '../widgets/custom_button.dart';
```

## 🧪 الاختبارات

### أنواع الاختبارات

1. **اختبارات الوحدة (Unit Tests):**
```bash
flutter test test/unit_test.dart
```

2. **اختبارات الويدجت (Widget Tests):**
```bash
flutter test test/widget_test.dart
```

3. **اختبارات التكامل (Integration Tests):**
```bash
flutter test integration_test/
```

### كتابة الاختبارات

```dart
group('اختبارات UserModel', () {
  test('يجب إنشاء مستخدم صحيح', () {
    final user = UserModel(
      id: 'test123',
      email: 'test@example.com',
      fullName: 'أحمد محمد',
      createdAt: DateTime.now(),
    );
    
    expect(user.displayName, equals('أحمد محمد'));
    expect(user.initials, equals('أم'));
  });
});
```

## 🚀 النشر

### إعداد النشر

1. **Android:**
```bash
flutter build apk --release --dart-define-from-file=env.json
```

2. **iOS:**
```bash
flutter build ios --release --dart-define-from-file=env.json
```

### قائمة التحقق قبل النشر
- [ ] تشغيل جميع الاختبارات
- [ ] فحص الكود بـ `flutter analyze`
- [ ] تحديث رقم الإصدار
- [ ] اختبار على أجهزة مختلفة
- [ ] التحقق من الأذونات
- [ ] مراجعة الأمان

## 🔧 أدوات التطوير

### أوامر مفيدة

```bash
# فحص الكود
flutter analyze

# تنسيق الكود
dart format .

# تشغيل الاختبارات
flutter test

# بناء التطبيق للإنتاج
flutter build apk --release

# تنظيف المشروع
flutter clean
```

### إعدادات VS Code

```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "dart.lineLength": 80,
  "editor.rulers": [80],
  "editor.formatOnSave": true,
  "dart.previewFlutterUiGuides": true
}
```

## 📚 مصادر إضافية

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Material Design Guidelines](https://material.io/design)

## 🤝 المساهمة

### خطوات المساهمة
1. Fork المشروع
2. إنشاء branch جديد للميزة
3. كتابة الكود مع الاختبارات
4. تشغيل جميع الاختبارات
5. إرسال Pull Request

### معايير المراجعة
- جودة الكود وقابليته للقراءة
- وجود اختبارات شاملة
- التوثيق المناسب
- اتباع إرشادات المشروع

---

**ملاحظة:** هذا الدليل يتطور مع المشروع. يرجى تحديثه عند إضافة ميزات جديدة.