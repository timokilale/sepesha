import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/booking.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';

class CustomerHistoryRepository {
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  Future<List<Booking>> getCustomerRideHistory({String? status}) async {
    debugPrint('=== GET CUSTOMER RIDE HISTORY ===');
    try {
      final token = await Preferences.instance.apiToken;
      final customerId = await _getCurrentCustomerId();

      final url = Uri.parse('$apiBaseUrl/bookings');
      debugPrint('Request URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer_id': customerId,
          if (status != null) 'status': status,
        }),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          final List<dynamic> bookingsData = data['data'];
          final bookings =
              bookingsData.map((booking) => Booking.fromJson(booking)).toList();
          debugPrint('Bookings: $bookings');
          debugPrint('==============================');
          return bookings;
        }
      } else {
        debugPrint(
          'Error fetching customer ride history: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Exception fetching customer ride history: $e');
    }
    return [];
  }

  Future<String> _getCurrentCustomerId() async {
    debugPrint('=== GET CURRENT CUSTOMER ID ===');
    try {
      final userData = SessionManager.instance.user;
      if (userData != null) {
        final customerId = 'customer_${userData.phoneNumber}';
        debugPrint('Customer ID from session: $customerId');
        debugPrint('==============================');
        return customerId;
      }

      final phone = SessionManager.instance.phone;
      final customerId = 'customer_$phone';
      debugPrint('Customer ID from session phone: $customerId');
      debugPrint('==============================');
      return customerId;
    } catch (e) {
      debugPrint('Error getting customer ID: $e');
      return '';
    }
  }

  Future<List<Booking>> getActiveRides() async {
    debugPrint('=== GET ACTIVE RIDES ===');
    final activeRides = await getCustomerRideHistory();
    debugPrint('Active Rides: $activeRides');
    debugPrint('======================');
    return activeRides;
  }

  Future<List<Booking>> getCompletedRides() async {
    debugPrint('=== GET COMPLETED RIDES ===');
    final completedRides = await getCustomerRideHistory(status: 'completed');
    debugPrint('Completed Rides: $completedRides');
    debugPrint('==========================');
    return completedRides;
  }

  Future<List<Booking>> getCanceledRides() async {
    debugPrint('=== GET CANCELED RIDES ===');
    final canceledRides = await getCustomerRideHistory(status: 'cancelled');
    debugPrint('Canceled Rides: $canceledRides');
    debugPrint('==========================');
    return canceledRides;
  }
}
