import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/user_data.dart';
import 'package:sepesha_app/services/preferences.dart';
import 'package:sepesha_app/services/session_manager.dart';
import '../../../model/ride_model.dart' show Ride, RideStatus;
import '../../../model/user_model.dart' show User;

class DashboardRepository {
  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  /// Get user data from stored session or API
  Future<User> getUserData() async {
    try {
      // Try to get user data from session
      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        return _mapUserDataToUser(sessionUser);
      }
    } catch (e) {
      // Session user might be null, continue to fallback
    }

    try {
      // Fallback: construct user from individual session fields
      return User(
        id: 'driver_${SessionManager.instance.phone}', // Use phone as ID fallback
        name:
            '${SessionManager.instance.getFirstname} ${SessionManager.instance.getLastname}',
        email: SessionManager.instance.getEmail,
        phone: SessionManager.instance.phone.toString(),
        vehicleNumber: _getVehicleNumber(),
        vehicleType: _getVehicleType(),
        walletBalance: 0.0, // This would come from wallet API
        rating: 4.5, // This would come from driver rating API
        totalRides: 0, // This would come from booking history API
      );
    } catch (e) {
      debugPrint('Error getting user data from session: $e');
      // Return fallback user
      return User(
        id: 'fallback',
        name: 'Driver',
        email: 'driver@sepesha.com',
        phone: '+255000000000',
        vehicleNumber: 'N/A',
        vehicleType: 'Car',
        walletBalance: 0.0,
        rating: 0.0,
        totalRides: 0,
      );
    }
  }

  /// Map UserData to User model
  User _mapUserDataToUser(UserData userData) {
    return User(
      id: 'driver_${userData.phoneNumber}',
      name: '${userData.firstName} ${userData.lastName}',
      email: userData.email,
      phone: userData.phoneNumber,
      vehicleNumber: _getVehicleNumber(),
      vehicleType: _getVehicleType(),
      walletBalance: 0.0, // Would need wallet endpoint
      rating: 4.5, // Would need rating endpoint
      totalRides: 0, // Would need booking history count
    );
  }

  /// Get vehicle number from session
  String _getVehicleNumber() {
    try {
      final vehicle = SessionManager.instance.vehicle;
      return vehicle?.plateNumber ?? 'TBD';
    } catch (e) {
      return 'TBD';
    }
  }

  /// Get vehicle type from session
  String _getVehicleType() {
    try {
      final vehicle = SessionManager.instance.vehicle;
      return '${vehicle?.manufacturer ?? 'Car'} ${vehicle?.model ?? ''}';
    } catch (e) {
      return 'Car';
    }
  }

  Future<List<Ride>> getPendingRides() async {
    try {
      final token = await Preferences.instance.apiToken;
      final response = await http.post(
        Uri.parse('$apiBaseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'pending', // Filter for pending rides
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          final bookings = data['data'] as List;
          return bookings.map((booking) => _mapBookingToRide(booking)).toList();
        }
      }

      // Return empty list if API fails
      return [];
    } catch (e) {
      debugPrint('Error fetching pending rides: $e');
      // Return fallback data for development
      return _getFallbackRides();
    }
  }

  /// Map booking data from API to Ride model
  Ride _mapBookingToRide(Map<String, dynamic> booking) {
    return Ride(
      id: booking['id'] ?? 'unknown',
      customerId: booking['customer_id'] ?? 'unknown_customer',
      passengerName: booking['customer_name'] ?? 'Unknown Passenger',
      pickupAddress: booking['pickup_location'] ?? 'Unknown pickup',
      destinationAddress: booking['delivery_location'] ?? 'Unknown destination',
      fare: double.tryParse(booking['fare']?.toString() ?? '0') ?? 0.0,
      distance:
          double.tryParse(booking['distance_km']?.toString() ?? '0') ?? 0.0,
      requestTime:
          DateTime.tryParse(booking['created_at'] ?? '') ?? DateTime.now(),
      status: _mapBookingStatus(booking['status']),
      passengerPhone: booking['customer_phone'],
      vehicleTypeRequested: booking['vehicle_type'],
      // Map coordinate fields from booking data
      pickupLatitude: double.tryParse(booking['pickup_latitude']?.toString() ?? '0'),
      pickupLongitude: double.tryParse(booking['pickup_longitude']?.toString() ?? '0'),
      destinationLatitude: double.tryParse(booking['delivery_latitude']?.toString() ?? '0'),
      destinationLongitude: double.tryParse(booking['delivery_longitude']?.toString() ?? '0'),
    );
  }

  /// Map booking status to RideStatus enum
  RideStatus _mapBookingStatus(String? status) {
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
        return RideStatus.requested;
    }
  }

  /// Fallback rides for development/testing
  List<Ride> _getFallbackRides() {
    return [
      Ride(
        id: 'ride1',
        customerId: 'customer1',
        passengerName: 'Alice Smith',
        pickupAddress: '123 Main St, Cityville',
        destinationAddress: '456 Oak Ave, Townsburg',
        fare: 25.50,
        distance: 5.2,
        requestTime: DateTime.now().subtract(const Duration(minutes: 5)),
        status: RideStatus.requested,
        pickupLatitude: -6.7924, // Dar es Salaam coordinates
        pickupLongitude: 39.2083,
        destinationLatitude: -6.8000,
        destinationLongitude: 39.2500,
      ),
      Ride(
        id: 'ride2',
        customerId: 'customer2',
        passengerName: 'Bob Johnson',
        pickupAddress: '789 Pine Rd, Villageton',
        destinationAddress: '321 Elm St, Hamletville',
        fare: 18.75,
        distance: 3.8,
        requestTime: DateTime.now().subtract(const Duration(minutes: 2)),
        status: RideStatus.requested,
        pickupLatitude: -6.7700,
        pickupLongitude: 39.1900,
        destinationLatitude: -6.8200,
        destinationLongitude: 39.2700,
      ),
    ];
  }

  /// Accept a ride request
  Future<bool> acceptRide(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final response = await http.post(
        Uri.parse('$apiBaseUrl/driver-response'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'booking_id': rideId, 'response': 'accept'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting ride: $e');
      return false;
    }
  }

  /// Reject a ride request
  Future<bool> rejectRide(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final response = await http.post(
        Uri.parse('$apiBaseUrl/driver-response'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'booking_id': rideId, 'response': 'reject'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rejecting ride: $e');
      return false;
    }
  }

  /// Complete a ride (this would need a different endpoint)
  Future<bool> completeRide(String rideId) async {
    try {
      // This would need a specific endpoint for completing rides
      // For now, simulate completion
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint('Error completing ride: $e');
      return false;
    }
  }

  /// Get detailed booking information with coordinates
  Future<Ride?> getDetailedRideInfo(String rideId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final response = await http.get(
        Uri.parse('$apiBaseUrl/booking/$rideId'),
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
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching detailed ride info: $e');
      return null;
    }
  }
}
