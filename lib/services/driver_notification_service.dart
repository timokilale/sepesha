// lib/Driver/services/driver_notification_service.dart
import 'package:sepesha_app/services/firebase_service.dart';

class DriverNotificationService {
  static void handleDriverEvents(Map<String, dynamic> event) {
    switch (event['event']) {
      case 'new-booking-request':
        _showBookingRequest(event['data']);
        break;
      case 'booking-cancelled':
        _showBookingCancellation(event['data']);
        break;
      case 'customer-message':
        _showCustomerMessage(event['data']);
        break;
    }
  }

  static void _showBookingRequest(Map<String, dynamic> data) {
    FirebaseService.showCustomNotification(
      title: '🚗 New Ride Request',
      body: 'From ${data['pickup_location']} to ${data['delivery_location']}',
      data: {'type': 'booking_request', 'booking_id': data['booking_id']},
      actions: ['accept', 'decline'], // Simplified for now
    );
  }

  static void _showBookingCancellation(Map<String, dynamic> data) {
    FirebaseService.showCustomNotification(
      title: '❌ Booking Cancelled',
      body: 'A booking has been cancelled',
      data: {'type': 'booking_cancelled', 'booking_id': data['booking_id']},
    );
  }

  static void _showCustomerMessage(Map<String, dynamic> data) {
    FirebaseService.showCustomNotification(
      title: '💬 New Message from Customer',
      body: data['message'] ?? 'You have a new message',
      data: {'type': 'customer_message', 'booking_id': data['booking_id']},
    );
  }
}