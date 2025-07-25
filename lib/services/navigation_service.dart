import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NavigationService {
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      // Try Google Maps app first
      final googleMapsUrl = 'google.navigation:q=$latitude,$longitude';
      
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
        return;
      }
      
      // Fallback to web Google Maps
      final webUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
      
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch navigation');
      }
    } catch (e) {
      throw Exception('Failed to open navigation: $e');
    }
  }
  
  static Future<void> openAppleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      final appleMapsUrl = 'maps://?daddr=$latitude,$longitude';
      
      if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } else {
        // Fallback to Google Maps if Apple Maps not available
        await openGoogleMaps(latitude: latitude, longitude: longitude, label: label);
      }
    } catch (e) {
      throw Exception('Failed to open Apple Maps: $e');
    }
  }
  
  static Future<void> openNavigation({
  required double latitude,
  required double longitude,
  String? label,
}) async {
  try {
    if (Platform.isIOS) {
      await openAppleMaps(latitude: latitude, longitude: longitude, label: label);
    } else {
      await openGoogleMaps(latitude: latitude, longitude: longitude, label: label);
    }
  } catch (e) {
    await openGoogleMaps(latitude: latitude, longitude: longitude, label: label);
  }
}

}