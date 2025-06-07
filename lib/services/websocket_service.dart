import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  // This will hold our connection
  WebSocketChannel? _channel;

  // This will tell us if we're connected
  bool get isConnected => _channel != null;

  // This function connects to the server
  void connect(String userId) {
    // The URL of our WebSocket server - replace with your actual server address
    // For local testing, use your computer's IP address instead of 'localhost'
    final wsUrl = Uri.parse(
      'ws://127.0.0.1:6001/app/local?protocol=7&client=dart',
    );

    try {
      // Create the connection
      _channel = WebSocketChannel.connect(wsUrl);

      // Listen for messages from the server
      _channel!.stream.listen(
        (message) {
          // When we get a message, decode it from JSON
          final data = jsonDecode(message);
          print('Received message: $data');

          // Handle different types of messages
          if (data['event'] == 'location.updated') {
            _handleLocationUpdate(data['data']);
          } else if (data['event'] == 'message.sent') {
            _handleNewMessage(data['data']);
          } else if (data['event'] == 'ride.statusChanged') {
            _handleRideStatusChange(data['data']);
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
    // You can create a callback or use a state management solution
    // to update your app's UI with this location data
    print('Location updated: $data');

    // The data will look like this:
    // {
    //   "userId": "auth_key_here",
    //   "userType": "driver",
    //   "latitude": 37.7749,
    //   "longitude": -122.4194,
    //   "accuracy": 10.5,
    //   "speed": 5.2,
    //   "heading": 90.0,
    //   "altitude": 50.0,
    //   "bookingId": "booking_id_here",
    //   "timestamp": "2023-06-15T12:00:00Z",
    //   "userName": "John Doe"
    // }

    // Example: If you're using a callback
    if (onLocationUpdated != null) {
      onLocationUpdated!(
        data['userId'],
        data['latitude'],
        data['longitude'],
        data['accuracy'],
        data['speed'],
        data['heading'],
        data['altitude'],
        data['bookingId'],
        data['userName'],
      );
    }
  }

  // Handle new messages
  void _handleNewMessage(Map<String, dynamic> data) {
    print('New message: $data');

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

  // Send your location to the server
  Future<void> sendLocationUpdate(
    String userId,
    double latitude,
    double longitude, {
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    String? bookingId,
  }) async {
    // We'll use regular HTTP for this, not WebSocket
    // This is because our server expects this data via a REST API

    // Implement using the http package
    final api = dotenv.env['BASE_URL'];
    try {
      final response = await http.post(
        Uri.parse('$api/update-location'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'speed': speed,
          'heading': heading,
          'altitude': altitude,
          'booking_id': bookingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Location update response: $data');
        // The response will look like this:
        // {
        //   "status": true,
        //   "message": "Location broadcasted successfully"
        // }
      } else {
        print('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location update: $e');
    }

    print('Sent location update: $latitude, $longitude');
  }

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
