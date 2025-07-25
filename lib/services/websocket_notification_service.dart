// lib/services/websocket_notification_service.dart
import 'package:sepesha_app/services/firebase_service.dart';

class WebSocketNotificationService {
  static void handleWebSocketEvent(Map<String, dynamic> event) {
    switch (event['event']) {
      case 'message-sent':
        _triggerMessageNotification(event['data']);
        break;
      case 'booking-status-updated':
        _triggerBookingNotification(event['data']);
        break;
      case 'location-updated':
        _triggerLocationNotification(event['data']);
        break;
    }
  }

  static void _triggerMessageNotification(Map<String, dynamic> data) {
    FirebaseService.showCustomNotification(
      title: 'New Message',
      body: data['message'] ?? 'You have a new message',
      data: {'type': 'message', 'booking_id': data['booking_id']},
    );
  }

  static void _triggerBookingNotification(Map<String, dynamic> data) {
    String status = data['status'] ?? 'updated';
    FirebaseService.showCustomNotification(
      title: 'Booking Update',
      body: 'Your ride has been $status',
      data: {'type': 'booking', 'booking_id': data['booking_id']},
    );
  }

  static void _triggerLocationNotification(Map<String, dynamic> data) {
    // Only show location notifications for important updates
    if (data['booking_id'] != null) {
      FirebaseService.showCustomNotification(
        title: 'Driver Location Update',
        body: 'Your driver is on the way',
        data: {'type': 'location', 'booking_id': data['booking_id']},
      );
    }
  }
}