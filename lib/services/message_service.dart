import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/models/conversation_model.dart';
import 'package:sepesha_app/services/preferences.dart';

class MessageService {
  MessageService._();
  static final MessageService _instance = MessageService._();
  static MessageService get instance => _instance;

  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  /// Send a message to another user
  Future<Message?> sendMessage({
    required String recipientId,
    required String message,
    String? bookingId,
    MessageType messageType = MessageType.text,
    String? attachment,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final senderId = await _getCurrentUserId();

      if (token == null || senderId == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/send-message');

      final requestBody = {
        'sender_id': senderId,
        'recipient_id': recipientId,
        'message': message,
        if (bookingId != null) 'booking_id': bookingId,
        'message_type': messageType.name,
        if (attachment != null) 'attachment': attachment,
      };

      if (kDebugMode) {
        print('=== SEND MESSAGE REQUEST ===');
        print('URL: ${url.toString()}');
        print(
          'Headers: {Content-Type: application/json, Authorization: Bearer ${token.substring(0, 20)}..., Accept: application/json}',
        );
        print('Body: ${jsonEncode(requestBody)}');
        print('===========================');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print('=== SEND MESSAGE RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');
        print('============================');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return Message.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send message');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to send message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }

  /// Get messages for a conversation
  Future<List<Message>> getConversationMessages({
    required String participantId,
    String? bookingId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final currentUserId = await _getCurrentUserId();

      if (token == null || currentUserId == null) {
        throw Exception('Authentication required');
      }

      // Build query parameters
      final queryParams = <String, String>{
        'sender_id': currentUserId,
        'recipient_id': participantId,
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (bookingId != null) {
        queryParams['booking_id'] = bookingId;
      }

      final uri = Uri.parse(
        '$apiBaseUrl/messages',
      ).replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('=== GET CONVERSATION MESSAGES REQUEST ===');
        print('URL: ${uri.toString()}');
        print(
          'Headers: {Content-Type: application/json, Authorization: Bearer ${token.substring(0, 20)}..., Accept: application/json}',
        );
        print('Query Params: $queryParams');
        print('========================================');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('=== GET CONVERSATION MESSAGES RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');
        print('=========================================');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> messagesJson = data['data'];
          return messagesJson.map((json) => Message.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get messages');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get messages');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting conversation messages: $e');
      }
      rethrow;
    }
  }

  /// Get all conversations for current user
  Future<List<Conversation>> getConversations() async {
    try {
      final token = await Preferences.instance.apiToken;
      final currentUserId = await _getCurrentUserId();

      if (token == null || currentUserId == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/conversations');

      if (kDebugMode) {
        print('=== GET CONVERSATIONS REQUEST ===');
        print('URL: ${url.toString()}');
        print(
          'Headers: {Content-Type: application/json, Authorization: Bearer ${token.substring(0, 20)}..., Accept: application/json}',
        );
        print('Current User ID: $currentUserId');
        print('================================');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('=== GET CONVERSATIONS RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Headers: ${response.headers}');
        print('Response Body: ${response.body}');
        print('=================================');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> conversationsJson = data['data'];
          return conversationsJson
              .map((json) => Conversation.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get conversations');
        }
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to get conversations',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting conversations: $e');
      }
      rethrow;
    }
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/messages/mark-read');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conversation_id': conversationId,
          'message_ids': messageIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: Failed to mark messages as read',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking messages as read: $e');
      }
      return false;
    }
  }

  /// Get unread message count
  Future<int> getUnreadMessageCount() async {
    try {
      final token = await Preferences.instance.apiToken;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/messages/unread-count');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data']['unread_count'] as int? ?? 0;
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread message count: $e');
      }
      return 0;
    }
  }

  /// Search conversations
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      final token = await Preferences.instance.apiToken;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse(
        '$apiBaseUrl/conversations/search',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> conversationsJson = data['data'];
          return conversationsJson
              .map((json) => Conversation.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error searching conversations: $e');
      }
      return [];
    }
  }

  /// Create a new conversation
  Future<Conversation?> createConversation({
    required String participantId,
    String? bookingId,
    ConversationType type = ConversationType.general,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final currentUserId = await _getCurrentUserId();

      if (token == null || currentUserId == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/conversations');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'participant_id': participantId,
          if (bookingId != null) 'booking_id': bookingId,
          'type': type.name,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return Conversation.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating conversation: $e');
      }
      return null;
    }
  }

  /// Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      final token = await Preferences.instance.apiToken;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/conversations/$conversationId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting conversation: $e');
      }
      return false;
    }
  }

  /// Get current user ID from preferences/session
  Future<String?> _getCurrentUserId() async {
    try {
      // Use auth key (uid) from preferences as the primary user ID
      final authKey = await Preferences.instance.authKey;
      if (authKey != null && authKey.isNotEmpty) {
        return authKey;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user ID: $e');
      }
      return null;
    }
  }

  /// Upload attachment (image, file, etc.)
  Future<String?> uploadAttachment({
    required String filePath,
    required String fileName,
    String fileType = 'image',
  }) async {
    try {
      final token = await Preferences.instance.apiToken;

      if (token == null) {
        throw Exception('Authentication required');
      }

      final url = Uri.parse('$apiBaseUrl/messages/upload-attachment');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('attachment', filePath),
      );

      request.fields['file_type'] = fileType;
      request.fields['file_name'] = fileName;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          return data['data']['file_url'] as String?;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading attachment: $e');
      }
      return null;
    }
  }
}
