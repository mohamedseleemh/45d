class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حروف كبيرة وصغيرة وأرقام';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != originalPassword) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    
    if (value.trim().length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }
    
    return null;
  }

  // Room name validation
  static String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الغرفة مطلوب';
    }
    
    if (value.trim().length < 3) {
      return 'اسم الغرفة يجب أن يكون 3 أحرف على الأقل';
    }
    
    if (value.trim().length > 50) {
      return 'اسم الغرفة يجب أن يكون أقل من 50 حرف';
    }
    
    return null;
  }

  // Phone number validation (optional)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صحيح';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    
    if (value.trim().length < minLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $minLength أحرف على الأقل';
    }
    
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون أقل من $maxLength حرف';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    
    if (int.tryParse(value.trim()) == null) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون رقم صحيح';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'الرابط'} غير صحيح';
    }
    
    return null;
  }

  // Combine multiple validators
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}