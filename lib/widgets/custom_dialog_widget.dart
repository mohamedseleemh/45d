import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

enum DialogType { info, success, warning, error, confirmation }

class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final DialogType type;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customContent;
  final bool barrierDismissible;

  const CustomDialogWidget({
    Key? key,
    required this.title,
    required this.content,
    this.type = DialogType.info,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customContent,
    this.barrierDismissible = true,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    DialogType type = DialogType.info,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Widget? customContent,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialogWidget(
        title: title,
        content: content,
        type: type,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        customContent: customContent,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  Color _getIconColor() {
    switch (type) {
      case DialogType.success:
        return AppTheme.successLight;
      case DialogType.warning:
        return AppTheme.warningLight;
      case DialogType.error:
        return AppTheme.errorLight;
      case DialogType.confirmation:
        return AppTheme.lightTheme.primaryColor;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getIconName() {
    switch (type) {
      case DialogType.success:
        return 'check_circle';
      case DialogType.warning:
        return 'warning';
      case DialogType.error:
        return 'error';
      case DialogType.confirmation:
        return 'help';
      default:
        return 'info';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.w),
        ),
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: _getIconColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getIconName(),
                    color: _getIconColor(),
                    size: 8.w,
                  ),
                ),
              ),
              
              SizedBox(height: 3.h),
              
              // Title
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 2.h),
              
              // Content
              if (customContent != null)
                customContent!
              else
                Text(
                  content,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              SizedBox(height: 4.h),
              
              // Buttons
              Row(
                children: [
                  if (secondaryButtonText != null) ...[
                    Expanded(
                      child: CustomButtonWidget(
                        text: secondaryButtonText!,
                        type: ButtonType.outline,
                        onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
                        isFullWidth: true,
                      ),
                    ),
                    SizedBox(width: 3.w),
                  ],
                  
                  Expanded(
                    child: CustomButtonWidget(
                      text: primaryButtonText ?? 'موافق',
                      type: type == DialogType.error || type == DialogType.confirmation
                          ? ButtonType.danger
                          : ButtonType.primary,
                      onPressed: onPrimaryPressed ?? () => Navigator.pop(context),
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}