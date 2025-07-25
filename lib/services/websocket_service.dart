import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/location_update.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sepesha_app/models/location_update.dart';
import 'package:sepesha_app/models/message_model.dart';

class WebSocketService {
  // This will hold our connection
  WebSocketChannel? _channel;

  Stream<LocationUpdate> get locationUpdateStream => _locationController.stream;
final StreamController<LocationUpdate> _locationController = StreamController<LocationUpdate>.broadcast();

  // Connection state tracking
  ConnectionState _connectionState = ConnectionState.disconnected;

  // This will tell us if we're connected
  bool get isConnected => _channel != null;

  void sendLocationUpdate({
  required String userId,
  required double latitude,
  required double longitude,
  String? bookingId,
  double? accuracy,
  double? speed,
  double? heading,
  double? altitude,
}) {
  if (_channel != null) {
    _sendMessage({
      'event': 'location-update',
      'data': {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy ?? 10.0,
        'speed': speed ?? 0.0,
        'heading': heading ?? 0.0,
        'altitude': altitude ?? 0.0,
        if (bookingId != null) 'booking_id': bookingId,
        'timestamp': DateTime.now().toIso8601String(),
      }
    });
  }
}

  // This function connects to the server
  void connect(String userId) {
    // Get WebSocket URL from environment variables
    final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
    final wsUrl = Uri.parse(
      '${baseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '')}/ws?user_id=$userId',
    );

    try {
      // Create the connection
      _channel = WebSocketChannel.connect(wsUrl);

      // Listen for messages from the server
      _channel!.stream.listen(
        (message) {
          // When we get a message, decode it from JSON
          final data = jsonDecode(message);
          if (kDebugMode) {
            print('Received WebSocket message: $data');
          }

          // Handle different types of messages
          switch (data['event']) {
            case 'location-updated': // Match documented event name
              _handleLocationUpdate(data['data']);
              break;
            case 'message-sent': // This matches the docs
              _handleMessageSent(data['data']);
              break;
            case 'message.sent': // Keep for backward compatibility
              _handleNewMessage(data['data']);
              break;
            case 'user-typing':
              _handleTypingIndicator(data['data']);
              break;
            case 'user-online-status':
              _handleOnlineStatus(data['data']);
              break;
            case 'booking-status-updated': // Match documented event name
              _handleRideStatusChange(data['data']);
              break;
            default:
              if (kDebugMode) {
                print('Unknown WebSocket event: ${data['event']}');
              }
              break;
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          disconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _channel = null;
        },
      );

      // Subscribe to channels we're interested in
      _subscribeToChannels(userId);

      print('WebSocket connected successfully!');
    } catch (e) {
      print('Failed to connect to WebSocket: $e');
      _channel = null;
    }
  }

  // This function disconnects from the server
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
    print('WebSocket disconnected');
  }

  void subscribeToBooking(String bookingId) {
  if (_channel != null) {
    _sendMessage({
      'event': 'pusher:subscribe',
      'data': {'channel': 'booking.$bookingId'},
    });
  }
}

  // ==================== MESSAGING FUNCTIONALITY ====================

  /// Stream for receiving real-time messages
  Stream<Message> get messageStream => _messageController.stream;
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();

  /// Stream for typing indicators
  Stream<TypingIndicator> get typingStream => _typingController.stream;
  final StreamController<TypingIndicator> _typingController =
      StreamController<TypingIndicator>.broadcast();

  /// Stream for online status updates
  Stream<UserOnlineStatus> get onlineStatusStream =>
      _onlineStatusController.stream;
  final StreamController<UserOnlineStatus> _onlineStatusController =
      StreamController<UserOnlineStatus>.broadcast();

  /// Subscribe to message events for current user
  void subscribeToMessages(String userId) {
    if (_channel != null) {
      try {
        // Subscribe to user-specific channel for messages
        _sendMessage({
          'event': 'pusher:subscribe',
          'data': {'channel': 'user.$userId'},
        });

        if (kDebugMode) {
          print('Subscribed to messages for user: $userId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error subscribing to messages: $e');
        }
      }
    }
  }

