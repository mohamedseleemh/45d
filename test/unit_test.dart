import 'package:flutter_test/flutter_test.dart';
import 'package:leqaa_chat/core/utils/validators.dart';
import 'package:leqaa_chat/core/utils/date_formatter.dart';
import 'package:leqaa_chat/shared/models/user_model.dart';
import 'package:leqaa_chat/shared/models/room_model.dart';
import 'package:leqaa_chat/shared/models/chat_message_model.dart';

void main() {
  group('اختبارات التحقق من البيانات (Validators)', () {
    test('اختبار تحقق البريد الإلكتروني', () {
      // بريد إلكتروني صحيح
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
      
      // بريد إلكتروني غير صحيح
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('test@'), isNotNull);
      expect(Validators.validateEmail('@example.com'), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('اختبار تحقق كلمة المرور', () {
      // كلمة مرور صحيحة
      expect(Validators.validatePassword('Password123'), isNull);
      expect(Validators.validatePassword('MySecure123'), isNull);
      
      // كلمة مرور غير صحيحة
      expect(Validators.validatePassword('123'), isNotNull); // قصيرة
      expect(Validators.validatePassword('password'), isNotNull); // بدون أرقام وأحرف كبيرة
      expect(Validators.validatePassword('PASSWORD123'), isNotNull); // بدون أحرف صغيرة
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('اختبار تحقق الاسم', () {
      // اسم صحيح
      expect(Validators.validateName('أحمد محمد'), isNull);
      expect(Validators.validateName('Sara Ahmed'), isNull);
      
      // اسم غير صحيح
      expect(Validators.validateName('أ'), isNotNull); // قصير
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName(null), isNotNull);
      expect(Validators.validateName('a' * 51), isNotNull); // طويل
    });

    test('اختبار تحقق اسم الغرفة', () {
      // اسم غرفة صحيح
      expect(Validators.validateRoomName('غرفة الأصدقاء'), isNull);
      expect(Validators.validateRoomName('Tech Discussion'), isNull);
      
      // اسم غرفة غير صحيح
      expect(Validators.validateRoomName('غر'), isNotNull); // قصير
      expect(Validators.validateRoomName(''), isNotNull);
      expect(Validators.validateRoomName(null), isNotNull);
      expect(Validators.validateRoomName('a' * 51), isNotNull); // طويل
    });
  });

  group('اختبارات تنسيق التاريخ (DateFormatter)', () {
    test('اختبار تحويل الأرقام للعربية', () {
      expect(DateFormatter.toArabicDigits('123'), equals('١٢٣'));
      expect(DateFormatter.toArabicDigits('2024'), equals('٢٠٢٤'));
      expect(DateFormatter.toArabicDigits('0'), equals('٠'));
    });

    test('اختبار تنسيق وقت الرسالة', () {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(Duration(minutes: 1));
      final oneHourAgo = now.subtract(Duration(hours: 1));
      final oneDayAgo = now.subtract(Duration(days: 1));

      expect(DateFormatter.formatMessageTime(now), equals('الآن'));
      expect(DateFormatter.formatMessageTime(oneMinuteAgo), contains('دقيقة'));
      expect(DateFormatter.formatMessageTime(oneHourAgo), contains('ساعة'));
      expect(DateFormatter.formatMessageTime(oneDayAgo), contains('يوم'));
    });

    test('اختبار تنسيق التاريخ', () {
      final testDate = DateTime(2024, 3, 15);
      final formatted = DateFormatter.formatDate(testDate);
      
      expect(formatted, contains('١٥')); // اليوم بالأرقام العربية
      expect(formatted, contains('مارس')); // الشهر بالعربية
      expect(formatted, contains('٢٠٢٤')); // السنة بالأرقام العربية
    });

    test('اختبار تنسيق الوقت', () {
      final testTime = DateTime(2024, 1, 1, 14, 30);
      final formatted = DateFormatter.formatTime(testTime);
      
      expect(formatted, equals('١٤:٣٠'));
    });
  });

  group('اختبارات النماذج (Models)', () {
    test('اختبار UserModel', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
        fullName: 'أحمد محمد',
        createdAt: DateTime.now(),
        isOnline: true,
      );

      expect(user.displayName, equals('أحمد محمد'));
      expect(user.initials, equals('أم'));
      expect(user.isCurrentlyOnline, isTrue);
    });

    test('اختبار RoomModel', () {
      final room = RoomModel(
        id: 'room123',
        name: 'غرفة الاختبار',
        type: 'voice',
        privacy: 'public',
        ownerId: 'user123',
        participantLimit: 10,
        currentParticipants: 5,
        createdAt: DateTime.now(),
      );

      expect(room.isPublic, isTrue);
      expect(room.isVoiceOnly, isTrue);
      expect(room.isFull, isFalse);
      expect(room.fillPercentage, equals(0.5));
      expect(room.canJoin, isTrue);
      expect(room.typeInArabic, equals('صوت فقط'));
      expect(room.privacyInArabic, equals('عامة'));
    });

    test('اختبار ChatMessageModel', () {
      final message = ChatMessageModel(
        id: 'msg123',
        roomId: 'room123',
        senderId: 'user123',
        content: 'مرحباً بالجميع',
        createdAt: DateTime.now(),
      );

      expect(message.isTextMessage, isTrue);
      expect(message.isSystemMessage, isFalse);
      expect(message.textDirection, equals(TextDirection.rtl));
      expect(message.preview, equals('مرحباً بالجميع'));
    });

    test('اختبار تحويل النماذج إلى JSON', () {
      final user = UserModel(
        id: 'user123',
        email: 'test@example.com',
        fullName: 'أحمد محمد',
        createdAt: DateTime.now(),
      );

      final json = user.toJson();
      final userFromJson = UserModel.fromJson(json);

      expect(userFromJson.id, equals(user.id));
      expect(userFromJson.email, equals(user.email));
      expect(userFromJson.fullName, equals(user.fullName));
    });
  });

  group('اختبارات منطق الأعمال', () {
    test('اختبار حساب نسبة امتلاء الغرفة', () {
      final room = RoomModel(
        id: 'room123',
        name: 'غرفة الاختبار',
        type: 'voice',
        privacy: 'public',
        ownerId: 'user123',
        participantLimit: 10,
        currentParticipants: 7,
        createdAt: DateTime.now(),
      );

      expect(room.fillPercentage, equals(0.7));
      expect(room.isFull, isFalse);
      
      // اختبار غرفة ممتلئة
      final fullRoom = room.copyWith(currentParticipants: 10);
      expect(fullRoom.isFull, isTrue);
      expect(fullRoom.canJoin, isFalse);
    });

    test('اختبار حالة المستخدم المتصل', () {
      final now = DateTime.now();
      
      // مستخدم متصل حالياً
      final onlineUser = UserModel(
        id: 'user123',
        email: 'test@example.com',
        createdAt: now,
        isOnline: true,
        lastSeen: now.subtract(Duration(minutes: 2)),
      );
      
      expect(onlineUser.isCurrentlyOnline, isTrue);
      expect(onlineUser.onlineStatusText, equals('متصل الآن'));
      
      // مستخدم غير متصل
      final offlineUser = onlineUser.copyWith(
        isOnline: false,
        lastSeen: now.subtract(Duration(hours: 2)),
      );
      
      expect(offlineUser.isCurrentlyOnline, isFalse);
      expect(offlineUser.onlineStatusText, contains('ساعة'));
    });

    test('اختبار اتجاه النص في الرسائل', () {
      // رسالة عربية
      final arabicMessage = ChatMessageModel(
        id: 'msg1',
        roomId: 'room123',
        senderId: 'user123',
        content: 'مرحباً بكم في الغرفة',
        createdAt: DateTime.now(),
      );
      
      expect(arabicMessage.textDirection, equals(TextDirection.rtl));
      
      // رسالة إنجليزية
      final englishMessage = arabicMessage.copyWith(
        content: 'Hello everyone',
      );
      
      expect(englishMessage.textDirection, equals(TextDirection.ltr));
    });
  });

  group('اختبارات الأداء', () {
    test('اختبار أداء تحويل النماذج', () {
      final stopwatch = Stopwatch()..start();
      
      // إنشاء 1000 مستخدم وتحويلهم لـ JSON
      for (int i = 0; i < 1000; i++) {
        final user = UserModel(
          id: 'user$i',
          email: 'user$i@example.com',
          fullName: 'مستخدم $i',
          createdAt: DateTime.now(),
        );
        
        final json = user.toJson();
        UserModel.fromJson(json);
      }
      
      stopwatch.stop();
      
      // يجب أن يكون التحويل سريع (أقل من ثانية واحدة)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('اختبار أداء البحث في الرسائل', () {
      // إنشاء قائمة كبيرة من الرسائل
      final messages = List.generate(1000, (index) => ChatMessageModel(
        id: 'msg$index',
        roomId: 'room123',
        senderId: 'user$index',
        content: 'رسالة رقم $index',
        createdAt: DateTime.now().subtract(Duration(minutes: index)),
      ));

      final stopwatch = Stopwatch()..start();
      
      // البحث في الرسائل
      final searchResults = messages.where((msg) => 
        msg.content.contains('500')
      ).toList();
      
      stopwatch.stop();
      
      expect(searchResults.length, equals(1));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}