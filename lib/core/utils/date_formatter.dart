import 'package:intl/intl.dart';

class DateFormatter {
  // Arabic month names
  static const List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  // Arabic day names
  static const List<String> _arabicDays = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
  ];

  // Arabic digits
  static const List<String> _arabicDigits = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'
  ];

  // Convert English digits to Arabic
  static String toArabicDigits(String input) {
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(i.toString(), _arabicDigits[i]);
    }
    return result;
  }

  // Format time for chat messages
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${toArabicDigits(difference.inMinutes.toString())} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${toArabicDigits(difference.inHours.toString())} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${toArabicDigits(difference.inDays.toString())} يوم';
    } else {
      return formatDate(dateTime);
    }
  }

  // Format date in Arabic
  static String formatDate(DateTime dateTime) {
    final day = toArabicDigits(dateTime.day.toString());
    final month = _arabicMonths[dateTime.month - 1];
    final year = toArabicDigits(dateTime.year.toString());
    
    return '$day $month $year';
  }

  // Format time in Arabic (24-hour format)
  static String formatTime(DateTime dateTime) {
    final hour = toArabicDigits(dateTime.hour.toString().padLeft(2, '0'));
    final minute = toArabicDigits(dateTime.minute.toString().padLeft(2, '0'));
    
    return '$hour:$minute';
  }

  // Format date and time together
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} - ${formatTime(dateTime)}';
  }

  // Format duration in Arabic
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = toArabicDigits(duration.inDays.toString());
      return '$days يوم';
    } else if (duration.inHours > 0) {
      final hours = toArabicDigits(duration.inHours.toString());
      return '$hours ساعة';
    } else if (duration.inMinutes > 0) {
      final minutes = toArabicDigits(duration.inMinutes.toString());
      return '$minutes دقيقة';
    } else {
      final seconds = toArabicDigits(duration.inSeconds.toString());
      return '$seconds ثانية';
    }
  }

  // Format relative time (e.g., "منذ 5 دقائق")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = toArabicDigits(difference.inMinutes.toString());
      return 'منذ $minutes دقيقة';
    } else if (difference.inHours < 24) {
      final hours = toArabicDigits(difference.inHours.toString());
      return 'منذ $hours ساعة';
    } else if (difference.inDays < 30) {
      final days = toArabicDigits(difference.inDays.toString());
      return 'منذ $days يوم';
    } else if (difference.inDays < 365) {
      final months = toArabicDigits((difference.inDays / 30).floor().toString());
      return 'منذ $months شهر';
    } else {
      final years = toArabicDigits((difference.inDays / 365).floor().toString());
      return 'منذ $years سنة';
    }
  }

  // Format room duration
  static String formatRoomDuration(int minutes) {
    if (minutes == 0) return 'بدون حد زمني';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    String result = '';

    if (hours > 0) {
      final hoursStr = toArabicDigits(hours.toString());
      result += '$hoursStr ساعة';

      if (remainingMinutes > 0) {
        result += ' و ';
      }
    }

    if (remainingMinutes > 0) {
      final minutesStr = toArabicDigits(remainingMinutes.toString());
      result += '$minutesStr دقيقة';
    }

    return result;
  }

  // Format participant count
  static String formatParticipantCount(int current, int max) {
    final currentStr = toArabicDigits(current.toString());
    final maxStr = toArabicDigits(max.toString());
    return '$currentStr/$maxStr مشارك';
  }

  // Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  // Get day name in Arabic
  static String getDayName(DateTime dateTime) {
    return _arabicDays[dateTime.weekday % 7];
  }

  // Format for chat message grouping
  static String formatChatDate(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'اليوم';
    } else if (isYesterday(dateTime)) {
      return 'أمس';
    } else {
      return '${getDayName(dateTime)} ${formatDate(dateTime)}';
    }
  }
}