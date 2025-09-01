import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/providers/app_state_provider.dart';
import '../../widgets/custom_button_widget.dart';
import '../../widgets/custom_text_field_widget.dart';
import '../../widgets/custom_snackbar_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AppStateProvider>(context, listen: false).signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل تسجيل الدخول: ${e.toString()}',
              textAlign: TextAlign.right,
            ),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/room-list');
      }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),
                  
                  // App Logo and Title
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(4.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'video_call',
                        size: 10.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  Text(
                    'لقاء شات',
                    style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  Text(
                    'تطبيق المحادثات الصوتية والمرئية',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  // Welcome Message
                  Text(
                    'مرحباً بعودتك',
                    style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  Text(
                    'سجل دخولك للمتابعة',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Email Field
                  CustomTextFieldWidget(
                    controller: _emailController,
                    labelText: 'البريد الإلكتروني',
                    hintText: 'أدخل بريدك الإلكتروني',
                    type: TextFieldType.email,
                    prefixIconName: 'email',
                    isRequired: true,
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Password Field
                  CustomTextFieldWidget(
                    controller: _passwordController,
                    labelText: 'كلمة المرور',
                    hintText: 'أدخل كلمة المرور',
                    type: TextFieldType.password,
                    prefixIconName: 'lock',
                    isRequired: true,
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Remember Me and Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'تذكرني',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: TextStyle(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  // Sign In Button
                  CustomButtonWidget(
                    text: 'تسجيل الدخول',
                    onPressed: _signIn,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    iconName: 'login',
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟ ',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(
                    iconName: 'person_outline',
                    isFullWidth: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'person_outline',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'دخول كضيف',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                          ),
        CustomSnackBarWidget.show(
          context: context,
          message: 'فشل تسجيل الدخول: ${e.toString()}',
          type: SnackBarType.error,
        ),
      ),
    );
  }
}