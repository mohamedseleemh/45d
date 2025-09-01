import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DangerZoneSection extends StatelessWidget {
  final Function() onTransferOwnership;
  final Function() onDeleteRoom;

  const DangerZoneSection({
    super.key,
    required this.onTransferOwnership,
    required this.onDeleteRoom,
  });

  void _showTransferOwnershipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'نقل ملكية الغرفة',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من نقل ملكية الغرفة؟',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'warning',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'تحذير مهم',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• ستفقد جميع صلاحيات إدارة الغرفة\n• لن تتمكن من استعادة الملكية\n• المالك الجديد سيتحكم في جميع الإعدادات',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              textDirection: TextDirection.rtl,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSelectNewOwnerDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'متابعة',
              style: TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectNewOwnerDialog(BuildContext context) {
    // Mock participants data for selection
    final List<Map<String, dynamic>> participants = [
      {
        'id': '2',
        'name': 'أحمد محمد',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'isOnline': true,
      },
      {
        'id': '3',
        'name': 'فاطمة علي',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'isOnline': true,
      },
      {
        'id': '4',
        'name': 'محمد حسن',
        'avatar':
            'https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png',
        'isOnline': false,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
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
                'اختر المالك الجديد',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showFinalConfirmation(context, participant);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 6.w,
                                  backgroundImage:
                                      NetworkImage(participant['avatar']),
                                ),
                                if (participant['isOnline'] == true)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 3.w,
                                      height: 3.w,
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.lightTheme
                                              .scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    participant['name'],
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  Text(
                                    participant['isOnline'] == true
                                        ? 'متصل الآن'
                                        : 'غير متصل',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: participant['isOnline'] == true
                                          ? AppTheme
                                              .lightTheme.colorScheme.primary
                                          : AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'keyboard_arrow_left',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 6.w,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFinalConfirmation(
      BuildContext context, Map<String, dynamic> newOwner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد نقل الملكية',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundImage: NetworkImage(newOwner['avatar']),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'سيتم نقل ملكية الغرفة إلى "${newOwner['name']}"',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              textDirection: TextDirection.rtl,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onTransferOwnership();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'نقل الملكية',
              style: TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoomDialog(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'حذف الغرفة نهائياً',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'delete_forever',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'تحذير: هذا الإجراء لا يمكن التراجع عنه',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '• سيتم حذف الغرفة نهائياً\n• سيتم إخراج جميع المشاركين\n• سيتم حذف جميع الرسائل والتسجيلات\n• لا يمكن استعادة البيانات',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'للتأكيد، اكتب "حذف الغرفة" في الحقل أدناه:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: confirmController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'حذف الغرفة',
                  hintTextDirection: TextDirection.rtl,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                textDirection: TextDirection.rtl,
              ),
            ),
            ElevatedButton(
              onPressed: confirmController.text == 'حذف الغرفة'
                  ? () {
                      Navigator.pop(context);
                      onDeleteRoom();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                disabledBackgroundColor: AppTheme
                    .lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
              ),
              child: Text(
                'حذف الغرفة',
                style: TextStyle(
                  color: confirmController.text == 'حذف الغرفة'
                      ? Colors.white
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'المنطقة الخطرة',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'الإجراءات في هذا القسم لا يمكن التراجع عنها',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 3.h),

          // Transfer Ownership
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نقل ملكية الغرفة',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'نقل جميع صلاحيات إدارة الغرفة إلى مشارك آخر',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showTransferOwnershipDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                    child: Text(
                      'نقل الملكية',
                      style: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Delete Room
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حذف الغرفة نهائياً',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'حذف الغرفة وجميع بياناتها نهائياً. لا يمكن التراجع عن هذا الإجراء',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showDeleteRoomDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    ),
                    child: Text(
                      'حذف الغرفة',
                      style: TextStyle(color: Colors.white),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
