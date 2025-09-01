import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

enum ButtonType { primary, secondary, outline, text, danger }
enum ButtonSize { small, medium, large }

class CustomButtonWidget extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final String? iconName;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;
  final EdgeInsetsGeometry? padding;

  const CustomButtonWidget({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.iconName,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
    this.padding,
  }) : super(key: key);

  @override
  State<CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<CustomButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  Color _getBackgroundColor() {
    if (widget.customColor != null) return widget.customColor!;
    
    switch (widget.type) {
      case ButtonType.primary:
        return AppTheme.lightTheme.primaryColor;
      case ButtonType.secondary:
        return AppTheme.lightTheme.colorScheme.secondary;
      case ButtonType.danger:
        return AppTheme.errorLight;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
        return Colors.white;
      case ButtonType.outline:
        return widget.customColor ?? AppTheme.lightTheme.primaryColor;
      case ButtonType.text:
        return widget.customColor ?? AppTheme.lightTheme.primaryColor;
    }
  }

  BorderSide? _getBorderSide() {
    switch (widget.type) {
      case ButtonType.outline:
        return BorderSide(
          color: widget.customColor ?? AppTheme.lightTheme.primaryColor,
          width: 1.5,
        );
      default:
        return null;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;
    
    switch (widget.size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 12.sp;
      case ButtonSize.medium:
        return 14.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 4.w;
      case ButtonSize.medium:
        return 5.w;
      case ButtonSize.large:
        return 6.w;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getBackgroundColor(),
                  foregroundColor: _getTextColor(),
                  elevation: widget.type == ButtonType.text ? 0 : 2,
                  padding: _getPadding(),
                  side: _getBorderSide(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppTheme.lightTheme.colorScheme
                      .onSurfaceVariant.withValues(alpha: 0.3),
                  disabledForegroundColor: AppTheme.lightTheme.colorScheme
                      .onSurfaceVariant.withValues(alpha: 0.6),
                ),
                child: widget.isLoading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _getIconSize(),
                            height: _getIconSize(),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getTextColor(),
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'جاري التحميل...',
                            style: TextStyle(
                              fontSize: _getFontSize(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: widget.isFullWidth 
                            ? MainAxisSize.max 
                            : MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.iconName != null) ...[
                            CustomIconWidget(
                              iconName: widget.iconName!,
                              size: _getIconSize(),
                              color: _getTextColor(),
                            ),
                            SizedBox(width: 2.w),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: _getFontSize(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}