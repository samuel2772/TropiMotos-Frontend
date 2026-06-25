import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/driver_trip.dart';
import '../models/ride_estimate.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  RideEstimate calculateEstimate({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) {
    final latDelta = originLat - destinationLat;
    final lngDelta = originLng - destinationLng;
    final directDistanceKm = ((latDelta * latDelta) + (lngDelta * lngDelta)).sqrtLike() * 111;
    final routeDistanceKm = directDistanceKm < 0.6 ? 0.6 : directDistanceKm * 1.18;
    final durationMinutes = ((routeDistanceKm / AppConstants.averageSpeedKmPerHour) * 60).ceil();
    final price = AppConstants.rideBaseFare + (routeDistanceKm * AppConstants.ridePricePerKm);

    return RideEstimate(
      distanceKm: routeDistanceKm,
      durationMinutes: durationMinutes < 3 ? 3 : durationMinutes,
      price: price,
    );
  }

  Future<Map<String, dynamic>> requestDriver({
    required User user,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required String originLabel,
    required String destinationLabel,
    required RideEstimate estimate,
  }) async {
    final userId = int.tryParse(user.id);
    if (userId == null) {
      return {
        'success': false,
        'error': 'No se pudo identificar el usuario autenticado para solicitar el viaje.',
      };
    }

      final payload = {
        'origenLatitud': originLat,
        'origenLongitud': originLng,
        'origenTexto': originLabel,
        'destinoLatitud': destinationLat,
        'destinoLongitud': destinationLng,
        'destinoTexto': destinationLabel,
        'distanciaKm': estimate.distanceKm,
        'tiempoEstimadoMin': estimate.durationMinutes,
        'tarifaCalculada': estimate.price,
      };

    try {
      final http.Response response = await _apiClient.post('${AppConstants.tripEndpoint}/$userId', payload);
      final Map<String, dynamic>? body = _decodeMap(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tripId = _extractTripId(body?['data']) ?? _extractTripId(body);
        if (tripId != null && tripId.isNotEmpty) {
          await _storage.saveActiveTripId(tripId);
        }
        return {
          'success': true,
          'message': body?['message'] ?? 'Solicitud enviada. Buscando chofer...',
          'data': body?['data'],
          'tripId': tripId,
        };
      }

      return {
        'success': false,
        'error': body?['message'] ?? 'No se pudo solicitar el chofer',
        'statusCode': response.statusCode,
      };
    } catch (_) {
      return {
        'success': false,
        'error': 'No fue posible conectar con el backend para solicitar el viaje.',
      };
    }
  }

  Map<String, dynamic>? _decodeMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<DriverTrip?> getTripById(String tripId) async {
    try {
      final response = await _apiClient.get('${AppConstants.tripByIdEndpoint}/$tripId');
      debugPrint('=== VIAJE DETALLE ===');
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final body = _decodeMap(response.body);
        final tripMap = _extractTripMap(body);
        if (tripMap != null) {
          final trip = DriverTrip.fromJson(tripMap);
          debugPrint('=== DRIVER TRIP ===');
          debugPrint('id: ${trip.id}');
          debugPrint('estado: ${trip.estado}');
          debugPrint('origen: ${trip.origen}');
          debugPrint('destino: ${trip.destino}');
          debugPrint('distancia: ${trip.distanciaKm}');
          debugPrint('tarifa: ${trip.tarifa}');
          return trip;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveTrip() async {
    await _storage.clearActiveTripId();
  }

  Future<String?> getStoredActiveTripId() async {
    return _storage.getActiveTripId();
  }

  String? _extractTripId(dynamic source) {
    if (source is Map<String, dynamic>) {
      final value = source['idViaje'] ?? source['id'];
      return value?.toString();
    }
    return null;
  }

  Map<String, dynamic>? _extractTripMap(Map<String, dynamic>? body) {
    if (body == null) return null;
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return body;
  }
}

extension on num {
  double sqrtLike() {
    if (this <= 0) return 0;
    double estimate = toDouble();
    for (int i = 0; i < 8; i++) {
      estimate = 0.5 * (estimate + (toDouble() / estimate));
    }
    return estimate;
  }
}
