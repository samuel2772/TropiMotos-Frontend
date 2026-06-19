import '../models/driver_trip_request.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();

  Future<List<DriverTripRequest>> getPendingRequests() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    return const [
      DriverTripRequest(
        id: 'req_001',
        origen: 'Av. Banzer y 4to anillo',
        destino: 'Equipetrol Norte',
        distanciaKm: 3.8,
        precioBs: 14.50,
        tiempoMinutos: 11,
      ),
      DriverTripRequest(
        id: 'req_002',
        origen: 'Terminal Bimodal',
        destino: '2do anillo y Santos Dumont',
        distanciaKm: 5.1,
        precioBs: 18.00,
        tiempoMinutos: 15,
      ),
      DriverTripRequest(
        id: 'req_003',
        origen: 'Mutualista',
        destino: 'Universidad Gabriel Rene Moreno',
        distanciaKm: 6.4,
        precioBs: 21.50,
        tiempoMinutos: 18,
      ),
    ];
  }

  Future<void> updateAvailability(bool isAvailable) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // Aqui luego se conectara con Spring Boot para actualizar el estado del chofer.
  }

  Future<void> acceptRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Aqui luego se enviara la aceptacion al backend Spring Boot.
  }

  Future<void> rejectRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // Aqui luego se enviara el rechazo al backend Spring Boot.
  }
}
