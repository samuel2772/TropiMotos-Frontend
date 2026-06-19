import 'dart:async';

import 'package:flutter/material.dart';

import '../models/driver_trip.dart';
import '../services/driver_trip_service.dart';

class DriverTripProvider extends ChangeNotifier {
  final DriverTripService _service = DriverTripService();

  List<DriverTrip> _trips = const [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  List<DriverTrip> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _service.getRequestedTrips();
    } catch (_) {
      _errorMessage = 'No se pudieron cargar los viajes solicitados.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptTrip({required DriverTrip trip, required String driverId}) async {
    final success = await _service.acceptTrip(tripId: trip.id, driverId: driverId);
    if (success) {
      _trips = _trips.map((item) {
        if (item.id == trip.id) {
          return item.copyWith(estado: 'ACEPTADO', choferId: driverId);
        }
        return item;
      }).toList();
      notifyListeners();
    }
    return success;
  }

  void startAutoRefresh() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadTrips();
    });
  }

  void stopAutoRefresh() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    stopAutoRefresh();
    super.dispose();
  }
}
