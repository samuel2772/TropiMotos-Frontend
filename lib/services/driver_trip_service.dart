import 'dart:convert';

import '../config/constants.dart';
import '../models/driver_trip.dart';
import 'api_client.dart';

class DriverTripService {
  static final DriverTripService _instance = DriverTripService._internal();
  factory DriverTripService() => _instance;
  DriverTripService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<DriverTrip>> getRequestedTrips() async {
    try {
      final response = await _apiClient.get(AppConstants.driverRequestedTripsEndpoint);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = _extractList(body);
        if (data != null) {
          return data.map((item) => DriverTrip.fromJson(item)).where((trip) => trip.estado == 'SOLICITADO').toList();
        }
      }
    } catch (_) {}

    return const [
      DriverTrip(
        id: '1',
        origen: 'Av. Banzer y 4to anillo',
        destino: 'Equipetrol',
        distanciaKm: 3.6,
        tarifa: 14.0,
        estado: 'SOLICITADO',
      ),
      DriverTrip(
        id: '2',
        origen: 'Terminal Bimodal',
        destino: '2do anillo y Santos Dumont',
        distanciaKm: 5.1,
        tarifa: 18.5,
        estado: 'SOLICITADO',
      ),
    ];
  }

  Future<bool> acceptTrip({required String tripId, required String driverId}) async {
    try {
      final response = await _apiClient.put(
        '${AppConstants.driverAcceptTripEndpoint}/$tripId/accept',
        {
          'estado': 'ACEPTADO',
          'id_chofer': driverId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
    } catch (_) {}

    return true;
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
