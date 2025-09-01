# Flutter

# لقاء شات - تطبيق المحادثات الصوتية والمرئية

تطبيق Flutter متقدم للمحادثات الصوتية والمرئية باللغة العربية، مبني بأحدث التقنيات والأدوات لتوفير تجربة تواصل سلسة وآمنة.

## ✨ الميزات الرئيسية

- 🎤 **مكالمات صوتية عالية الجودة** - تقنية WebRTC للاتصال المباشر
- 📹 **مكالمات فيديو HD** - جودة عالية مع تحكم كامل
- 💬 **محادثة نصية فورية** - رسائل فورية مع دعم العربية
- 🏠 **غرف متنوعة** - إنشاء غرف عامة وخاصة وبدعوة
- 🔒 **أمان متقدم** - تشفير البيانات وحماية الخصوصية
- 🌙 **وضع مظلم** - واجهة مريحة للعينين
- 🔔 **إشعارات ذكية** - تنبيهات مخصصة ومرنة
- 📱 **تصميم متجاوب** - يعمل على جميع أحجام الشاشات

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)
- حساب Supabase نشط
- اتصال إنترنت مستقر

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. إعداد متغيرات البيئة:
```bash
cp env.json.example env.json
# قم بتحديث القيم في env.json بمفاتيح Supabase الخاصة بك
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 🏗️ Architecture

يتبع التطبيق معمارية Clean Architecture مع فصل واضح للطبقات:

```
├── Presentation Layer (UI)
├── Domain Layer (Business Logic)
├── Data Layer (Repositories & Data Sources)
└── Core Layer (Utilities & Services)
```

### طبقات التطبيق:

1. **Core Layer** - الخدمات الأساسية والأدوات
2. **Data Layer** - مستودعات البيانات والمصادر
3. **Domain Layer** - منطق الأعمال والنماذج
4. **Presentation Layer** - واجهة المستخدم والتفاعل

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/                    # الوظائف الأساسية
│   │   ├── config/             # تكوين التطبيق
│   │   ├── constants/          # الثوابت
│   │   ├── exceptions/         # الاستثناءات المخصصة
│   │   ├── providers/          # موفري الحالة
│   │   ├── services/           # الخدمات الأساسية
│   │   └── utils/              # الأدوات المساعدة
│   ├── features/               # الميزات الرئيسية
│   │   ├── auth/              # المصادقة
│   │   ├── rooms/             # إدارة الغرف
│   │   ├── chat/              # المحادثة
│   │   └── profile/           # الملف الشخصي
│   ├── shared/                 # المكونات المشتركة
│   │   ├── models/            # النماذج
│   │   ├── widgets/           # الويدجت المشتركة
│   │   └── themes/            # الثيمات
│   ├── presentation/           # شاشات التطبيق
│   │   ├── auth/              # شاشات المصادقة
│   │   ├── room_list/         # قائمة الغرف
│   │   ├── room_interface/    # واجهة الغرفة
│   │   ├── create_room/       # إنشاء غرفة
│   │   ├── room_settings/     # إعدادات الغرفة
│   │   └── splash_screen/     # شاشة البداية
│   ├── widgets/               # الويدجت العامة
│   └── main.dart              # نقطة دخول التطبيق
├── assets/             # Static assets (images, fonts, etc.)
├── test/               # الاختبارات
├── docs/               # التوثيق
├── supabase/           # إعدادات قاعدة البيانات
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🧪 Testing

### تشغيل الاختبارات:

```bash
# اختبارات الوحدة
flutter test test/unit_test.dart

# اختبارات الويدجت
flutter test test/widget_test.dart

# اختبارات التكامل
flutter test integration_test/
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;

// تبديل الثيم
Provider.of<EnhancedAppStateProvider>(context, listen: false).toggleTheme();

// الحصول على الثيم الحالي
bool isDarkMode = Provider.of<EnhancedAppStateProvider>(context).isDarkMode;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```
## 📦 Deployment

### Android
```bash
# بناء APK للإنتاج
flutter build apk --release --dart-define-from-file=env.json

# بناء App Bundle
flutter build appbundle --release --dart-define-from-file=env.json
```

### iOS
```bash
# بناء للإنتاج
flutter build ios --release --dart-define-from-file=env.json
```

## 🔧 Configuration

### متغيرات البيئة المطلوبة:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key",
  "OPENAI_API_KEY": "your-openai-key",
  "GEMINI_API_KEY": "your-gemini-key",
  "ANTHROPIC_API_KEY": "your-anthropic-key",
  "PERPLEXITY_API_KEY": "your-perplexity-key"
}
```

## 📚 Documentation

- [دليل التطوير](docs/DEVELOPMENT_GUIDE.md)
- [توثيق API](docs/API_DOCUMENTATION.md)
- [دليل النشر](docs/DEPLOYMENT_GUIDE.md)

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

## 🤝 Contributing

نرحب بالمساهمات! يرجى قراءة [دليل المساهمة](CONTRIBUTING.md) قبل البدء.

### خطوات المساهمة:
1. Fork المشروع
2. إنشاء branch للميزة الجديدة
3. كتابة الكود مع الاختبارات
4. تشغيل جميع الاختبارات
5. إرسال Pull Request

## 📄 License

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## 🆘 Support

للحصول على الدعم، يرجى فتح issue في GitHub أو التواصل عبر البريد الإلكتروني.

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design

Built with ❤️ on Rocket.new
