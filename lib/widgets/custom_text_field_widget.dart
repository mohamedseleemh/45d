import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

enum TextFieldType { text, email, password, number, multiline }

class CustomTextFieldWidget extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final TextFieldType type;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? prefixIconName;
  final String? suffixIconName;
  final VoidCallback? onSuffixIconTap;
  final bool isRequired;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final TextDirection? textDirection;
  final TextAlign textAlign;

  const CustomTextFieldWidget({
    Key? key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.type = TextFieldType.text,
    this.onChanged,
    this.validator,
    this.controller,
    this.prefixIconName,
    this.suffixIconName,
    this.onSuffixIconTap,
    this.isRequired = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textDirection,
    this.textAlign = TextAlign.right,
  }) : super(key: key);

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  late TextEditingController _controller;
  bool _obscureText = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _obscureText = widget.type == TextFieldType.password;
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.number:
        return TextInputType.number;
      case TextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case TextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return [];
    }
  }

  String? _getDefaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.trim().isEmpty)) {
      return 'هذا الحقل مطلوب';
    }

    switch (widget.type) {
      case TextFieldType.email:
        if (value != null && value.isNotEmpty) {
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'البريد الإلكتروني غير صحيح';
          }
        }
        break;
      case TextFieldType.password:
        if (value != null && value.isNotEmpty && value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        break;
      default:
        break;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          RichText(
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: widget.labelText!),
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AppTheme.errorLight,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
        ],
        
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          keyboardType: _getKeyboardType(),
          inputFormatters: _getInputFormatters(),
          maxLines: widget.type == TextFieldType.password ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection ?? TextDirection.rtl,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: widget.enabled 
                ? AppTheme.lightTheme.colorScheme.onSurface
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintTextDirection: widget.textDirection ?? TextDirection.rtl,
            prefixIcon: widget.prefixIconName != null
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: widget.prefixIconName!,
                      color: _isFocused
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  )
                : null,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.enabled
                ? AppTheme.lightTheme.colorScheme.surface
                : AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorLight,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.errorLight,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: widget.type == TextFieldType.multiline ? 3.h : 2.h,
            ),
            counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          validator: widget.validator ?? _getDefaultValidator,
          onChanged: widget.onChanged,
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.type == TextFieldType.password) {
      return IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: CustomIconWidget(
          iconName: _obscureText ? 'visibility' : 'visibility_off',
          color: _isFocused
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
      );
    }

    if (widget.suffixIconName != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: CustomIconWidget(
          iconName: widget.suffixIconName!,
          color: _isFocused
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 5.w,
        ),
      );
    }

    return null;
  }
}