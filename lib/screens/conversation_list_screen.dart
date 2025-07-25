import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sepesha_app/models/conversation_model.dart';
import 'package:sepesha_app/provider/message_provider.dart';
import 'package:sepesha_app/widgets/conversation_list_item.dart';
import 'package:sepesha_app/screens/chat_screen.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeConversations();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _initializeConversations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messageProvider = Provider.of<MessageProvider>(
        context,
        listen: false,
      );
      messageProvider.loadConversations();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      messageProvider.clearSearch();
    } else {
      setState(() {
        _isSearching = true;
      });
      messageProvider.searchConversations(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
    });
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    messageProvider.clearSearch();
  }

  void _navigateToChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationId: conversation.id,
              participantId: conversation.participantId,
              participantName: conversation.participantName,
              participantPhoto: conversation.participantPhoto,
              bookingId: conversation.bookingId,
            ),
      ),
    );
  }

  void _deleteConversation(Conversation conversation) {
    // Show confirmation and delete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conversation with ${conversation.participantName} deleted',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
  }

  Future<void> _refreshConversations() async {
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    await messageProvider.loadConversations(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Conversations list
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return _buildConversationsList(messageProvider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Messages',
        style: AppTextStyle.headingTextStyle.copyWith(
          color: AppColor.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Unread count badge
        Consumer<MessageProvider>(
          builder: (context, messageProvider, child) {
            if (messageProvider.unreadCount > 0) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigate to unread messages or filter
                      },
                      icon: Icon(
                        Icons.mark_email_unread,
                        color: AppColor.primary,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          messageProvider.unreadCount > 99
                              ? '99+'
                              : messageProvider.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // More options menu
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: 12),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: AppTextStyle.bodyTextStyle.copyWith(color: AppColor.grey),
          prefixIcon: Icon(Icons.search, color: AppColor.grey),
          suffixIcon:
              _isSearching
                  ? IconButton(
                    onPressed: _clearSearch,
                    icon: Icon(Icons.clear, color: AppColor.grey),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColor.lightGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColor.lightGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColor.primary),
          ),
          filled: true,
          fillColor: AppColor.lightGrey.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildConversationsList(MessageProvider messageProvider) {
    // Show loading state
    if (messageProvider.isLoadingConversations) {
      return const ConversationListLoadingState();
    }

    // Show error state
    if (messageProvider.error != null) {
      return _buildErrorState(messageProvider);
    }

    // Get conversations to display
    final conversations =
        _isSearching
            ? messageProvider.searchResults
            : messageProvider.conversations;

    // Show empty state
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    // Show conversations list
    return RefreshIndicator(
      onRefresh: _refreshConversations,
      color: AppColor.primary,
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final isTyping = messageProvider.isUserTyping(
            conversation.participantId,
          );

          return SwipeableConversationListItem(
            conversation: conversation,
            isTyping: isTyping,
            onTap: () => _navigateToChat(conversation),
            onDelete: _deleteConversation,
          );
        },
      ),
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
              'Something went wrong',
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
                _refreshConversations();
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
    if (_isSearching) {
      return ConversationListEmptyState(
        title: 'No results found',
        subtitle: 'Try searching with different keywords',
        icon: Icons.search_off,
        onActionPressed: _clearSearch,
        actionText: 'Clear Search',
      );
    }

    return ConversationListEmptyState(
      title: 'No conversations yet',
      subtitle: 'Start a new conversation to begin messaging',
      icon: Icons.chat_bubble_outline,
      onActionPressed: _showNewConversationDialog,
      actionText: 'Start New Chat',
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showNewConversationDialog,
      backgroundColor: AppColor.primary,
      child: const Icon(Icons.add_comment, color: Colors.white),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'settings':
        _navigateToSettings();
        break;
    }
  }

  void _markAllAsRead() {
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    // Implement mark all as read functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All conversations marked as read')),
    );
  }

  void _navigateToSettings() {
    // Navigate to message settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message settings coming soon')),
    );
  }

  void _showNewConversationDialog() {
    showDialog(
      context: context,
      builder: (context) => const NewConversationDialog(),
    );
  }
}

// New conversation dialog
class NewConversationDialog extends StatefulWidget {
  const NewConversationDialog({super.key});

  @override
  State<NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<NewConversationDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _contacts = [
    {
      'id': '1',
      'name': 'John Driver',
      'phone': '+1234567890',
      'type': 'driver',
      'avatar': null,
    },
    {
      'id': '2',
      'name': 'Jane Customer',
      'phone': '+0987654321',
      'type': 'customer',
      'avatar': null,
    },
    // Add more mock contacts as needed
  ];

  List<Map<String, dynamic>> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = _contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts =
          _contacts.where((contact) {
            return contact['name'].toLowerCase().contains(query) ||
                contact['phone'].contains(query);
          }).toList();
    });
  }

  void _startConversation(Map<String, dynamic> contact) {
    Navigator.pop(context);

    // Navigate to chat screen with the selected contact
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationId: 'new_${contact['id']}',
              participantId: contact['id'],
              participantName: contact['name'],
              participantPhoto: contact['avatar'],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'New Conversation',
                    style: AppTextStyle.headingTextStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Contacts list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColor.primary,
                      child: Text(
                        contact['name'][0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(contact['name']),
                    subtitle: Text(contact['phone']),
                    trailing: Icon(
                      contact['type'] == 'driver'
                          ? Icons.directions_car
                          : Icons.person,
                      color: AppColor.grey,
                    ),
                    onTap: () => _startConversation(contact),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
