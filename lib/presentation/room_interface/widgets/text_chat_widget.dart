import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TextChatWidget extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final Function(String message) onSendMessage;

  const TextChatWidget({
    Key? key,
    required this.messages,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  State<TextChatWidget> createState() => _TextChatWidgetState();
}

class _TextChatWidgetState extends State<TextChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.w),
          bottomLeft: Radius.circular(4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.w),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'chat',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'المحادثة النصية',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: widget.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(3.w),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'chat_bubble_outline',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'لا توجد رسائل بعد',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'ابدأ المحادثة بإرسال رسالة',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.7),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isLocal = message['isLocal'] as bool? ?? false;
    final senderName = message['senderName'] as String;
    final content = message['content'] as String;
    final timestamp = message['timestamp'] as DateTime;
    final avatar = message['avatar'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isLocal ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isLocal) ...[
            // Sender avatar
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.primaryColor,
              ),
              child: ClipOval(
                child: avatar != null
                    ? CustomImageWidget(
                        imageUrl: avatar,
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Text(
                          senderName.isNotEmpty
                              ? senderName[0].toUpperCase()
                              : "U",
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 3.w,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),

            SizedBox(width: 2.w),
          ],

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isLocal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isLocal)
                  Padding(
                    padding: EdgeInsets.only(bottom: 0.5.h),
                    child: Text(
                      senderName,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isLocal
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3.w),
                      topRight: Radius.circular(3.w),
                      bottomLeft: isLocal
                          ? Radius.circular(3.w)
                          : Radius.circular(0.5.w),
                      bottomRight: isLocal
                          ? Radius.circular(0.5.w)
                          : Radius.circular(3.w),
                    ),
                  ),
                  child: Text(
                    content,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isLocal
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                    textDirection: _getTextDirection(content),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(timestamp),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 9.sp,
                  ),
                ),
              ],
            ),
          ),

          if (isLocal) ...[
            SizedBox(width: 2.w),

            // Local user indicator
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.primaryColor,
              ),
              child: Center(
                child: Text(
                  "أ",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 3.w,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.w),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.w),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.w),
                    borderSide: BorderSide(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  filled: true,
                  fillColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'send',
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String text) {
    // Simple Arabic text detection
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
