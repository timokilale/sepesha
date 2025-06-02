import 'package:flutter/foundation.dart';
import 'package:sepesha_app/Driver/history/data/history_repository.dart';
import 'package:sepesha_app/Driver/model/ride_model.dart';


class HistoryViewModel with ChangeNotifier {
  final HistoryRepository _repository = HistoryRepository();
  
  bool _isLoading = true;
  List<Ride> _rideHistory = [];

  bool get isLoading => _isLoading;
  List<Ride> get rideHistory => _rideHistory;

  HistoryViewModel() {
    _loadRideHistory();
  }

  Future<void> _loadRideHistory() async {
    _rideHistory = await _repository.getRideHistory();
    _isLoading = false;
    notifyListeners();
  }
}