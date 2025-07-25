import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/models/conversation_model.dart';
import 'package:sepesha_app/services/message_service.dart';
import 'package:sepesha_app/services/websocket_service.dart';

class MessageRepository {
  MessageRepository._();
  static final MessageRepository _instance = MessageRepository._();
  static MessageRepository get instance => _instance;

  final MessageService _messageService = MessageService.instance;
  final WebSocketService _webSocketService = WebSocketService();

  final Map<String, List<Message>> _messageCache = {};
  final Map<String, Conversation> _conversationCache = {};
  final List<String> _pendingMessages = [];

  final StreamController<List<Conversation>> _conversationsController =
      StreamController<List<Conversation>>.broadcast();
  final StreamController<List<Message>> _messagesController =
      StreamController<List<Message>>.broadcast();
  final StreamController<Message> _newMessageController =
      StreamController<Message>.broadcast();

  Stream<List<Conversation>> get conversationsStream =>
      _conversationsController.stream;
  Stream<List<Message>> get messagesStream => _messagesController.stream;
  Stream<Message> get newMessageStream => _newMessageController.stream;

  String? _currentConversationId;

  Future<void> initialize(String userId) async {
    debugPrint('=== INITIALIZING MESSAGE REPOSITORY ===');
    try {
      _webSocketService.connect(userId);
      _webSocketService.subscribeToMessages(userId);

      _webSocketService.messageStream.listen((message) {
        debugPrint('Incoming message received: ${message.message}');
        _handleIncomingMessage(message);
      });

      _webSocketService.typingStream.listen((typingIndicator) {
        debugPrint(
          'Typing indicator: ${typingIndicator.userId} is ${typingIndicator.isTyping ? 'typing' : 'not typing'}',
        );
        _handleTypingIndicator(typingIndicator);
      });

      _webSocketService.onlineStatusStream.listen((onlineStatus) {
        debugPrint(
          'Online status update: ${onlineStatus.userId} is ${onlineStatus.isOnline ? 'online' : 'offline'}',
        );
        _handleOnlineStatusUpdate(onlineStatus);
      });

      await _loadCachedData();
      debugPrint('MessageRepository initialized for user: $userId');
    } catch (e) {
      debugPrint('Error initializing MessageRepository: $e');
    }
  }

  Message? findMessageById(String messageId) {
    debugPrint('=== FINDING MESSAGE BY ID: $messageId ===');
    if (_currentConversationId == null) {
      debugPrint('No current conversation ID');
      return null;
    }

    for (final messages in _messageCache.values) {
      try {
        final message = messages.firstWhere((msg) => msg.id == messageId);
        debugPrint('Found message: $message');
        return message;
      } catch (e) {
        continue;
      }
    }
    debugPrint('Message not found');
    return null;
  }

  void removeFailedMessage(String messageId) {
    debugPrint('=== REMOVING FAILED MESSAGE: $messageId ===');
    for (final key in _messageCache.keys) {
      final messages = _messageCache[key] ?? [];
      _messageCache[key] =
          messages.where((msg) => msg.id != messageId).toList();
    }
    _pendingMessages.remove(messageId);
    debugPrint('Failed message removed');
  }

  String getMessageCacheKey(String conversationId, String participantId) {
    return _getMessageCacheKey(conversationId, participantId);
  }

  Future<List<Conversation>> getConversations({
    bool forceRefresh = false,
  }) async {
    debugPrint('=== GETTING CONVERSATIONS ===');
    try {
      List<Conversation> conversations;
      if (forceRefresh || _conversationCache.isEmpty) {
        conversations = await _messageService.getConversations();
        _conversationCache.clear();
        for (final conversation in conversations) {
          _conversationCache[conversation.id] = conversation;
        }
        await _saveCachedConversations(conversations);
        debugPrint('Fetched conversations from API');
      } else {
        conversations = _conversationCache.values.toList();
        debugPrint('Using cached conversations');
      }

      conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      _conversationsController.add(conversations);
      debugPrint('Conversations: $conversations');
      return conversations;
    } catch (e) {
      debugPrint('Error getting conversations: $e');
      final cachedConversations = _conversationCache.values.toList();
      _conversationsController.add(cachedConversations);
      return cachedConversations;
    }
  }

