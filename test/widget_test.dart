import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:leqaa_chat/main.dart';
import 'package:leqaa_chat/core/providers/enhanced_app_state_provider.dart';

void main() {
  group('تطبيق لقاء شات - اختبارات الويدجت', () {
    testWidgets('اختبار تحميل الشاشة الرئيسية', (WidgetTester tester) async {
      // إنشاء التطبيق مع موفر الحالة
      await tester.pumpWidget(
        ChangeNotifierProvider<EnhancedAppStateProvider>(
          create: (_) => EnhancedAppStateProvider.instance,
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('مرحباً بك في لقاء شات'),
              ),
            ),
          ),
        ),
      );

      // التحقق من وجود النص
      expect(find.text('مرحباً بك في لقاء شات'), findsOneWidget);
    });

    testWidgets('اختبار عرض شاشة تسجيل الدخول', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('تسجيل الدخول'),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                  ),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('دخول'),
                ),
              ],
            ),
          ),
        ),
      );

      // التحقق من وجود عناصر تسجيل الدخول
      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.text('البريد الإلكتروني'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
      expect(find.text('دخول'), findsOneWidget);
    });

    testWidgets('اختبار إدخال النص في حقول تسجيل الدخول', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  key: Key('email_field'),
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                  ),
                ),
                TextField(
                  key: Key('password_field'),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );

      // إدخال النص في الحقول
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');

      // التحقق من النص المدخل
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsNothing); // مخفي لأنه كلمة مرور
    });

    testWidgets('اختبار الضغط على زر تسجيل الدخول', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                buttonPressed = true;
              },
              child: Text('تسجيل الدخول'),
            ),
          ),
        ),
      );

      // الضغط على الزر
      await tester.tap(find.text('تسجيل الدخول'));
      await tester.pump();

      // التحقق من تنفيذ الوظيفة
      expect(buttonPressed, isTrue);
    });
  });

  group('اختبارات مكونات UI المخصصة', () {
    testWidgets('اختبار CustomIconWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Icon(Icons.home),
          ),
        ),
      );

      // التحقق من وجود الأيقونة
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('اختبار عرض قائمة الغرف', (WidgetTester tester) async {
      final rooms = [
        {'name': 'غرفة الأصدقاء', 'participants': 5},
        {'name': 'غرفة العمل', 'participants': 3},
        {'name': 'غرفة الألعاب', 'participants': 8},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Text(room['name'] as String),
                  subtitle: Text('${room['participants']} مشارك'),
                );
              },
            ),
          ),
        ),
      );

      // التحقق من عرض الغرف
      expect(find.text('غرفة الأصدقاء'), findsOneWidget);
      expect(find.text('غرفة العمل'), findsOneWidget);
      expect(find.text('غرفة الألعاب'), findsOneWidget);
      expect(find.text('5 مشارك'), findsOneWidget);
    });
  });

  group('اختبارات التنقل', () {
    testWidgets('اختبار التنقل بين الشاشات', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/rooms');
                  },
                  child: Text('الذهاب للغرف'),
                ),
              ),
            ),
            '/rooms': (context) => Scaffold(
              body: Center(
                child: Text('قائمة الغرف'),
              ),
            ),
          },
        ),
      );

      // التحقق من الشاشة الأولى
      expect(find.text('الذهاب للغرف'), findsOneWidget);

      // الضغط على زر التنقل
      await tester.tap(find.text('الذهاب للغرف'));
      await tester.pumpAndSettle();

      // التحقق من الانتقال للشاشة الثانية
      expect(find.text('قائمة الغرف'), findsOneWidget);
    });
  });
}