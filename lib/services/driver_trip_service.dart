import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../models/driver_trip.dart';
import 'api_client.dart';

class DriverTripService {
  static final DriverTripService _instance = DriverTripService._internal();
  factory DriverTripService() => _instance;
  DriverTripService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<DriverTrip>> getRequestedTrips() async {
    final response = await _apiClient.get(AppConstants.driverRequestedTripsEndpoint);

    debugPrint('=== VIAJES RECIBIDOS ===');
    debugPrint(response.body);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = _extractList(body);
      if (data != null) {
        final trips = data
            .map((item) => DriverTrip.fromJson(item))
            .where((trip) => trip.estado.toUpperCase() == 'SOLICITADO')
            .toList();

        for (final trip in trips) {
          debugPrint('=== DRIVER TRIP ===');
          debugPrint('id: ${trip.id}');
          debugPrint('estado: ${trip.estado}');
          debugPrint('origen: ${trip.origen}');
          debugPrint('destino: ${trip.destino}');
          debugPrint('distancia: ${trip.distanciaKm}');
          debugPrint('tarifa: ${trip.tarifa}');
        }

        return trips;
      }
      return const [];
    }

    throw Exception('No se pudieron cargar los viajes solicitados (${response.statusCode}).');
  }

  Future<bool> startTrip(String tripId) async {
    try {
      final url = '${AppConstants.driverStartTripEndpoint}/$tripId/iniciar';
      final body = <String, dynamic>{};

      debugPrint('=== INICIAR VIAJE ===');
      debugPrint('method: PUT');
      debugPrint('url: ${AppConstants.baseUrl}$url');
      debugPrint('body: ${jsonEncode(body)}');

      final response = await _apiClient.put(url, body);

      debugPrint('statusCode: ${response.statusCode}');
      debugPrint('response: ${response.body}');

      if (response.statusCode >= 400) {
        debugPrint('errorBody: ${response.body}');
      }

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('=== INICIAR VIAJE ===');
      debugPrint('method: PUT');
      debugPrint('url: ${AppConstants.baseUrl}${AppConstants.driverStartTripEndpoint}/$tripId/iniciar');
      debugPrint('body: {}');
      debugPrint('statusCode: request_error');
      debugPrint('response: $e');
      debugPrint('[DriverTripService] startTrip error: $e');
      return false;
    }
  }

  Future<bool> acceptTrip({
    required String tripId,
    required String driverId,
    required String vehicleId,
  }) async {
    try {
      final parsedDriverId = int.tryParse(driverId);
      final parsedVehicleId = int.tryParse(vehicleId);
      final url = '${AppConstants.driverAcceptTripEndpoint}/$tripId/aceptar';
      final body = {
        'idChofer': parsedDriverId ?? driverId,
        'idVehiculo': parsedVehicleId ?? vehicleId,
      };

      debugPrint('=== ACEPTAR VIAJE ===');
      debugPrint('tripId: $tripId');
      debugPrint('idChofer: ${parsedDriverId ?? driverId}');
      debugPrint('idVehiculo: ${parsedVehicleId ?? vehicleId}');
      debugPrint('url: ${AppConstants.baseUrl}$url');
      debugPrint('body: ${jsonEncode(body)}');

      final response = await _apiClient.put(
        url,
        body,
      );

      debugPrint('statusCode: ${response.statusCode}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('=== ACEPTAR VIAJE ===');
      debugPrint('tripId: $tripId');
      debugPrint('idChofer: $driverId');
      debugPrint('idVehiculo: $vehicleId');
      debugPrint('url: ${AppConstants.baseUrl}${AppConstants.driverAcceptTripEndpoint}/$tripId/aceptar');
      debugPrint('body: ${jsonEncode({'idChofer': driverId, 'idVehiculo': vehicleId})}');
      debugPrint('statusCode: request_error');
      debugPrint('[DriverTripService] acceptTrip error: $e');
      return false;
    }
  }

  List<Map<String, dynamic>>? _extractList(dynamic body) {
    if (body is List) {
      return body.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }

    return null;
  }
}
