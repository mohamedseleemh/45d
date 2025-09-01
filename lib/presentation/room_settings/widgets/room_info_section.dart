import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RoomInfoSection extends StatefulWidget {
  final String roomName;
  final String roomDescription;
  final String roomImageUrl;
  final Function(String) onNameChanged;
  final Function(String) onDescriptionChanged;
  final Function(String) onImageChanged;

  const RoomInfoSection({
    super.key,
    required this.roomName,
    required this.roomDescription,
    required this.roomImageUrl,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onImageChanged,
  });

  @override
  State<RoomInfoSection> createState() => _RoomInfoSectionState();
}

class _RoomInfoSectionState extends State<RoomInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final int _maxDescriptionLength = 200;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roomName);
    _descriptionController =
        TextEditingController(text: widget.roomDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectRoomImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'تغيير صورة الغرفة',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: 'camera_alt',
                  label: 'الكاميرا',
                  onTap: () {
                    Navigator.pop(context);
                    // Camera functionality would be implemented here
                  },
                ),
                _buildImageOption(
                  icon: 'photo_library',
                  label: 'المعرض',
                  onTap: () {
                    Navigator.pop(context);
                    // Gallery functionality would be implemented here
                  },
                ),
                _buildImageOption(
                  icon: 'delete',
                  label: 'حذف الصورة',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onImageChanged('');
                  },
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الغرفة',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),

          // Room Image
          Center(
            child: GestureDetector(
              onTap: _selectRoomImage,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: widget.roomImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImageWidget(
                          imageUrl: widget.roomImageUrl,
                          width: 25.w,
                          height: 25.w,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'add_a_photo',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 8.w,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'إضافة صورة',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Room Name Field
          Text(
            'اسم الغرفة',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'أدخل اسم الغرفة',
              hintTextDirection: TextDirection.rtl,
              suffixIcon: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ),
            onChanged: widget.onNameChanged,
          ),
          SizedBox(height: 3.h),

          // Room Description Field
          Text(
            'وصف الغرفة',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _descriptionController,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 3,
            maxLength: _maxDescriptionLength,
            decoration: InputDecoration(
              hintText: 'أدخل وصف الغرفة (اختياري)',
              hintTextDirection: TextDirection.rtl,
              alignLabelWithHint: true,
              counterText:
                  '${_descriptionController.text.length}/$_maxDescriptionLength',
              counterStyle: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              widget.onDescriptionChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
