import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParticipantManagementSection extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final Function(String userId, String action) onParticipantAction;

  const ParticipantManagementSection({
    super.key,
    required this.participants,
    required this.onParticipantAction,
  });

  void _showParticipantActions(
      BuildContext context, Map<String, dynamic> participant) {
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
            Row(
              children: [
                CircleAvatar(
                  radius: 6.w,
                  backgroundImage: NetworkImage(participant['avatar'] ?? ''),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant['name'] ?? '',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        participant['role'] == 'owner'
                            ? 'مالك الغرفة'
                            : 'مشارك',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            if (participant['role'] != 'owner') ...[
              _buildActionTile(
                context: context,
                icon: 'admin_panel_settings',
                title: 'ترقية إلى مشرف مساعد',
                subtitle: 'منح صلاحيات إدارية محدودة',
                onTap: () {
                  Navigator.pop(context);
                  onParticipantAction(participant['id'], 'promote');
                },
              ),
              _buildActionTile(
                context: context,
                icon: participant['isMuted'] == true ? 'mic' : 'mic_off',
                title: participant['isMuted'] == true
                    ? 'إلغاء كتم الصوت'
                    : 'كتم الصوت',
                subtitle: participant['isMuted'] == true
                    ? 'السماح للمشارك بالتحدث'
                    : 'منع المشارك من التحدث',
                onTap: () {
                  Navigator.pop(context);
                  onParticipantAction(participant['id'],
                      participant['isMuted'] == true ? 'unmute' : 'mute');
                },
              ),
              _buildActionTile(
                context: context,
                icon: 'person_remove',
                title: 'إزالة من الغرفة',
                subtitle: 'إخراج المشارك من الغرفة نهائياً',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showRemoveConfirmation(context, participant);
                },
              ),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isDestructive
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isDestructive ? AppTheme.lightTheme.colorScheme.error : null,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
      onTap: onTap,
    );
  }

  void _showRemoveConfirmation(
      BuildContext context, Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إزالة المشارك',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل أنت متأكد من إزالة "${participant['name']}" من الغرفة؟ لن يتمكن من الانضمام مرة أخرى إلا بدعوة جديدة.',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
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
              onParticipantAction(participant['id'], 'remove');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'إزالة',
              style: TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إدارة المشاركين',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${participants.length} مشارك',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Participants List
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final participant = participants[index];
              return GestureDetector(
                onTap: () => _showParticipantActions(context, participant),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 6.w,
                            backgroundImage:
                                NetworkImage(participant['avatar'] ?? ''),
                          ),
                          if (participant['isOnline'] == true)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 3.w,
                                height: 3.w,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme
                                        .lightTheme.scaffoldBackgroundColor,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    participant['name'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                if (participant['role'] == 'owner')
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'مالك',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  participant['isOnline'] == true
                                      ? 'متصل الآن'
                                      : 'غير متصل',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
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
                                Row(
                                  children: [
                                    if (participant['isMuted'] == true)
                                      CustomIconWidget(
                                        iconName: 'mic_off',
                                        color: AppTheme
                                            .lightTheme.colorScheme.error,
                                        size: 4.w,
                                      ),
                                    if (participant['role'] != 'owner')
                                      CustomIconWidget(
                                        iconName: 'more_vert',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 4.w,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
