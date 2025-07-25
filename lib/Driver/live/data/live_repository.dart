import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';

class LiveRepository {
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  /// Get active ride details for the current driver
  Future<Ride> getActiveRideDetails(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/booking/$rideId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          return _mapBookingToRide(data['data']);
        }
        throw Exception(
          'Failed to get ride details: ${data['message'] ?? 'Unknown error'}',
        );
      } else {
        throw Exception(
          'Failed to get ride details: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception getting active ride details: $e');
      throw Exception('Failed to get ride details: $e');
    }
  }

  /// Map booking data from API to Ride model
  Ride _mapBookingToRide(Map<String, dynamic> booking) {
    // Extract customer/passenger information
    final customer = booking['customer'] as Map<String, dynamic>?;
    final customerName =
        customer != null
            ? '${customer['name'] ?? ''} ${customer['sname'] ?? ''}'.trim()
            : booking['recepient_name'] ?? 'Unknown Passenger';

    return Ride(
      id: booking['id'] ?? '',
      customerId: booking['customer_id'] ?? '',
      passengerName: customerName,
      pickupAddress: booking['pickup_location'] ?? '',
      destinationAddress: booking['delivery_location'] ?? '',
      fare: (booking['fare'] ?? booking['estimated_fare'] ?? 0).toDouble(),
      distance: (booking['distance_km'] ?? 0).toDouble(),
      requestTime:
          DateTime.tryParse(booking['created_at'] ?? '') ?? DateTime.now(),
      status: _mapStringToRideStatus(booking['status']),
      rating: booking['rating']?.toDouble(),
      passengerPhone: customer?['phone'] ?? booking['recepient_phone'],
      vehicleTypeRequested: booking['category']?['name'],
      // Add coordinate mapping from API response
      pickupLatitude: (booking['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (booking['pickup_longitude'] as num?)?.toDouble(),
      destinationLatitude: (booking['delivery_latitude'] as num?)?.toDouble(),
      destinationLongitude: (booking['delivery_longitude'] as num?)?.toDouble(),
    );
  }

  /// Map string status to RideStatus enum
  RideStatus _mapStringToRideStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RideStatus.requested;
      case 'assigned':
        return RideStatus.accepted;
      case 'intransit':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.inProgress; // Default for active rides
    }
  }

  /// Get current driver ID from session/preferences
  Future<String> _getCurrentDriverId() async {
    try {
      // Try to get from session manager first
      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        // Use phone number as driver identifier (adjust based on your ID system)
        return 'driver_${sessionUser.phoneNumber}';
      }

      // Fallback: try individual session fields
      final phone = SessionManager.instance.phone;
      return 'driver_$phone';
    } catch (e) {
      print('Error getting driver ID: $e');
      // Return empty string as fallback - this will cause API calls to fail gracefully
      return '';
    }
  }

  /// Update driver's current location
  Future<void> updateDriverLocation(
    LatLng position, {
    String? bookingId,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final driverId = await _getCurrentDriverId();

      final url = Uri.parse('$apiBaseUrl/update-location');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': driverId,
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': 10.0, // Default accuracy
          'speed': 0.0, // Can be enhanced with actual speed data
          'heading': 0.0, // Can be enhanced with actual heading data
          'altitude': 0.0, // Can be enhanced with actual altitude data
          if (bookingId != null) 'booking_id': bookingId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['status']) {
          throw Exception(
            'Failed to update location: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception(
          'Failed to update location: HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Exception updating driver location: $e');
      throw Exception('Failed to update location: $e');
    }
  }

  /// Complete a ride
  Future<void> completeRide(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/driver-response');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': rideId,
          'response':
              'complete', // This might need to be adjusted based on actual API
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['status']) {
          throw Exception(
            'Failed to complete ride: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to complete ride: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception completing ride: $e');
      throw Exception('Failed to complete ride: $e');
    }
  }

  /// Cancel a ride
  Future<void> cancelRide(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/driver-response');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': rideId,
          'response': 'decline', // Decline the booking
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data['status']) {
          throw Exception(
            'Failed to cancel ride: ${data['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Failed to cancel ride: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception canceling ride: $e');
      throw Exception('Failed to cancel ride: $e');
    }
  }

  /// Get real-time passenger location for a specific ride
  Stream<LatLng> getPassengerLocation(String rideId) async* {
    try {
      final token = await Preferences.instance.apiToken;

      // First, get the booking details to find the customer ID
      final bookingDetails = await _getBookingDetails(rideId);
      if (bookingDetails == null) {
        throw Exception('Booking not found');
      }

      final customerId = bookingDetails['customer_id'];
      if (customerId == null) {
        throw Exception('Customer ID not found in booking');
      }

      // Poll for location updates every 5 seconds
      while (true) {
        try {
          final url = Uri.parse(
            '$apiBaseUrl/driver-location?driver_id=$customerId',
          );

          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['status'] && data['data'] != null) {
              final locationData = data['data'];
              final lat = (locationData['latitude'] as num?)?.toDouble();
              final lng = (locationData['longitude'] as num?)?.toDouble();

              if (lat != null && lng != null) {
                yield LatLng(lat, lng);
              }
            }
          }
        } catch (e) {
          print('Error getting passenger location: $e');
          // Continue polling even if one request fails
        }

        // Wait 5 seconds before next poll
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Exception in passenger location stream: $e');
      // Yield a default position or handle error appropriately
      yield const LatLng(0.0, 0.0);
    }
  }

  /// Get booking details helper method
  Future<Map<String, dynamic>?> _getBookingDetails(String bookingId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/booking/$bookingId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Exception getting booking details: $e');
      return null;
    }
  }
}
