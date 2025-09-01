import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

/// زر عائم متحرك مع أنيميشن متقدم
class AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  final String iconName;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isExtended;
  final bool isVisible;

  const AnimatedFab({
    Key? key,
    required this.onPressed,
    required this.iconName,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.isExtended = false,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rotationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _rotationController.reverse();
  }

  void _onTapCancel() {
    _rotationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: widget.isExtended && widget.label != null
                  ? FloatingActionButton.extended(
                      onPressed: widget.onPressed,
                      backgroundColor: widget.backgroundColor ?? AppTheme.lightTheme.primaryColor,
                      foregroundColor: widget.foregroundColor ?? Colors.white,
                      elevation: 4,
                      highlightElevation: 8,
                      icon: CustomIconWidget(
                        iconName: widget.iconName,
                        color: widget.foregroundColor ?? Colors.white,
                        size: 5.w,
                      ),
                      label: Text(
                        widget.label!,
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: widget.foregroundColor ?? Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    )
                  : FloatingActionButton(
                      onPressed: widget.onPressed,
                      backgroundColor: widget.backgroundColor ?? AppTheme.lightTheme.primaryColor,
                      foregroundColor: widget.foregroundColor ?? Colors.white,
                      elevation: 4,
                      highlightElevation: 8,
                      child: CustomIconWidget(
                        iconName: widget.iconName,
                        color: widget.foregroundColor ?? Colors.white,
                        size: 6.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}