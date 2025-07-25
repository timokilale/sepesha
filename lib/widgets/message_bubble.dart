import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showTimestamp;
  final bool showAvatar;
  final String? senderName;
  final String? senderAvatar;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.showTimestamp = true,
    this.showAvatar = true,
    this.senderName,
    this.senderAvatar,
    this.onTap,
    this.onLongPress,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for received messages
          if (!isCurrentUser && showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                // Sender name for received messages
                if (!isCurrentUser && senderName != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      senderName!,
                      style: AppTextStyle.captionTextStyle.copyWith(
                        color: AppColor.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                // Message bubble
                GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                      minWidth: 60,
                    ),
                    decoration: BoxDecoration(
                      color: _getBubbleColor(),
                      borderRadius: _getBubbleBorderRadius(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildMessageContent(context),
                  ),
                ),

                // Timestamp and status
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  _buildTimestampAndStatus(),
                ],
              ],
            ),
          ),

          // Avatar for sent messages (optional)
          if (isCurrentUser && showAvatar) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.lightGrey,
      ),
      child:
          senderAvatar != null
              ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: senderAvatar!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: AppColor.lightGrey,
                        child: Icon(
                          Icons.person,
                          color: AppColor.grey,
                          size: 20,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: AppColor.lightGrey,
                        child: Icon(
                          Icons.person,
                          color: AppColor.grey,
                          size: 20,
                        ),
                      ),
                ),
              )
              : Icon(Icons.person, color: AppColor.grey, size: 20),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.messageType) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.location:
        return _buildLocationMessage();
      case MessageType.audio:
        return _buildAudioMessage();
      case MessageType.video:
        return _buildVideoMessage();
    }
  }

  Widget _buildTextMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        message.message,
        style: AppTextStyle.bodyTextStyle.copyWith(
          color: isCurrentUser ? Colors.white : AppColor.black,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.hasAttachment) ...[
          GestureDetector(
            onTap: onImageTap,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 250, maxHeight: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: message.attachment!,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        height: 150,
                        color: AppColor.lightGrey,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        height: 150,
                        color: AppColor.lightGrey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: AppColor.grey,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load image',
                              style: AppTextStyle.captionTextStyle.copyWith(
                                color: AppColor.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
        ],
        if (message.message.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              message.message,
              style: AppTextStyle.bodyTextStyle.copyWith(
                color: isCurrentUser ? Colors.white : AppColor.black,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: isCurrentUser ? Colors.white : AppColor.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: AppTextStyle.bodyTextStyle.copyWith(
                    color: isCurrentUser ? Colors.white : AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: AppTextStyle.captionTextStyle.copyWith(
                      color:
                          isCurrentUser
                              ? Colors.white.withOpacity(0.8)
                              : AppColor.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: isCurrentUser ? Colors.white : AppColor.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Message',
                  style: AppTextStyle.bodyTextStyle.copyWith(
                    color: isCurrentUser ? Colors.white : AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 100,
                  decoration: BoxDecoration(
                    color: (isCurrentUser ? Colors.white : AppColor.primary)
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.6, // Placeholder progress
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Colors.white : AppColor.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
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

  Widget _buildVideoMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: isCurrentUser ? Colors.white : AppColor.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Video Message',
              style: AppTextStyle.bodyTextStyle.copyWith(
                color: isCurrentUser ? Colors.white : AppColor.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampAndStatus() {
    return Padding(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 0 : 12,
        right: isCurrentUser ? 12 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.timeOnly,
            style: AppTextStyle.smallTextStyle.copyWith(color: AppColor.grey),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 4),
            _buildMessageStatus(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    IconData iconData;
    Color iconColor;

    if (message.isRead) {
      iconData = Icons.done_all;
      iconColor = AppColor.primary;
    } else {
      iconData = Icons.done;
      iconColor = AppColor.grey;
    }

    return Icon(iconData, size: 16, color: iconColor);
  }

  Color _getBubbleColor() {
    if (isCurrentUser) {
      return AppColor.primary;
    } else {
      return AppColor.lightGrey;
    }
  }

  BorderRadius _getBubbleBorderRadius() {
    if (isCurrentUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(4),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(16),
      );
    }
  }
}

// Message status indicator widget
class MessageStatusIndicator extends StatelessWidget {
  final Message message;
  final bool showDelivered;

  const MessageStatusIndicator({
    super.key,
    required this.message,
    this.showDelivered = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.timeOnly,
          style: AppTextStyle.smallTextStyle.copyWith(color: AppColor.grey),
        ),
        const SizedBox(width: 4),
        _buildStatusIcon(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    if (message.isRead) {
      return Icon(Icons.done_all, size: 16, color: AppColor.primary);
    } else if (showDelivered) {
      return Icon(Icons.done, size: 16, color: AppColor.grey);
    } else {
      return Icon(Icons.access_time, size: 16, color: AppColor.grey);
    }
  }
}

// Typing indicator bubble
class TypingBubble extends StatefulWidget {
  final String? senderName;
  final String? senderAvatar;

  const TypingBubble({super.key, this.senderName, this.senderAvatar});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.lightGrey,
            ),
            child:
                widget.senderAvatar != null
                    ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: widget.senderAvatar!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Icon(
                              Icons.person,
                              color: AppColor.grey,
                              size: 20,
                            ),
                        errorWidget:
                            (context, url, error) => Icon(
                              Icons.person,
                              color: AppColor.grey,
                              size: 20,
                            ),
                      ),
                    )
                    : Icon(Icons.person, color: AppColor.grey, size: 20),
          ),
          const SizedBox(width: 8),

          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(1),
                    const SizedBox(width: 4),
                    _buildDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
    final opacity = (animationValue * 2).clamp(0.0, 1.0);

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.grey.withOpacity(opacity),
      ),
    );
  }
}
