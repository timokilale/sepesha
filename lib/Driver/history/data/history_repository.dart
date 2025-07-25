import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/Driver/model/ride_model.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';

class HistoryRepository {
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  Future<List<Ride>> getRideHistory() async {
    print('=== GET RIDE HISTORY ===');
    try {
      final token = await Preferences.instance.apiToken;
      String? userId;

      try {
        final phone = SessionManager.instance.phone;
        userId = 'driver_$phone';
        print('User ID from session: $userId');
      } catch (e) {
        print('Error getting phone from session: $e');
        final phoneString = await Preferences.instance.getString(
          PrefKeys.phoneNumber,
        );
        if (phoneString != null) {
          userId = 'driver_$phoneString';
          print('User ID from preferences: $userId');
        }
      }

      if (userId == null) {
        print('No user ID available for ride history');
        return [];
      }

      final url = Uri.parse('$apiBaseUrl/bookings');
      print('Request URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'driver_id': userId, 'status': 'completed'}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          final List<dynamic> bookingsData = data['data'];
          final rides =
              bookingsData
                  .map((booking) => _mapBookingToRide(booking))
                  .toList();
          print('Rides: $rides');
          print('===================');
          return rides;
        }
      } else {
        print('Error fetching ride history: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching ride history: $e');
    }
    return [];
  }

  Ride _mapBookingToRide(Map<String, dynamic> booking) {
    print('=== MAPPING BOOKING TO RIDE ===');
    final ride = Ride(
      id: booking['id'] ?? '',
      customerId: booking['customer_id'] ?? '',
      passengerName: booking['customer_name'] ?? 'Unknown',
      pickupAddress: booking['pickup_location'] ?? '',
      destinationAddress: booking['delivery_location'] ?? '',
      fare: (booking['fare'] ?? 0).toDouble(),
      distance: (booking['distance_km'] ?? 0).toDouble(),
      requestTime:
          DateTime.tryParse(booking['created_at'] ?? '') ?? DateTime.now(),
      status: _mapStringToRideStatus(booking['status']),
      rating: booking['rating']?.toDouble(),
      passengerPhone: booking['customer_phone'],
      vehicleTypeRequested: booking['vehicle_type'],
    );
    print('Mapped Ride: $ride');
    print('============================');
    return ride;
  }

  RideStatus _mapStringToRideStatus(String? status) {
    print('=== MAPPING STRING TO RIDE STATUS ===');
    final rideStatus = switch (status?.toLowerCase()) {
      'pending' => RideStatus.requested,
      'assigned' => RideStatus.accepted,
      'intransit' => RideStatus.inProgress,
      'completed' => RideStatus.completed,
      'cancelled' => RideStatus.cancelled,
      _ => RideStatus.completed,
    };
    print('Ride Status: $rideStatus');
    print('==============================');
    return rideStatus;
  }
}
