import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

/// طبقة تحميل متقدمة مع أنيميشن وحالات مختلفة
class LoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String? message;
  final Widget? child;
  final Color? backgroundColor;
  final bool canDismiss;

  const LoadingOverlay({
    Key? key,
    required this.isVisible,
    this.message,
    this.child,
    this.backgroundColor,
    this.canDismiss = false,
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    if (widget.isVisible) {
      _showOverlay();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showOverlay() {
    _fadeController.forward();
    _scaleController.forward();
  }

  void _hideOverlay() {
    _fadeController.reverse();
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // المحتوى الأساسي
        if (widget.child != null) widget.child!,
        
        // طبقة التحميل
        if (widget.isVisible)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: widget.backgroundColor ?? 
                      Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildLoadingContent(),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Loading indicator
          _buildLoadingIndicator(),
          
          if (widget.message != null) ...[
            SizedBox(height: 3.h),
            Text(
              widget.message!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          if (widget.canDismiss) ...[
            SizedBox(height: 3.h),
            TextButton(
              onPressed: () {
                _hideOverlay();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 15.w,
      height: 15.w,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          
          // Rotating progress indicator
          Center(
            child: SizedBox(
              width: 12.w,
              height: 12.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),
          ),
          
          // Center icon
          Center(
            child: CustomIconWidget(
              iconName: 'video_call',
              color: AppTheme.lightTheme.primaryColor,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }
}