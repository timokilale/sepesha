import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/provider/message_provider.dart';
import 'package:sepesha_app/widgets/message_bubble.dart';
import 'package:sepesha_app/widgets/chat_input.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String participantId;
  final String participantName;
  final String? participantPhoto;
  final String? bookingId;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.participantId,
    required this.participantName,
    this.participantPhoto,
    this.bookingId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  bool _isKeyboardVisible = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    _setupScrollListener();
    _inputFocusNode.addListener(_onInputFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _inputFocusNode.dispose();

    // Leave conversation when screen is disposed
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    messageProvider.leaveCurrentConversation();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    if (_isKeyboardVisible != isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = isKeyboardVisible;
      });

      if (isKeyboardVisible) {
        _scrollToBottom();
      }
    }
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageProvider = Provider.of<MessageProvider>(
        context,
        listen: false,
      );
      messageProvider.loadMessages(
        conversationId: widget.conversationId,
        participantId: widget.participantId,
        bookingId: widget.bookingId,
      );
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (_showScrollToBottom != showButton) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }
    });
  }

  void _onInputFocusChanged() {
    if (_inputFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage(String message, MessageType type, String? attachment) {
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    messageProvider
        .sendMessage(
          recipientId: widget.participantId,
          message: message,
          bookingId: widget.bookingId,
          messageType: type,
          attachment: attachment,
        )
        .then((success) {
          if (success) {
            _scrollToBottom();
          }
        });
  }

  void _sendLocation() async {
    try {
      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Format location as a message
      final locationJson = jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      // Send as a location type message
      _sendMessage(
        locationJson,
        MessageType.location,
        null, // No attachment for location messages
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share location: $e')));
    }
  }

  void _onTypingChanged(bool isTyping) {
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    messageProvider.sendTypingIndicator(
      recipientId: widget.participantId,
      isTyping: isTyping,
    );
  }

  void _showImageViewer(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(imageUrl: imageUrl),
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => MessageOptionsBottomSheet(
            message: message,
            onCopy: () => _copyMessage(message),
            onDelete: () => _deleteMessage(message),
            onReply: () => _replyToMessage(message),
          ),
    );
  }

  void _copyMessage(Message message) {
    // Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard')),
    );
  }

  void _deleteMessage(Message message) {
    // Implement message deletion
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message deleted')));
  }

  void _replyToMessage(Message message) {
    // Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply functionality coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return _buildMessagesList(messageProvider);
              },
            ),
          ),

          // Typing indicator
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              final isTyping = messageProvider.isUserTyping(
                widget.participantId,
              );
              if (isTyping) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TypingBubble(
                    senderName: widget.participantName,
                    senderAvatar: widget.participantPhoto,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Chat input
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              return ChatInput(
                onSendMessage: _sendMessage,
                onSendLocation: _sendLocation,
                onTypingChanged: _onTypingChanged,
                isEnabled: !messageProvider.isSendingMessage,
              );
            },
          ),
        ],
      ),
      floatingActionButton:
          _showScrollToBottom
              ? FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: AppColor.primary,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              )
              : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back, color: AppColor.black),
      ),
      title: Row(
        children: [
          // Participant avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.lightGrey,
            ),
            child:
                widget.participantPhoto != null
                    ? ClipOval(
                      child: Image.network(
                        widget.participantPhoto!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarFallback();
                        },
                      ),
                    )
                    : _buildAvatarFallback(),
          ),

          const SizedBox(width: 12),

          // Participant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.participantName,
                  style: AppTextStyle.subheadingTextStyle.copyWith(
                    color: AppColor.black,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Consumer<MessageProvider>(
                  builder: (context, messageProvider, child) {
                    final isOnline = messageProvider.isUserOnline(
                      widget.participantId,
                    );
                    final isTyping = messageProvider.isUserTyping(
                      widget.participantId,
                    );

                    if (isTyping) {
                      return Text(
                        'typing...',
                        style: AppTextStyle.captionTextStyle.copyWith(
                          color: AppColor.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return Text(
                      isOnline ? 'Online' : 'Last seen recently',
                      style: AppTextStyle.captionTextStyle.copyWith(
                        color: isOnline ? Colors.green : AppColor.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _makeVoiceCall,
          icon: Icon(Icons.call, color: AppColor.primary),
        ),
        IconButton(
          onPressed: _makeVideoCall,
          icon: Icon(Icons.videocam, color: AppColor.primary),
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 12),
                      Text('View Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 12),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block_user',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Block User', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColor.primary.withOpacity(0.8), AppColor.primary],
        ),
      ),
      child: Center(
        child: Text(
          widget.participantName.isNotEmpty
              ? widget.participantName[0].toUpperCase()
              : '?',
          style: AppTextStyle.bodyTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(MessageProvider messageProvider) {
    if (messageProvider.isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messageProvider.error != null) {
      return _buildErrorState(messageProvider);
    }

    final messages = messageProvider.currentMessages;

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId != widget.participantId;
        final showTimestamp = _shouldShowTimestamp(messages, index);

        return MessageBubble(
          message: message,
          isCurrentUser: isCurrentUser,
          showTimestamp: showTimestamp,
          senderName: isCurrentUser ? null : widget.participantName,
          senderAvatar: isCurrentUser ? null : widget.participantPhoto,
          onTap: () => _showMessageOptions(message),
          onImageTap:
              message.hasAttachment
                  ? () => _showImageViewer(message.attachment!)
                  : null,
        );
      },
    );
  }

  Widget _buildErrorState(MessageProvider messageProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.5),
            ),

            const SizedBox(height: 24),

            Text(
              'Failed to load messages',
              style: AppTextStyle.headingTextStyle.copyWith(
                color: AppColor.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              messageProvider.error ?? 'Unknown error occurred',
              style: AppTextStyle.bodyTextStyle.copyWith(color: AppColor.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                messageProvider.clearError();
                _initializeChat();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColor.grey.withOpacity(0.5),
            ),

            const SizedBox(height: 24),

            Text(
              'No messages yet',
              style: AppTextStyle.headingTextStyle.copyWith(
                color: AppColor.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Start the conversation by sending a message',
              style: AppTextStyle.bodyTextStyle.copyWith(color: AppColor.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowTimestamp(List<Message> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];

    final timeDifference = currentMessage.createdAt.difference(
      nextMessage.createdAt,
    );
    return timeDifference.inMinutes > 5;
  }

  void _makeVoiceCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice call feature coming soon')),
    );
  }

  void _makeVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video call feature coming soon')),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'view_profile':
        _viewProfile();
        break;
      case 'clear_chat':
        _clearChat();
        break;
      case 'block_user':
        _blockUser();
        break;
    }
  }

  void _viewProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile view coming soon')));
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat'),
            content: const Text(
              'Are you sure you want to clear this chat? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Chat cleared')));
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _blockUser() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Block User'),
            content: Text(
              'Are you sure you want to block ${widget.participantName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.participantName} blocked'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Block'),
              ),
            ],
          ),
    );
  }
}

// Image viewer screen
class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // Implement save image
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Save image coming soon')),
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 80, color: Colors.white54),
                    SizedBox(height: 16),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Message options bottom sheet
class MessageOptionsBottomSheet extends StatelessWidget {
  final Message message;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onReply;

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onDelete,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              onCopy();
            },
          ),
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              onReply();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
