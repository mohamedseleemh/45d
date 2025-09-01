import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class CustomLoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double? size;

  const CustomLoadingWidget({
    Key? key,
    this.message,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  State<CustomLoadingWidget> createState() => _CustomLoadingWidgetState();
}

class _CustomLoadingWidgetState extends State<CustomLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size ?? 12.w,
                    height: widget.size ?? 12.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color ?? AppTheme.lightTheme.primaryColor,
                          (widget.color ?? AppTheme.lightTheme.primaryColor)
                              .withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(6.w),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? AppTheme.lightTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'video_call',
                        size: 6.w,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          if (widget.message != null) ...[
            SizedBox(height: 3.h),
            Text(
              widget.message!,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: widget.color ?? AppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}