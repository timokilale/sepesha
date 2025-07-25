import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/models/conversation_model.dart';
import 'package:sepesha_app/repositories/message_repository.dart';
import 'package:sepesha_app/services/websocket_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _messageRepository = MessageRepository.instance;
  final WebSocketService _webSocketService = WebSocketService();

  // State variables
  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  String? _currentConversationId;
  String? _currentParticipantId;
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSendingMessage = false;
  String? _error;
  int _unreadCount = 0;

  // Typing indicators
  final Map<String, bool> _typingUsers = {};
  final Map<String, Timer> _typingTimers = {};

  // Online status
  final Map<String, bool> _onlineUsers = {};

  // Search
  List<Conversation> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  String? get currentConversationId => _currentConversationId;
  String? get currentParticipantId => _currentParticipantId;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSendingMessage => _isSendingMessage;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  Map<String, bool> get typingUsers => _typingUsers;
  Map<String, bool> get onlineUsers => _onlineUsers;
  List<Conversation> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  // Stream subscriptions
  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<TypingIndicator>? _typingSubscription;
  StreamSubscription<UserOnlineStatus>? _onlineStatusSubscription;

  /// Initialize the provider
  Future<void> initialize(String userId) async {
    try {
      _setError(null);

      // Initialize repository
      await _messageRepository.initialize(userId);

      // Set up stream listeners
      _setupStreamListeners();

      // Load initial data
      await loadConversations();
      await _updateUnreadCount();

      if (kDebugMode) {
        print('MessageProvider initialized for user: $userId');
      }
    } catch (e) {
      _setError('Failed to initialize messaging: $e');
      if (kDebugMode) {
        print('Error initializing MessageProvider: $e');
      }
    }
  }

  /// Set up stream listeners for real-time updates
  void _setupStreamListeners() {
    // Listen to conversations updates
    _conversationsSubscription = _messageRepository.conversationsStream.listen(
      (conversations) {
        _conversations = conversations;
        _isLoadingConversations = false;
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading conversations: $error');
      },
    );

    // Listen to messages updates
    _messagesSubscription = _messageRepository.messagesStream.listen(
      (messages) {
        _currentMessages = messages;
        _isLoadingMessages = false;
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading messages: $error');
      },
    );

    // Listen to new messages
    _newMessageSubscription = _messageRepository.newMessageStream.listen(
      (message) {
        _handleNewMessage(message);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error receiving new message: $error');
        }
      },
    );

    // Listen to typing indicators
    _typingSubscription = _webSocketService.typingStream.listen(
      (typingIndicator) {
        _handleTypingIndicator(typingIndicator);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error receiving typing indicator: $error');
        }
      },
    );

    // Listen to online status updates
    _onlineStatusSubscription = _webSocketService.onlineStatusStream.listen(
      (onlineStatus) {
        _handleOnlineStatusUpdate(onlineStatus);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Error receiving online status: $error');
        }
      },
    );
  }

  /// Load conversations
  Future<void> loadConversations({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _conversations.isNotEmpty) return;

      _isLoadingConversations = true;
      _setError(null);
      notifyListeners();

      await _messageRepository.getConversations(forceRefresh: forceRefresh);
      await _updateUnreadCount();
    } catch (e) {
      _setError('Failed to load conversations: $e');
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages({
    required String conversationId,
    required String participantId,
    String? bookingId,
    bool forceRefresh = false,
  }) async {
    try {
      _currentConversationId = conversationId;
      _currentParticipantId = participantId;
      _isLoadingMessages = true;
      _setError(null);
      notifyListeners();

      // Join conversation for real-time updates
      _webSocketService.joinConversation(conversationId);

      await _messageRepository.getConversationMessages(
        conversationId: conversationId,
        participantId: participantId,
        bookingId: bookingId,
        forceRefresh: forceRefresh,
      );

      // Mark messages as read
      await _markCurrentMessagesAsRead();
    } catch (e) {
      _setError('Failed to load messages: $e');
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String recipientId,
    required String message,
    String? bookingId,
    MessageType messageType = MessageType.text,
    String? attachment,
  }) async {
    try {
      if (message.trim().isEmpty && attachment == null) {
        _setError('Message cannot be empty');
        return false;
      }

      _isSendingMessage = true;
      _setError(null);
      notifyListeners();

      final sentMessage = await _messageRepository.sendMessage(
        recipientId: recipientId,
        message: message.trim(),
        conversationId: _currentConversationId,
        bookingId: bookingId,
        messageType: messageType,
        attachment: attachment,
      );

      _isSendingMessage = false;
      notifyListeners();

      if (sentMessage != null) {
        // Update unread count
        await _updateUnreadCount();
        return true;
      } else {
        _setError('Failed to send message');
        return false;
      }
    } catch (e) {
      _isSendingMessage = false;
      _setError('Failed to send message: $e');
      notifyListeners();
      return false;
    }
  }

  /// Retry sending a failed message
  Future<bool> retryMessage(String messageId) async {
    try {
      final failedMessage = _messageRepository.findMessageById(messageId);
      if (failedMessage == null) {
        _setError('Message not found');
        return false;
      }

      _isSendingMessage = true;
      notifyListeners();

      final sentMessage = await _messageRepository.sendMessage(
        recipientId: failedMessage.recipientId,
        message: failedMessage.message,
        conversationId: _currentConversationId,
        bookingId: failedMessage.bookingId,
        messageType: failedMessage.messageType,
        attachment: failedMessage.attachment,
      );

      _isSendingMessage = false;

      if (sentMessage != null) {
        // Remove the failed message and add the new one
        _messageRepository.removeFailedMessage(messageId);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to send message');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isSendingMessage = false;
      _setError('Failed to retry message: $e');
      notifyListeners();
      return false;
    }
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String recipientId,
    required bool isTyping,
  }) {
    try {
      _webSocketService.sendTypingIndicator(
        recipientId: recipientId,
        isTyping: isTyping,
        conversationId: _currentConversationId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending typing indicator: $e');
      }
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    try {
      await _messageRepository.markMessagesAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );

      // Update unread count
      await _updateUnreadCount();
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
    }
  }

  /// Search conversations
  Future<void> searchConversations(String query) async {
    try {
      _searchQuery = query;
      _isSearching = true;
      notifyListeners();

      if (query.trim().isEmpty) {
        _searchResults = [];
        _isSearching = false;
        notifyListeners();
        return;
      }

      final results = await _messageRepository.searchConversations(
        query.trim(),
      );
      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to search conversations: $e');
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  /// Leave current conversation
  void leaveCurrentConversation() {
    if (_currentConversationId != null) {
      _webSocketService.leaveConversation(_currentConversationId!);
      _currentConversationId = null;
      _currentParticipantId = null;
      _currentMessages = [];
      notifyListeners();
    }
  }

  /// Get conversation by participant ID
  Conversation? getConversationByParticipant(String participantId) {
    try {
      return _conversations.firstWhere(
        (conversation) => conversation.participantId == participantId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user is typing
  bool isUserTyping(String userId) {
    return _typingUsers[userId] ?? false;
  }

  /// Check if user is online
  bool isUserOnline(String userId) {
    return _onlineUsers[userId] ?? false;
  }

  /// Get unread count for specific conversation
  int getConversationUnreadCount(String conversationId) {
    try {
      final conversation = _conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
      return conversation.unreadCount;
    } catch (e) {
      return 0;
    }
  }

  /// Handle new incoming message
  void _handleNewMessage(Message message) {
    try {
      // Update unread count if message is not from current user
      if (message.senderId != _getCurrentUserId()) {
        _updateUnreadCount();
      }

      // Show notification or update UI as needed
      if (kDebugMode) {
        print('New message received: ${message.message}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling new message: $e');
      }
    }
  }

  /// Handle typing indicator
  void _handleTypingIndicator(TypingIndicator typingIndicator) {
    try {
      final userId = typingIndicator.userId;

      // Update typing status
      _typingUsers[userId] = typingIndicator.isTyping;

      // Clear existing timer
      _typingTimers[userId]?.cancel();

      if (typingIndicator.isTyping) {
        // Set timer to clear typing status after 3 seconds
        _typingTimers[userId] = Timer(const Duration(seconds: 3), () {
          _typingUsers[userId] = false;
          notifyListeners();
        });
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling typing indicator: $e');
      }
    }
  }

  /// Handle online status update
  void _handleOnlineStatusUpdate(UserOnlineStatus onlineStatus) {
    try {
      _onlineUsers[onlineStatus.userId] = onlineStatus.isOnline;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling online status update: $e');
      }
    }
  }

  /// Mark current messages as read
  Future<void> _markCurrentMessagesAsRead() async {
    try {
      if (_currentConversationId == null) return;

      final unreadMessages =
          _currentMessages
              .where(
                (message) =>
                    !message.isRead && message.senderId != _getCurrentUserId(),
              )
              .map((message) => message.id)
              .toList();

      if (unreadMessages.isNotEmpty) {
        await markMessagesAsRead(
          conversationId: _currentConversationId!,
          messageIds: unreadMessages,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking current messages as read: $e');
      }
    }
  }

  /// Update unread count
  Future<void> _updateUnreadCount() async {
    try {
      final count = await _messageRepository.getUnreadMessageCount();
      _unreadCount = count;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating unread count: $e');
      }
    }
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    if (error != null) {
      if (kDebugMode) {
        print('MessageProvider error: $error');
      }
    }
  }

  /// Get current user ID (placeholder - implement based on your auth system)
  String? _getCurrentUserId() {
    // This should match your authentication system
    return 'current_user_id'; // Placeholder
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadConversations(forceRefresh: true);
    if (_currentConversationId != null && _currentParticipantId != null) {
      await loadMessages(
        conversationId: _currentConversationId!,
        participantId: _currentParticipantId!,
        forceRefresh: true,
      );
    }
  }

  /// Clear error
  void clearError() {
    _setError(null);
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancel stream subscriptions
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _newMessageSubscription?.cancel();
    _typingSubscription?.cancel();
    _onlineStatusSubscription?.cancel();

    // Cancel typing timers
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }

    // Leave current conversation
    leaveCurrentConversation();

    // Dispose repository
    _messageRepository.dispose();

    super.dispose();
  }
}
