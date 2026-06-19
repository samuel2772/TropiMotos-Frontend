class DriverTrip {
  final String id;
  final String origen;
  final String destino;
  final double distanciaKm;
  final double tarifa;
  final String estado;
  final String? choferId;

  const DriverTrip({
    required this.id,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.tarifa,
    required this.estado,
    this.choferId,
  });

  factory DriverTrip.fromJson(Map<String, dynamic> json) {
    return DriverTrip(
      id: (json['id'] ?? json['idViaje'] ?? '').toString(),
      origen: (json['origen'] ?? json['pickup'] ?? json['direccionOrigen'] ?? 'Origen no disponible').toString(),
      destino: (json['destino'] ?? json['dropoff'] ?? json['direccionDestino'] ?? 'Destino no disponible').toString(),
      distanciaKm: _toDouble(json['distanciaKm'] ?? json['distancia'] ?? json['kilometros']),
      tarifa: _toDouble(json['tarifa'] ?? json['precio'] ?? json['monto']),
      estado: (json['estado'] ?? 'SOLICITADO').toString().toUpperCase(),
      choferId: json['idChofer']?.toString(),
    );
  }

  DriverTrip copyWith({
    String? id,
    String? origen,
    String? destino,
    double? distanciaKm,
    double? tarifa,
    String? estado,
    String? choferId,
  }) {
    return DriverTrip(
      id: id ?? this.id,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      tarifa: tarifa ?? this.tarifa,
      estado: estado ?? this.estado,
      choferId: choferId ?? this.choferId,
    );
  }

  String get distanciaLabel => '${distanciaKm.toStringAsFixed(1)} km';
  String get tarifaLabel => 'Bs ${tarifa.toStringAsFixed(2)}';

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
