import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/ride_estimate.dart';
import '../models/user.dart';
import 'api_client.dart';

class TripService {
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final ApiClient _apiClient = ApiClient();

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
    required String destinationLabel,
    required RideEstimate estimate,
  }) async {
    final payload = {
      'idUsuario': user.id.isEmpty ? null : int.tryParse(user.id),
      'nombreUsuario': user.nombre,
      'email': user.email,
      'origen': {
        'latitud': originLat,
        'longitud': originLng,
      },
      'destino': {
        'latitud': destinationLat,
        'longitud': destinationLng,
        'referencia': destinationLabel,
      },
      'estimacion': {
        'distanciaKm': estimate.distanceKm,
        'tiempoMinutos': estimate.durationMinutes,
        'precioAproximado': estimate.price,
      },
    };

    try {
      final http.Response response = await _apiClient.post(AppConstants.tripEndpoint, payload);
      final Map<String, dynamic>? body = _decodeMap(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body?['message'] ?? 'Solicitud enviada. Buscando chofer...',
          'data': body?['data'],
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
