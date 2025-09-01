# دليل النشر - تطبيق لقاء شات

## 🚀 نظرة عامة

هذا الدليل يوضح خطوات نشر تطبيق لقاء شات على المنصات المختلفة.

## 📋 متطلبات ما قبل النشر

### 1. إعداد البيئة
- [ ] Flutter SDK (^3.29.2)
- [ ] Android Studio / Xcode
- [ ] حساب Supabase مُعد
- [ ] مفاتيح API للخدمات الخارجية

### 2. إعداد المتغيرات
```bash
# إنشاء ملف env.json للإنتاج
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-production-anon-key",
  "OPENAI_API_KEY": "your-openai-key",
  "GEMINI_API_KEY": "your-gemini-key",
  "ANTHROPIC_API_KEY": "your-anthropic-key",
  "PERPLEXITY_API_KEY": "your-perplexity-key"
}
```

### 3. فحص الجودة
```bash
# فحص الكود
flutter analyze

# تشغيل الاختبارات
flutter test

# فحص الأمان
flutter pub deps
```

## 📱 نشر Android

### 1. إعداد التوقيع

إنشاء مفتاح التوقيع:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

إعداد ملف `android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### 2. تحديث إعدادات البناء

في `android/app/build.gradle`:
```gradle
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.leqaa_chat.app"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. بناء APK للإنتاج
```bash
flutter build apk --release --dart-define-from-file=env.json --obfuscate --split-debug-info=build/debug-info
```

### 4. بناء App Bundle
```bash
flutter build appbundle --release --dart-define-from-file=env.json --obfuscate --split-debug-info=build/debug-info
```

### 5. النشر على Google Play

1. **إنشاء حساب Google Play Developer**
2. **رفع App Bundle**
3. **ملء معلومات التطبيق:**
   - الاسم: لقاء شات
   - الوصف: تطبيق المحادثات الصوتية والمرئية
   - الفئة: التواصل
   - التقييم: للجميع

4. **إعداد الأذونات:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## 🍎 نشر iOS

### 1. إعداد Xcode

1. **فتح المشروع في Xcode:**
```bash
open ios/Runner.xcworkspace
```

2. **تحديث Bundle Identifier:**
   - `com.leqaa_chat.app`

3. **إعداد Team والشهادات**

### 2. إعداد الأذونات

في `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق للكاميرا لإجراء مكالمات الفيديو</string>

<key>NSMicrophoneUsageDescription</key>
<string>يحتاج التطبيق للميكروفون لإجراء المكالمات الصوتية</string>

<key>NSLocalNetworkUsageDescription</key>
<string>يحتاج التطبيق للشبكة المحلية لتحسين جودة الاتصال</string>
```

### 3. بناء التطبيق
```bash
flutter build ios --release --dart-define-from-file=env.json --obfuscate --split-debug-info=build/debug-info
```

### 4. النشر على App Store

1. **Archive في Xcode**
2. **رفع للـ App Store Connect**
3. **ملء معلومات التطبيق**
4. **إرسال للمراجعة**

## 🌐 نشر Web (اختياري)

### 1. بناء النسخة الويب
```bash
flutter build web --release --dart-define-from-file=env.json
```

### 2. النشر على Firebase Hosting
```bash
# تثبيت Firebase CLI
npm install -g firebase-tools

# تسجيل الدخول
firebase login

# تهيئة المشروع
firebase init hosting

# النشر
firebase deploy
```

## 🔧 إعداد CI/CD

### GitHub Actions

إنشاء `.github/workflows/deploy.yml`:
```yaml
name: Deploy Flutter App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.2'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: android-apk
        path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter build ios --release --no-codesign
```

## 📊 مراقبة ما بعد النشر

### 1. إعداد Crashlytics
```dart
// في main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kReleaseMode) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  
  runApp(MyApp());
}
```

### 2. مراقبة الأداء
```dart
// تسجيل مقاييس الأداء
FirebasePerformance.instance.newTrace('room_loading')
  ..start()
  ..stop();
```

### 3. تحليل الاستخدام
```dart
// تسجيل الأحداث المهمة
FirebaseAnalytics.instance.logEvent(
  name: 'room_created',
  parameters: {
    'room_type': roomType,
    'participant_count': participantCount,
  },
);
```

## 🔄 تحديث التطبيق

### 1. إعداد التحديث التلقائي

```dart
class UpdateService {
  static Future<void> checkForUpdates() async {
    // فحص الإصدار الحالي مقابل الخادم
    final currentVersion = AppConfig.appVersion;
    final latestVersion = await getLatestVersion();
    
    if (isUpdateAvailable(currentVersion, latestVersion)) {
      showUpdateDialog();
    }
  }
}
```

### 2. إشعار المستخدمين
```dart
void showUpdateDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('تحديث متاح'),
      content: Text('يتوفر إصدار جديد من التطبيق مع ميزات محسنة'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('لاحقاً'),
        ),
        ElevatedButton(
          onPressed: () => launchAppStore(),
          child: Text('تحديث الآن'),
        ),
      ],
    ),
  );
}
```

## 🔒 أمان الإنتاج

### 1. تشفير البيانات الحساسة
```dart
// تشفير كلمات المرور قبل الحفظ
final encryptedPassword = SecurityHelper.instance.encryptText(
  password, 
  userSecretKey
);
```

### 2. إخفاء المفاتيح الحساسة
```dart
// استخدام متغيرات البيئة
const apiKey = String.fromEnvironment('API_KEY');
```

### 3. تفعيل ProGuard (Android)
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## 📋 قائمة التحقق النهائية

### قبل النشر:
- [ ] اختبار على أجهزة مختلفة
- [ ] فحص الأداء والذاكرة
- [ ] التحقق من الأذونات
- [ ] اختبار الاتصال المنقطع
- [ ] مراجعة الأمان
- [ ] تحديث التوثيق
- [ ] إنشاء Release Notes

### بعد النشر:
- [ ] مراقبة الأخطاء
- [ ] تتبع مقاييس الأداء
- [ ] مراجعة تعليقات المستخدمين
- [ ] تحديث قاعدة البيانات إذا لزم
- [ ] إعداد النسخ الاحتياطية

## 🆘 استكشاف الأخطاء

### مشاكل شائعة:

1. **خطأ في البناء:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

2. **مشاكل الأذونات:**
```bash
# التحقق من الأذونات في AndroidManifest.xml
# التحقق من Info.plist في iOS
```

3. **مشاكل الشبكة:**
```bash
# التحقق من إعدادات الشبكة
# فحص شهادات SSL
```

---

**للدعم:** راجع الوثائق أو تواصل مع فريق التطوير.