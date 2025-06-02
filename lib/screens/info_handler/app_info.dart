import 'package:flutter/material.dart';
import 'package:sepesha_app/models/direction_model.dart';

class AppInfo extends ChangeNotifier {
  DirectionModel? userPickUpLocation, UserDropOffLocation;
  int countTotalTrips = 0;
  // List<String> historyTripsKeyList = [];
  // List<TripHistoryModel> allTripHistoryInformationList = [];

  void updatePickupLocationAddress(DirectionModel pickUpAddress) {
    userPickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(DirectionModel dropOffAddress) {
    UserDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
