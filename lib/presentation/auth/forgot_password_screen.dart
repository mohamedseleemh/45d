import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';
import '../../widgets/custom_snackbar_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseService.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );

      setState(() {
        _emailSent = true;
      });

      CustomSnackBarWidget.show(
        context: context,
        message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
        type: SnackBarType.success,
      );
    } catch (e) {
      CustomSnackBarWidget.show(
        context: context,
        message: 'فشل في إرسال رابط إعادة التعيين: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('استعادة كلمة المرور'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4.h),
                  
                  // Icon
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _emailSent ? 'mark_email_read' : 'lock_reset',
                        size: 10.w,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Title
                  Text(
                    _emailSent ? 'تم إرسال الرابط' : 'نسيت كلمة المرور؟',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // Description
                  Text(
                    _emailSent 
                        ? 'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور'
                        : 'أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  if (!_emailSent) ...[
                    // Email Field
                    CustomTextFieldWidget(
                      controller: _emailController,
                      labelText: 'البريد الإلكتروني',
                      hintText: 'أدخل بريدك الإلكتروني',
                      type: TextFieldType.email,
                      prefixIconName: 'email',
                      isRequired: true,
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Reset Button
                    CustomButtonWidget(
                      text: 'إرسال رابط الاستعادة',
                      onPressed: _resetPassword,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      iconName: 'send',
                    ),
                  ] else ...[
                    // Success state
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.successLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.successLight,
                            size: 8.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'تم إرسال الرابط بنجاح',
                            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.successLight,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'تحقق من صندوق الوارد وصندوق الرسائل المزعجة',
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 4.h),
                    
                    // Resend Button
                    CustomButtonWidget(
                      text: 'إعادة الإرسال',
                      type: ButtonType.outline,
                      onPressed: () {
                        setState(() {
                          _emailSent = false;
                        });
                      },
                      isFullWidth: true,
                      iconName: 'refresh',
                    ),
                  ],
                  
                  SizedBox(height: 3.h),
                  
                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تذكرت كلمة المرور؟ ',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}