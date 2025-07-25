import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sepesha_app/models/conversation_model.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isTyping;
  final bool showOnlineStatus;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Conversation)? onDelete;

  const ConversationListItem({
    super.key,
    required this.conversation,
    this.isSelected = false,
    this.isTyping = false,
    this.showOnlineStatus = true,
    this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:
            isSelected ? AppColor.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar with online status
                _buildAvatar(),

                const SizedBox(width: 12),

                // Conversation details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and timestamp row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.conversationTitle,
                              style: AppTextStyle.subheadingTextStyle.copyWith(
                                fontWeight:
                                    conversation.hasUnreadMessages
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color: AppColor.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Timestamp
                          Text(
                            conversation.formattedLastActivity,
                            style: AppTextStyle.captionTextStyle.copyWith(
                              color:
                                  conversation.hasUnreadMessages
                                      ? AppColor.primary
                                      : AppColor.grey,
                              fontWeight:
                                  conversation.hasUnreadMessages
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Last message and unread count row
                      Row(
                        children: [
                          Expanded(child: _buildLastMessagePreview()),

                          const SizedBox(width: 8),

                          // Unread count badge
                          if (conversation.hasUnreadMessages)
                            _buildUnreadBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        // Main avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.lightGrey,
          ),
          child:
              conversation.participantPhoto != null
                  ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: conversation.participantPhoto!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: AppColor.lightGrey,
                            child: Icon(
                              Icons.person,
                              color: AppColor.grey,
                              size: 28,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppColor.lightGrey,
                            child: Icon(
                              Icons.person,
                              color: AppColor.grey,
                              size: 28,
                            ),
                          ),
                    ),
                  )
                  : _buildAvatarFallback(),
        ),

        // Online status indicator
        if (showOnlineStatus && conversation.isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),

        // Conversation type icon
        if (conversation.type != ConversationType.general)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _getTypeIconColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(_getTypeIcon(), color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColor.primary.withOpacity(0.8), AppColor.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          conversation.participantInitials,
          style: AppTextStyle.headingTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessagePreview() {
    if (isTyping) {
      return Row(
        children: [
          Icon(Icons.edit, size: 14, color: AppColor.primary),
          const SizedBox(width: 4),
          Text(
            'typing...',
            style: AppTextStyle.bodyTextStyle.copyWith(
              color: AppColor.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    final lastMessage = conversation.lastMessage;
    if (lastMessage == null) {
      return Text(
        'No messages yet',
        style: AppTextStyle.bodyTextStyle.copyWith(
          color: AppColor.grey,
          fontStyle: FontStyle.italic,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        // Message type icon
        if (lastMessage.messageType != MessageType.text) ...[
          Icon(
            _getMessageTypeIcon(lastMessage.messageType),
            size: 16,
            color: AppColor.grey,
          ),
          const SizedBox(width: 4),
        ],

        // Message preview
        Expanded(
          child: Text(
            conversation.lastMessagePreview,
            style: AppTextStyle.bodyTextStyle.copyWith(
              color:
                  conversation.hasUnreadMessages
                      ? AppColor.black
                      : AppColor.grey,
              fontWeight:
                  conversation.hasUnreadMessages
                      ? FontWeight.w500
                      : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        conversation.unreadCount > 99
            ? '99+'
            : conversation.unreadCount.toString(),
        style: AppTextStyle.captionTextStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  IconData _getMessageTypeIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
        return Icons.image;
      case MessageType.location:
        return Icons.location_on;
      case MessageType.audio:
        return Icons.mic;
      case MessageType.video:
        return Icons.videocam;
      case MessageType.text:
        return Icons.message;
    }
  }

  IconData _getTypeIcon() {
    switch (conversation.type) {
      case ConversationType.driverCustomer:
      case ConversationType.customerDriver:
        return Icons.directions_car;
      case ConversationType.driverSupport:
      case ConversationType.customerSupport:
        return Icons.headset_mic;
      case ConversationType.vendorCustomer:
        return Icons.shopping_bag;
      case ConversationType.vendorDriver:
        return Icons.local_shipping;
      case ConversationType.general:
        return Icons.chat;
    }
  }

  Color _getTypeIconColor() {
    switch (conversation.type) {
      case ConversationType.driverCustomer:
      case ConversationType.customerDriver:
        return AppColor.primary;
      case ConversationType.driverSupport:
      case ConversationType.customerSupport:
        return Colors.orange;
      case ConversationType.vendorCustomer:
        return Colors.green;
      case ConversationType.vendorDriver:
        return Colors.blue;
      case ConversationType.general:
        return AppColor.grey;
    }
  }
}

// Conversation list item with swipe actions
class SwipeableConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final bool isTyping;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(Conversation)? onDelete;
  final Function(Conversation)? onMute;
  final Function(Conversation)? onPin;

  const SwipeableConversationListItem({
    super.key,
    required this.conversation,
    this.isSelected = false,
    this.isTyping = false,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onMute,
    this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call(conversation);
      },
      child: ConversationListItem(
        conversation: conversation,
        isSelected: isSelected,
        isTyping: isTyping,
        onTap: onTap,
        onLongPress: onLongPress,
        onDelete: onDelete,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text(
              'Are you sure you want to delete this conversation with ${conversation.participantName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

// Empty state widget for conversation list
class ConversationListEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const ConversationListEmptyState({
    super.key,
    this.title = 'No conversations yet',
    this.subtitle = 'Start a new conversation to begin messaging',
    this.icon = Icons.chat_bubble_outline,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColor.grey.withOpacity(0.5)),

            const SizedBox(height: 24),

            Text(
              title,
              style: AppTextStyle.headingTextStyle.copyWith(
                color: AppColor.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              subtitle,
              style: AppTextStyle.bodyTextStyle.copyWith(color: AppColor.grey),
              textAlign: TextAlign.center,
            ),

            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Loading state widget for conversation list
class ConversationListLoadingState extends StatelessWidget {
  final int itemCount;

  const ConversationListLoadingState({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => const ConversationListItemSkeleton(),
    );
  }
}

// Skeleton loading item
class ConversationListItemSkeleton extends StatefulWidget {
  const ConversationListItemSkeleton({super.key});

  @override
  State<ConversationListItemSkeleton> createState() =>
      _ConversationListItemSkeletonState();
}

class _ConversationListItemSkeletonState
    extends State<ConversationListItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar skeleton
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.lightGrey.withOpacity(_animation.value),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Name skeleton
                    Expanded(
                      flex: 3,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColor.lightGrey.withOpacity(
                                _animation.value,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Timestamp skeleton
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColor.lightGrey.withOpacity(
                                _animation.value,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Message skeleton
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.lightGrey.withOpacity(
                          _animation.value * 0.7,
                        ),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
