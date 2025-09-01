import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModerationToolsSection extends StatelessWidget {
  final List<Map<String, dynamic>> blockedUsers;
  final List<Map<String, dynamic>> reportedMessages;
  final bool autoModeration;
  final Function(String userId) onUnblockUser;
  final Function(String messageId, String action) onMessageAction;
  final Function(bool) onAutoModerationChanged;

  const ModerationToolsSection({
    super.key,
    required this.blockedUsers,
    required this.reportedMessages,
    required this.autoModeration,
    required this.onUnblockUser,
    required this.onMessageAction,
    required this.onAutoModerationChanged,
  });

  void _showBlockedUsers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                'المستخدمون المحظورون',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: blockedUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'block',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 15.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'لا يوجد مستخدمون محظورون',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: blockedUsers.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          final user = blockedUsers[index];
                          return Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.lightTheme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 6.w,
                                  backgroundImage:
                                      NetworkImage(user['avatar'] ?? ''),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['name'] ?? '',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      Text(
                                        'محظور منذ ${user['blockedDate'] ?? ''}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => onUnblockUser(user['id']),
                                  child: Text(
                                    'إلغاء الحظر',
                                    style: TextStyle(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
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

  void _showReportedMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                'الرسائل المبلغ عنها',
                style: AppTheme.lightTheme.textTheme.titleLarge,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: reportedMessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'report',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 15.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'لا توجد رسائل مبلغ عنها',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: reportedMessages.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          final message = reportedMessages[index];
                          return Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.lightTheme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 4.w,
                                      backgroundImage: NetworkImage(
                                          message['senderAvatar'] ?? ''),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        message['senderName'] ?? '',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme
                                            .lightTheme.colorScheme.error
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${message['reportCount'] ?? 1} بلاغ',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme
                                              .lightTheme.colorScheme.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightTheme.colorScheme.error
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme
                                          .lightTheme.colorScheme.error
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    message['content'] ?? '',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyMedium,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => onMessageAction(
                                            message['id'], 'dismiss'),
                                        child: Text(
                                          'تجاهل البلاغ',
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => onMessageAction(
                                            message['id'], 'delete'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme
                                              .lightTheme.colorScheme.error,
                                        ),
                                        child: Text(
                                          'حذف الرسالة',
                                          style: TextStyle(color: Colors.white),
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
            'أدوات الإشراف',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 3.h),

          // Blocked Users
          GestureDetector(
            onTap: () => _showBlockedUsers(context),
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
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'block',
                        color: AppTheme.lightTheme.colorScheme.error,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المستخدمون المحظورون',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          '${blockedUsers.length} مستخدم محظور',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_left',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Reported Messages
          GestureDetector(
            onTap: () => _showReportedMessages(context),
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
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: CustomIconWidget(
                            iconName: 'report',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 5.w,
                          ),
                        ),
                        if (reportedMessages.isNotEmpty)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${reportedMessages.length}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرسائل المبلغ عنها',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          reportedMessages.isEmpty
                              ? 'لا توجد رسائل مبلغ عنها'
                              : '${reportedMessages.length} رسالة تحتاج مراجعة',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: reportedMessages.isEmpty
                                ? AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant
                                : AppTheme.lightTheme.colorScheme.error,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_left',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Auto Moderation
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإشراف التلقائي',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      'حذف الرسائل المخالفة تلقائياً',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoModeration,
                onChanged: onAutoModerationChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
