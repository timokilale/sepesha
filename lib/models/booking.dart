import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  assigned,
  intransit,
  completed,
  canceled,
  unknown
}

class Booking {
  final String id;
  final String bookingReference;
  final String customerId;
  final String feeCategoryId;
  final String recipientName;
  final String recipientPhone;
  final String userType;
  final String description;
  final String pickupLocation;
  final String deliveryLocation;
  final DateTime pickupDate;
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final double distanceKm;
  final String? discountCode;
  final String? referralCode;
  final Map<String, dynamic>? customerDetails;
  final String? luggageSize;
  final String? pickupPhotoUrl;
  BookingStatus status;
  final String? driverId;
  final String? vehicleId;
  final String? driverName;
  final String? driverPhone;
  final double? driverRating;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehiclePlateNumber;
  final String? vehicleColor;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.customerId,
    required this.feeCategoryId,
    required this.recipientName,
    required this.recipientPhone,
    required this.userType,
    required this.description,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupDate,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.distanceKm,
    this.discountCode,
    this.referralCode,
    this.customerDetails,
    this.luggageSize,
    this.pickupPhotoUrl,
    required this.status,
    this.driverId,
    this.vehicleId,
    this.driverName,
    this.driverPhone,
    this.driverRating,
    this.vehicleMake,
    this.vehicleModel,
    this.vehiclePlateNumber,
    this.vehicleColor,
    required this.createdAt,
    this.updatedAt,
  });

  // Factory method to create a Booking from a JSON map
  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse status
    BookingStatus parseStatus(String? statusStr) {
      if (statusStr == null) return BookingStatus.unknown;

      switch (statusStr.toLowerCase()) {
        case 'pending':
          return BookingStatus.pending;
        case 'assigned':
          return BookingStatus.assigned;
        case 'intransit':
          return BookingStatus.intransit;
        case 'completed':
          return BookingStatus.completed;
        case 'canceled':
          return BookingStatus.canceled;
        default:
          return BookingStatus.unknown;
      }
    }

    // Parse dates
    DateTime parseDate(String? dateStr) {
      if (dateStr == null) return DateTime.now();
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Parse driver and vehicle details
    Map<String, dynamic>? driver = json['driver'] as Map<String, dynamic>?;
    Map<String, dynamic>? vehicle = json['vehicle'] as Map<String, dynamic>?;

    return Booking(
      id: json['id'] as String? ?? '',
      bookingReference: json['booking_reference'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      feeCategoryId: json['fee_category_id'] as String? ?? '',
      recipientName: json['recepient_name'] as String? ?? '',
      recipientPhone: json['recepient_phone'] as String? ?? '',
      userType: json['user_type'] as String? ?? 'customer',
      description: json['description'] as String? ?? '',
      pickupLocation: json['pickup_location'] as String? ?? '',
      deliveryLocation: json['delivery_location'] as String? ?? '',
      pickupDate: parseDate(json['pickup_date'] as String?),
      pickupLatitude: double.tryParse(json['pickup_latitude'] as String? ?? '0') ?? 0.0,
      pickupLongitude: double.tryParse(json['pickup_longitude'] as String? ?? '0') ?? 0.0,
      deliveryLatitude: double.tryParse(json['delivery_latitude'] as String? ?? '0') ?? 0.0,
      deliveryLongitude: double.tryParse(json['delivery_longitude'] as String? ?? '0') ?? 0.0,
      distanceKm: double.tryParse(json['distance_km'] as String? ?? '0') ?? 0.0,
      discountCode: json['discount_code'] as String?,
      referralCode: json['referal_code'] as String?,
      customerDetails: json['customerDetails'] as Map<String, dynamic>?,
      luggageSize: json['luggage_size'] as String?,
      pickupPhotoUrl: json['pickup_photo'] as String?,
      status: parseStatus(json['status'] as String?),
      driverId: json['driver_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
      driverName: driver?['name'] as String?,
      driverPhone: driver?['phone'] as String?,
      driverRating: (driver?['rating'] as num?)?.toDouble(),
      vehicleMake: vehicle?['make'] as String?,
      vehicleModel: vehicle?['model'] as String?,
      vehiclePlateNumber: vehicle?['plate_number'] as String?,
      vehicleColor: vehicle?['color'] as String?,
      createdAt: parseDate(json['created_at'] as String?),
      updatedAt: parseDate(json['updated_at'] as String?),
    );
  }

  // Helper method to get the status color
  Color getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.assigned:
        return Colors.blue;
      case BookingStatus.intransit:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.canceled:
        return Colors.red;
      case BookingStatus.unknown:
        return Colors.grey;
    }
  }

  // Helper method to get the status text
  String getStatusText() {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.assigned:
        return 'Driver Assigned';
      case BookingStatus.intransit:
        return 'In Transit';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.canceled:
        return 'Canceled';
      case BookingStatus.unknown:
        return 'Unknown';
    }
  }

  // Helper method to get the estimated arrival time
  String getEstimatedArrivalTime() {
    if (status == BookingStatus.assigned) {
      // Calculate estimated arrival time based on distance and average speed
      // Assuming average speed of 30 km/h
      final double averageSpeed = 30.0; // km/h
      final double estimatedTimeHours = distanceKm / averageSpeed;
      final int estimatedTimeMinutes = (estimatedTimeHours * 60).round();

      if (estimatedTimeMinutes < 1) {
        return 'Less than a minute';
      } else if (estimatedTimeMinutes == 1) {
        return '1 minute';
      } else if (estimatedTimeMinutes < 60) {
        return '$estimatedTimeMinutes minutes';
      } else {
        final int hours = estimatedTimeMinutes ~/ 60;
        final int minutes = estimatedTimeMinutes % 60;
        return '$hours hour${hours > 1 ? 's' : ''}${minutes > 0 ? ' $minutes minute${minutes > 1 ? 's' : ''}' : ''}';
      }
    } else {
      return 'N/A';
    }
  }

  // Helper method to get the vehicle details
  String getVehicleDetails() {
    if (vehicleMake != null && vehicleModel != null) {
      String details = '$vehicleMake $vehicleModel';
      if (vehicleColor != null) {
        details += ' • $vehicleColor';
      }
      if (vehiclePlateNumber != null) {
        details += ' • $vehiclePlateNumber';
      }
      return details;
    }
    return 'N/A';
  }

  // Helper method to format the date
  String getFormattedDate() {
    return '${pickupDate.day}/${pickupDate.month}/${pickupDate.year}';
  }

  // Helper method to get the trip duration
  String getTripDuration() {
    if (status == BookingStatus.completed && updatedAt != null) {
      final Duration duration = updatedAt!.difference(createdAt);
      final int minutes = duration.inMinutes;

      if (minutes < 60) {
        return '$minutes minutes';
      } else {
        final int hours = minutes ~/ 60;
        final int remainingMinutes = minutes % 60;
        return '$hours hour${hours > 1 ? 's' : ''}${remainingMinutes > 0 ? ' $remainingMinutes minute${remainingMinutes > 1 ? 's' : ''}' : ''}';
      }
    } else {
      // Estimate based on distance
      final double averageSpeed = 30.0; // km/h
      final double estimatedTimeHours = distanceKm / averageSpeed;
      final int estimatedTimeMinutes = (estimatedTimeHours * 60).round();

      return '$estimatedTimeMinutes minutes (estimated)';
    }
  }
}