  /// Send typing indicator
  void sendTypingIndicator({
    required String recipientId,
    required bool isTyping,
    String? conversationId,
  }) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-typing',
          'data': {
            'recipient_id': recipientId,
            'is_typing': isTyping,
            'conversation_id': conversationId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Sent typing indicator: $isTyping to $recipientId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending typing indicator: $e');
        }
      }
    }
  }

  /// Send message delivery confirmation
  void confirmMessageDelivery(String messageId) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-message-delivered',
          'data': {
            'message_id': messageId,
            'delivered_at': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Confirmed delivery for message: $messageId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error confirming message delivery: $e');
        }
      }
    }
  }

  /// Send message read confirmation
  void confirmMessageRead(String messageId) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-message-read',
          'data': {
            'message_id': messageId,
            'read_at': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Confirmed read for message: $messageId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error confirming message read: $e');
        }
      }
    }
  }

  /// Update user online status
  void updateOnlineStatus(bool isOnline) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-online-status',
          'data': {
            'is_online': isOnline,
            'last_seen': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Updated online status: $isOnline');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error updating online status: $e');
        }
      }
    }
  }

  /// Join a conversation room for real-time updates
  void joinConversation(String conversationId) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-join-conversation',
          'data': {
            'conversation_id': conversationId,
            'joined_at': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Joined conversation: $conversationId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error joining conversation: $e');
        }
      }
    }
  }

  /// Leave a conversation room
  void leaveConversation(String conversationId) {
    if (_channel != null) {
      try {
        _sendMessage({
          'event': 'client-leave-conversation',
          'data': {
            'conversation_id': conversationId,
            'left_at': DateTime.now().toIso8601String(),
          },
        });

        if (kDebugMode) {
          print('Left conversation: $conversationId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error leaving conversation: $e');
        }
      }
    }
  }

  /// Check if WebSocket is connected and ready for messaging
  bool get isReadyForMessaging =>
      _channel != null && _connectionState == ConnectionState.connected;

  /// Get current connection status
  ConnectionState get connectionState => _connectionState;

  /// Dispose messaging resources
  void disposeMessaging() {
    _messageController.close();
    _typingController.close();
    _onlineStatusController.close();
  }

  /// Dispose all resources
  void dispose() {
    disposeMessaging();
    disconnect();
  }

  // This function subscribes to channels
  void _subscribeToChannels(String userId) {
    // Subscribe to general location channel
    _sendMessage({
      'event': 'pusher:subscribe',
      'data': {'channel': 'location'},
    });

    // Subscribe to user-specific location channel
    _sendMessage({
      'event': 'pusher:subscribe',
      'data': {'channel': 'user-location.$userId'},
    });

    // If user is a driver, subscribe to driver channel
    // You would need to know if the user is a driver
    _sendMessage({
      'event': 'pusher:subscribe',
      'data': {'channel': 'driver-location'},
    });
  }

  // This function sends a message to the server
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // Handle location updates
  void _handleLocationUpdate(Map<String, dynamic> data) {
  try {
    final locationUpdate = LocationUpdate.fromJson(data);
    _locationController.add(locationUpdate);
    
    if (kDebugMode) {
      print('Location update received: ${locationUpdate.latitude}, ${locationUpdate.longitude}');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing location update: $e');
    }
  }
}

  // Handle message-sent events (real-time messaging)
  void _handleMessageSent(Map<String, dynamic> data) {
    try {
      if (data != null) {
        final message = Message.fromJson(data);
        _messageController.add(message);

        if (kDebugMode) {
          print(
            'Received real-time message: ${message.message} from ${message.senderId}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing real-time message: $e');
      }
    }
  }

  // Handle typing indicators
  void _handleTypingIndicator(Map<String, dynamic> data) {
    try {
      if (data != null) {
        final typingIndicator = TypingIndicator.fromJson(data);
        _typingController.add(typingIndicator);

        if (kDebugMode) {
          print(
            'Received typing indicator: ${typingIndicator.isTyping} from ${typingIndicator.userId}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing typing indicator: $e');
      }
    }
  }

  // Handle online status updates
  void _handleOnlineStatus(Map<String, dynamic> data) {
    try {
      if (data != null) {
        final onlineStatus = UserOnlineStatus.fromJson(data);
        _onlineStatusController.add(onlineStatus);

        if (kDebugMode) {
          print(
            'Received online status: ${onlineStatus.isOnline} for ${onlineStatus.userId}',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing online status: $e');
      }
    }
  }

  // Handle new messages (legacy support)
  void _handleNewMessage(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('New message (legacy): $data');
    }

    // The data will look like this:
    // {
    //   "message": {
    //     "id": "message_id_here",
    //     "sender_id": "auth_key_here",
    //     "recipient_id": "auth_key_here",
    //     "booking_id": "booking_id_here",
    //     "message": "Hello, what's your ETA?",
    //     "attachment": null,
    //     "message_type": "text",
    //     "created_at": "2023-06-15T12:00:00Z"
    //   },
    //   "sender": {
    //     "id": "auth_key_here",
    //     "name": "John Doe",
    //     "user_type": "driver",
    //     "profile_photo": "url_to_photo"
    //   },
    //   "recipient": {
    //     "id": "auth_key_here",
    //     "name": "Jane Smith",
    //     "user_type": "customer",
    //     "profile_photo": "url_to_photo"
    //   },
    //   "bookingId": "booking_id_here",
    //   "timestamp": "2023-06-15T12:00:00Z"
    // }

    // Example: If you're using a callback
    if (onMessageReceived != null) {
      onMessageReceived!(
        data['message']['id'],
        data['sender']['id'],
        data['message']['message'],
        data['message']['message_type'],
        data['message']['attachment'],
        data['sender']['name'],
        data['timestamp'],
      );
    }
  }

  // Handle ride status changes
  void _handleRideStatusChange(Map<String, dynamic> data) {
    print('Ride status changed: $data');

    // Example: If you're using a callback
    if (onRideStatusChanged != null) {
      onRideStatusChanged!(data['bookingId'], data['status']);
    }
  }

  // Callbacks that other parts of the app can set
  Function(
    String userId,
    double latitude,
    double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    String? bookingId,
    String? userName,
  )?
  onLocationUpdated;

  Function(
    String messageId,
    String senderId,
    String message,
    String messageType,
    String? attachment,
    String senderName,
    String timestamp,
  )?
  onMessageReceived;

  Function(String bookingId, String status)? onRideStatusChanged;

  // Send a message to another user
  Future<void> sendMessage(
    String senderId,
    String recipientId,
    String message, {
    String? bookingId,
    String messageType = 'text',
    String? attachment,
  }) async {
    // Again, we'll use HTTP for sending
    try {
      final api = dotenv.env['BASE_URL'];
      final response = await http.post(
        Uri.parse('$api/send-message'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'sender_id': senderId,
          'recipient_id': recipientId,
          'message': message,
          'booking_id': bookingId,
          'message_type': messageType,
          'attachment': attachment,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Message send response: $data');
        // The response will look like this:
        // {
        //   "status": true,
        //   "message": "Message sent successfully",
        //   "data": {
        //     "id": "message_id_here",
        //     "sender_id": "auth_key_here",
        //     "recipient_id": "auth_key_here",
        //     "booking_id": "booking_id_here",
        //     "message": "Hello, what's your ETA?",
        //     "message_type": "text",
        //     "attachment": null,
        //     "created_at": "2023-06-15T12:00:00Z",
        //     "updated_at": "2023-06-15T12:00:00Z"
        //   }
        // }
      } else {
        print('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }

    print('Sent message: $message');
  }
}

// Supporting classes for messaging
class TypingIndicator {
  final String userId;
  final String recipientId;
  final bool isTyping;
  final String? conversationId;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.recipientId,
    required this.isTyping,
    this.conversationId,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['user_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      isTyping: json['is_typing'] as bool? ?? false,
      conversationId: json['conversation_id'] as String?,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'recipient_id': recipientId,
      'is_typing': isTyping,
      if (conversationId != null) 'conversation_id': conversationId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class UserOnlineStatus {
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;

  UserOnlineStatus({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
  });

  factory UserOnlineStatus.fromJson(Map<String, dynamic> json) {
    return UserOnlineStatus(
      userId: json['user_id'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
      lastSeen:
          DateTime.tryParse(json['last_seen'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
    };
  }
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}
