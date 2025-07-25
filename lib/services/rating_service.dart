import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:sepesha_app/models/driver_review.dart';
import 'package:sepesha_app/services/preferences.dart';

class RatingService {
  RatingService._();

  static final String apiBaseUrl = dotenv.env['BASE_URL']!;

  /// Create a new driver review
  /// POST /driver-rating/create
  static Future<DriverReview?> createDriverReview({
    required String driverId,
    required int rating,
    required String review,
  }) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/driver-rating/create');

      final request = CreateReviewRequest(
        driverId: driverId,
        rating: rating,
        review: review,
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] && data['data'] != null) {
          return DriverReview.fromJson(data['data']);
        }
        return null;
      } else {
        print('Error creating review: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception creating review: $e');
      return null;
    }
  }

  /// Get driver reviews and rating data
  /// GET /driver-rating/{driver_id}
  static Future<DriverRatingData?> getDriverReviews(String driverId) async {
    try {
      final token = await Preferences.instance.apiToken;
      final url = Uri.parse('$apiBaseUrl/driver-rating/$driverId');

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
          return DriverRatingData.fromJson(data['data']);
        }
        return null;
      } else {
        print('Error fetching driver reviews: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception fetching driver reviews: $e');
      return null;
    }
  }

  /// Helper method to validate rating value
  static bool isValidRating(int rating) {
    return rating >= 1 && rating <= 5;
  }
}
