import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/participant_limit_slider_widget.dart';
import './widgets/privacy_selector_widget.dart';
import './widgets/room_image_selector_widget.dart';
import './widgets/room_type_selector_widget.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key}) : super(key: key);

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _roomDescriptionController = TextEditingController();
  final _scrollController = ScrollController();

  // Room configuration
  String? _roomImagePath;
  RoomType _selectedRoomType = RoomType.both;
  PrivacyType _selectedPrivacy = PrivacyType.public;
  int _participantLimit = 10;
  bool _autoMuteNewParticipants = false;
  bool _allowScreenSharing = true;
  int _roomDurationMinutes = 0; // 0 means no limit
  String _languagePreference = 'ar'; // Arabic by default

  bool _isCreating = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _roomNameController.addListener(_validateForm);
    _roomDescriptionController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomDescriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _roomNameController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String _formatArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return arabicDigits[int.parse(digit)];
    }).join('');
  }

  Future<void> _createRoom() async {
    if (!_isFormValid || _isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Simulate room creation process
      await Future.delayed(Duration(seconds: 2));

      // Create room data
      final roomData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _roomNameController.text.trim(),
        'description': _roomDescriptionController.text.trim(),
        'image': _roomImagePath,
        'type': _selectedRoomType.toString().split('.').last,
        'privacy': _selectedPrivacy.toString().split('.').last,
        'participantLimit': _participantLimit,
        'autoMuteNewParticipants': _autoMuteNewParticipants,
        'allowScreenSharing': _allowScreenSharing,
        'durationMinutes': _roomDurationMinutes,
        'language': _languagePreference,
        'ownerId': 'current_user_id',
        'createdAt': DateTime.now().toIso8601String(),
        'participants': [],
        'isActive': true,
      };

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء الغرفة بنجاح',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );

        // Navigate to room interface as owner
        Navigator.pushReplacementNamed(context, '/room-interface');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إنشاء الغرفة',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_roomNameController.text.trim().isNotEmpty ||
        _roomDescriptionController.text.trim().isNotEmpty ||
        _roomImagePath != null) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'تأكيد الخروج',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
              content: Text(
                'هل تريد الخروج بدون حفظ التغييرات؟',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('خروج'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'إنشاء غرفة',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
              icon: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isFormValid && !_isCreating ? _createRoom : null,
                child: _isCreating
                    ? SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                      )
                    : Text(
                        'إنشاء',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: _isFormValid
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(width: 2.w),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Name Field
                        Text(
                          'اسم الغرفة *',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          controller: _roomNameController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLength: 50,
                          decoration: InputDecoration(
                            hintText: 'أدخل اسم الغرفة',
                            hintTextDirection: TextDirection.rtl,
                            counterText:
                                '${_roomNameController.text.length}/${50}',
                            counterStyle: AppTheme
                                .lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'اسم الغرفة مطلوب';
                            }
                            if (value.trim().length < 3) {
                              return 'اسم الغرفة يجب أن يكون ٣ أحرف على الأقل';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {}); // Update counter
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Room Description Field
                        Text(
                          'وصف الغرفة',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        TextFormField(
                          controller: _roomDescriptionController,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 3,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText: 'أدخل وصف الغرفة (اختياري)',
                            hintTextDirection: TextDirection.rtl,
                            counterText:
                                '${_roomDescriptionController.text.length}/${200}',
                            counterStyle: AppTheme
                                .lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {}); // Update counter
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Room Image Selector
                        RoomImageSelectorWidget(
                          initialImage: _roomImagePath,
                          onImageSelected: (imagePath) {
                            setState(() {
                              _roomImagePath = imagePath;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Room Type Selector
                        RoomTypeSelectorWidget(
                          selectedType: _selectedRoomType,
                          onTypeChanged: (type) {
                            setState(() {
                              _selectedRoomType = type;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Privacy Selector
                        PrivacySelectorWidget(
                          selectedPrivacy: _selectedPrivacy,
                          onPrivacyChanged: (privacy) {
                            setState(() {
                              _selectedPrivacy = privacy;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Participant Limit Slider
                        ParticipantLimitSliderWidget(
                          participantLimit: _participantLimit,
                          onLimitChanged: (limit) {
                            setState(() {
                              _participantLimit = limit;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),

                        // Language Preference
                        Text(
                          'لغة الغرفة',
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<String>(
                                title: Text(
                                  'العربية',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyLarge,
                                  textAlign: TextAlign.right,
                                ),
                                value: 'ar',
                                groupValue: _languagePreference,
                                onChanged: (value) {
                                  setState(() {
                                    _languagePreference = value!;
                                  });
                                },
                                activeColor: AppTheme.lightTheme.primaryColor,
                              ),
                              Divider(
                                height: 1,
                                color: AppTheme.lightTheme.colorScheme.outline,
                              ),
                              RadioListTile<String>(
                                title: Text(
                                  'English',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyLarge,
                                  textAlign: TextAlign.right,
                                ),
                                value: 'en',
                                groupValue: _languagePreference,
                                onChanged: (value) {
                                  setState(() {
                                    _languagePreference = value!;
                                  });
                                },
                                activeColor: AppTheme.lightTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Advanced Settings
                        AdvancedSettingsWidget(
                          autoMuteNewParticipants: _autoMuteNewParticipants,
                          allowScreenSharing: _allowScreenSharing,
                          roomDurationMinutes: _roomDurationMinutes,
                          onAutoMuteChanged: (value) {
                            setState(() {
                              _autoMuteNewParticipants = value;
                            });
                          },
                          onScreenSharingChanged: (value) {
                            setState(() {
                              _allowScreenSharing = value;
                            });
                          },
                          onDurationChanged: (duration) {
                            setState(() {
                              _roomDurationMinutes = duration;
                            });
                          },
                        ),
                        SizedBox(height: 10.h), // Extra space for bottom button
                      ],
                    ),
                  ),
                ),

                // Bottom Create Button
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed:
                            _isFormValid && !_isCreating ? _createRoom : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isCreating
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 5.w,
                                    height: 5.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'جاري الإنشاء...',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'إنشاء الغرفة',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
