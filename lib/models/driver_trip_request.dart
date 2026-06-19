class DriverTripRequest {
  final String id;
  final String origen;
  final String destino;
  final double distanciaKm;
  final double precioBs;
  final int tiempoMinutos;

  const DriverTripRequest({
    required this.id,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.precioBs,
    required this.tiempoMinutos,
  });

  String get distanciaLabel => '${distanciaKm.toStringAsFixed(1)} km';
  String get precioLabel => 'Bs ${precioBs.toStringAsFixed(2)}';
  String get tiempoLabel => '$tiempoMinutos min';
}
