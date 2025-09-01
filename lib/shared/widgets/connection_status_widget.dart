import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/utils/connectivity_helper.dart';

/// ويدجت عرض حالة الاتصال مع مؤشر جودة الشبكة
class ConnectionStatusWidget extends StatefulWidget {
  final bool showDetails;
  final EdgeInsetsGeometry? padding;

  const ConnectionStatusWidget({
    Key? key,
    this.showDetails = false,
    this.padding,
  }) : super(key: key);

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  ConnectionType _currentConnection = ConnectionType.none;
  String _connectionQuality = 'unknown';

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    
    // مراقبة تغييرات الاتصال
    _setupConnectionListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupConnectionListener() {
    ConnectivityHelper.instance.connectionStream.listen((connectionType) {
      if (mounted) {
        setState(() {
          _currentConnection = connectionType;
          _connectionQuality = _getConnectionQuality(connectionType);
        });
      }
    });

    // الحصول على الحالة الحالية
    setState(() {
      _currentConnection = ConnectivityHelper.instance.currentConnectionType;
      _connectionQuality = _getConnectionQuality(_currentConnection);
    });
  }

  String _getConnectionQuality(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
      case ConnectionType.ethernet:
        return 'excellent';
      case ConnectionType.mobile:
        return 'good';
      case ConnectionType.bluetooth:
      case ConnectionType.other:
        return 'fair';
      case ConnectionType.vpn:
        return 'fair';
      case ConnectionType.none:
      default:
        return 'none';
    }
  }

  Color _getConnectionColor() {
    switch (_connectionQuality) {
      case 'excellent':
        return AppTheme.successLight;
      case 'good':
        return AppTheme.lightTheme.primaryColor;
      case 'fair':
        return AppTheme.warningLight;
      case 'poor':
        return AppTheme.errorLight;
      case 'none':
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getConnectionIcon() {
    switch (_currentConnection) {
      case ConnectionType.wifi:
        return 'wifi';
      case ConnectionType.mobile:
        return 'signal_cellular_4_bar';
      case ConnectionType.ethernet:
        return 'cable';
      case ConnectionType.bluetooth:
        return 'bluetooth';
      case ConnectionType.vpn:
        return 'vpn_lock';
      case ConnectionType.other:
        return 'network_check';
      case ConnectionType.none:
      default:
        return 'signal_cellular_0_bar';
    }
  }

  String _getConnectionText() {
    if (_currentConnection == ConnectionType.none) {
      return 'غير متصل';
    }

    final connectionName = ConnectivityHelper.instance.getConnectionTypeInArabic();
    
    if (!widget.showDetails) {
      return connectionName;
    }

    final qualityText = _getQualityText();
    return '$connectionName - $qualityText';
  }

  String _getQualityText() {
    switch (_connectionQuality) {
      case 'excellent':
        return 'ممتاز';
      case 'good':
        return 'جيد';
      case 'fair':
        return 'متوسط';
      case 'poor':
        return 'ضعيف';
      case 'none':
      default:
        return 'منقطع';
    }
  }

  Widget _buildSignalBars() {
    final barCount = _getSignalBarCount();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < barCount;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 0.2.w),
          width: 0.8.w,
          height: (index + 1) * 0.8.h,
          decoration: BoxDecoration(
            color: isActive 
                ? _getConnectionColor()
                : _getConnectionColor().withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(0.5.w),
          ),
        );
      }),
    );
  }

  int _getSignalBarCount() {
    switch (_connectionQuality) {
      case 'excellent':
        return 4;
      case 'good':
        return 3;
      case 'fair':
        return 2;
      case 'poor':
        return 1;
      case 'none':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getConnectionColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getConnectionColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connection icon with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentConnection != ConnectionType.none 
                    ? _pulseAnimation.value 
                    : 1.0,
                child: CustomIconWidget(
                  iconName: _getConnectionIcon(),
                  color: _getConnectionColor(),
                  size: 4.w,
                ),
              );
            },
          ),

          SizedBox(width: 2.w),

          // Connection text
          Text(
            _getConnectionText(),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getConnectionColor(),
              fontWeight: FontWeight.w600,
            ),
          ),

          if (widget.showDetails && _currentConnection != ConnectionType.none) ...[
            SizedBox(width: 2.w),
            _buildSignalBars(),
          ],
        ],
      ),
    );
  }
}