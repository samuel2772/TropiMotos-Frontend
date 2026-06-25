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
    } catch (e) {
      _trips = const [];
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> acceptTrip({
    required DriverTrip trip,
    required String driverId,
    required String vehicleId,
  }) async {
    debugPrint('=== ACEPTAR VIAJE ===');
    debugPrint('tripId: ${trip.idViaje}');
    debugPrint('idChofer: $driverId');
    debugPrint('idVehiculo: $vehicleId');
    final success = await _service.acceptTrip(
      tripId: trip.idViaje,
      driverId: driverId,
      vehicleId: vehicleId,
    );
    if (success) {
      _trips = _trips.where((item) => item.idViaje != trip.idViaje).toList();
      notifyListeners();
    }
    return success;
  }

  Future<bool> startTrip(String tripId) async {
    return _service.startTrip(tripId);
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