  Future<List<Message>> getConversationMessages({
    required String conversationId,
    required String participantId,
    String? bookingId,
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    debugPrint('=== GETTING CONVERSATION MESSAGES ===');
    try {
      _currentConversationId = conversationId;
      final cacheKey = _getMessageCacheKey(conversationId, participantId);
      List<Message> messages;

      if (forceRefresh || !_messageCache.containsKey(cacheKey)) {
        messages = await _messageService.getConversationMessages(
          participantId: participantId,
          bookingId: bookingId,
          limit: limit,
          offset: offset,
        );
        _messageCache[cacheKey] = messages;
        await _saveCachedMessages(cacheKey, messages);
        debugPrint('Fetched messages from API');
      } else {
        messages = _messageCache[cacheKey] ?? [];
        if (offset == 0) {
          try {
            final newMessages = await _messageService.getConversationMessages(
              participantId: participantId,
              bookingId: bookingId,
              limit: 10,
              offset: 0,
            );
            if (newMessages.isNotEmpty) {
              final mergedMessages = _mergeMessages(messages, newMessages);
              _messageCache[cacheKey] = mergedMessages;
              messages = mergedMessages;
              await _saveCachedMessages(cacheKey, messages);
              debugPrint('Fetched new messages from API');
            }
          } catch (e) {
            debugPrint('Error fetching new messages: $e');
          }
        }
      }

      messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _messagesController.add(messages);
      debugPrint('Messages: $messages');
      return messages;
    } catch (e) {
      debugPrint('Error getting conversation messages: $e');
      final cacheKey = _getMessageCacheKey(conversationId, participantId);
      final cachedMessages = _messageCache[cacheKey] ?? [];
      _messagesController.add(cachedMessages);
      return cachedMessages;
    }
  }

  Future<Message?> sendMessage({
    required String recipientId,
    required String message,
    String? conversationId,
    String? bookingId,
    MessageType messageType = MessageType.text,
    String? attachment,
  }) async {
    debugPrint('=== SENDING MESSAGE ===');
    try {
      final tempMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        senderId: await _getCurrentUserId() ?? '',
        recipientId: recipientId,
        bookingId: bookingId,
        message: message,
        messageType: messageType,
        attachment: attachment,
        isRead: false,
        createdAt: DateTime.now(),
      );

      _pendingMessages.add(tempMessage.id);

      if (conversationId != null) {
        final cacheKey = _getMessageCacheKey(conversationId, recipientId);
        final currentMessages = _messageCache[cacheKey] ?? [];
        currentMessages.insert(0, tempMessage);
        _messageCache[cacheKey] = currentMessages;
        _messagesController.add(currentMessages);
      }

      final sentMessage = await _messageService.sendMessage(
        recipientId: recipientId,
        message: message,
        bookingId: bookingId,
        messageType: messageType,
        attachment: attachment,
      );

      if (sentMessage != null) {
        _pendingMessages.remove(tempMessage.id);

        if (conversationId != null) {
          final cacheKey = _getMessageCacheKey(conversationId, recipientId);
          final currentMessages = _messageCache[cacheKey] ?? [];
          final tempIndex = currentMessages.indexWhere(
            (m) => m.id == tempMessage.id,
          );
          if (tempIndex != -1) {
            currentMessages[tempIndex] = sentMessage;
            _messageCache[cacheKey] = currentMessages;
            _messagesController.add(currentMessages);
          }
        }

        await _updateConversationLastMessage(recipientId, sentMessage);
        debugPrint('Message sent successfully');
        return sentMessage;
      } else {
        _pendingMessages.remove(tempMessage.id);
        if (conversationId != null) {
          final cacheKey = _getMessageCacheKey(conversationId, recipientId);
          final currentMessages = _messageCache[cacheKey] ?? [];
          currentMessages.removeWhere((m) => m.id == tempMessage.id);
          _messageCache[cacheKey] = currentMessages;
          _messagesController.add(currentMessages);
        }
        debugPrint('Failed to send message');
        throw Exception('Failed to send message');
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<bool> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    debugPrint('=== MARKING MESSAGES AS READ ===');
    try {
      final success = await _messageService.markMessagesAsRead(
        conversationId: conversationId,
        messageIds: messageIds,
      );

      if (success) {
        for (final cacheKey in _messageCache.keys) {
          final messages = _messageCache[cacheKey] ?? [];
          for (int i = 0; i < messages.length; i++) {
            if (messageIds.contains(messages[i].id)) {
              messages[i] = messages[i].copyWith(isRead: true);
            }
          }
          _messageCache[cacheKey] = messages;
        }

        for (final conversation in _conversationCache.values) {
          if (conversation.id == conversationId) {
            final updatedConversation = conversation.copyWith(
              unreadCount: conversation.unreadCount - messageIds.length,
            );
            _conversationCache[conversation.id] = updatedConversation;
          }
        }

        _refreshStreams();
        debugPrint('Messages marked as read');
      }
      return success;
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      return false;
    }
  }

  Future<List<Conversation>> searchConversations(String query) async {
    debugPrint('=== SEARCHING CONVERSATIONS ===');
    try {
      if (query.isEmpty) {
        return await getConversations();
      }

      final apiResults = await _messageService.searchConversations(query);
      final localResults =
          _conversationCache.values
              .where(
                (conversation) =>
                    conversation.participantName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    conversation.lastMessage?.message.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ==
                        true,
              )
              .toList();

      final allResults = <String, Conversation>{};
      for (final conversation in [...apiResults, ...localResults]) {
        allResults[conversation.id] = conversation;
      }

      final results = allResults.values.toList();
      results.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      debugPrint('Search results: $results');
      return results;
    } catch (e) {
      debugPrint('Error searching conversations: $e');
      return [];
    }
  }

  Future<int> getUnreadMessageCount() async {
    debugPrint('=== GETTING UNREAD MESSAGE COUNT ===');
    try {
      final apiCount = await _messageService.getUnreadMessageCount();
      if (apiCount == 0) {
        final localCount = _conversationCache.values.fold<int>(
          0,
          (sum, conversation) => sum + conversation.unreadCount,
        );
        debugPrint('Unread message count from cache: $localCount');
        return localCount;
      }
      debugPrint('Unread message count from API: $apiCount');
      return apiCount;
    } catch (e) {
      debugPrint('Error getting unread message count: $e');
      return _conversationCache.values.fold<int>(
        0,
        (sum, conversation) => sum + conversation.unreadCount,
      );
    }
  }

  void _handleIncomingMessage(Message message) {
    debugPrint('=== HANDLING INCOMING MESSAGE ===');
    try {
      _newMessageController.add(message);
      final conversationId = _findConversationId(message.senderId);
      if (conversationId != null) {
        final cacheKey = _getMessageCacheKey(conversationId, message.senderId);
        final currentMessages = _messageCache[cacheKey] ?? [];
        if (!currentMessages.any((m) => m.id == message.id)) {
          currentMessages.insert(0, message);
          _messageCache[cacheKey] = currentMessages;
          if (_currentConversationId == conversationId) {
            _messagesController.add(currentMessages);
          }
        }
      }
      _updateConversationLastMessage(message.senderId, message);
      debugPrint('Incoming message handled: ${message.message}');
    } catch (e) {
      debugPrint('Error handling incoming message: $e');
    }
  }

  void _handleTypingIndicator(TypingIndicator typingIndicator) {
    debugPrint(
      'User ${typingIndicator.userId} is ${typingIndicator.isTyping ? 'typing' : 'not typing'}',
    );
  }

  void _handleOnlineStatusUpdate(UserOnlineStatus onlineStatus) {
    debugPrint('=== HANDLING ONLINE STATUS UPDATE ===');
    try {
      for (final conversation in _conversationCache.values) {
        if (conversation.participantId == onlineStatus.userId) {
          final updatedConversation = conversation.copyWith(
            isOnline: onlineStatus.isOnline,
            lastActivity: onlineStatus.lastSeen,
          );
          _conversationCache[conversation.id] = updatedConversation;
        }
      }

      final conversations = _conversationCache.values.toList();
      conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      _conversationsController.add(conversations);
      debugPrint(
        'Updated online status for ${onlineStatus.userId}: ${onlineStatus.isOnline}',
      );
    } catch (e) {
      debugPrint('Error handling online status update: $e');
    }
  }

  String _getMessageCacheKey(String conversationId, String participantId) {
    return '${conversationId}_$participantId';
  }

  String? _findConversationId(String participantId) {
    for (final conversation in _conversationCache.values) {
      if (conversation.participantId == participantId) {
        return conversation.id;
      }
    }
    return null;
  }

  List<Message> _mergeMessages(
    List<Message> existing,
    List<Message> newMessages,
  ) {
    final merged = <String, Message>{};
    for (final message in existing) {
      merged[message.id] = message;
    }
    for (final message in newMessages) {
      merged[message.id] = message;
    }
    return merged.values.toList();
  }

  Future<void> _updateConversationLastMessage(
    String participantId,
    Message message,
  ) async {
    debugPrint('=== UPDATING CONVERSATION LAST MESSAGE ===');
    try {
      for (final conversation in _conversationCache.values) {
        if (conversation.participantId == participantId) {
          final updatedConversation = conversation.copyWith(
            lastMessage: message,
            lastActivity: message.createdAt,
            unreadCount: conversation.unreadCount + (message.isRead ? 0 : 1),
          );
          _conversationCache[conversation.id] = updatedConversation;
          break;
        }
      }

      final conversations = _conversationCache.values.toList();
      conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      _conversationsController.add(conversations);
      debugPrint('Conversation last message updated');
    } catch (e) {
      debugPrint('Error updating conversation last message: $e');
    }
  }

  void _refreshStreams() {
    debugPrint('=== REFRESHING STREAMS ===');
    final conversations = _conversationCache.values.toList();
    conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    _conversationsController.add(conversations);

    if (_currentConversationId != null) {
      for (final cacheKey in _messageCache.keys) {
        if (cacheKey.startsWith(_currentConversationId!)) {
          final messages = _messageCache[cacheKey] ?? [];
          _messagesController.add(messages);
          break;
        }
      }
    }
    debugPrint('Streams refreshed');
  }

  Future<String?> _getCurrentUserId() async {
    debugPrint('=== GETTING CURRENT USER ID ===');
    return 'current_user_id';
  }

  Future<void> _loadCachedData() async {
    debugPrint('=== LOADING CACHED DATA ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getString('cached_conversations');
      if (conversationsJson != null) {
        final List<dynamic> conversationsList = jsonDecode(conversationsJson);
        for (final conversationJson in conversationsList) {
          final conversation = Conversation.fromJson(conversationJson);
          _conversationCache[conversation.id] = conversation;
        }
      }

      final messageKeys = prefs.getKeys().where(
        (key) => key.startsWith('cached_messages_'),
      );
      for (final key in messageKeys) {
        final messagesJson = prefs.getString(key);
        if (messagesJson != null) {
          final List<dynamic> messagesList = jsonDecode(messagesJson);
          final messages =
              messagesList.map((json) => Message.fromJson(json)).toList();
          final cacheKey = key.replaceFirst('cached_messages_', '');
          _messageCache[cacheKey] = messages;
        }
      }
      debugPrint(
        'Loaded cached data: ${_conversationCache.length} conversations, ${_messageCache.length} message groups',
      );
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  Future<void> _saveCachedConversations(
    List<Conversation> conversations,
  ) async {
    debugPrint('=== SAVING CACHED CONVERSATIONS ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = jsonEncode(
        conversations.map((c) => c.toJson()).toList(),
      );
      await prefs.setString('cached_conversations', conversationsJson);
      debugPrint('Saved cached conversations');
    } catch (e) {
      debugPrint('Error saving cached conversations: $e');
    }
  }

  Future<void> _saveCachedMessages(
    String cacheKey,
    List<Message> messages,
  ) async {
    debugPrint('=== SAVING CACHED MESSAGES ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString('cached_messages_$cacheKey', messagesJson);
      debugPrint('Saved cached messages for key: $cacheKey');
    } catch (e) {
      debugPrint('Error saving cached messages: $e');
    }
  }

  void dispose() {
    debugPrint('=== DISPOSING MESSAGE REPOSITORY ===');
    _conversationsController.close();
    _messagesController.close();
    _newMessageController.close();
    _webSocketService.dispose();
    _messageCache.clear();
    _conversationCache.clear();
    _pendingMessages.clear();
    debugPrint('MessageRepository disposed');
  }
}
