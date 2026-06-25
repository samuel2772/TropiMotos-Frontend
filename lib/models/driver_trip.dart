class DriverTrip {
  final String id;
  final String idViaje;
  final String origen;
  final String destino;
  final double distanciaKm;
  final double tarifa;
  final String estado;
  final String? choferId;
  final double? origenLatitud;
  final double? origenLongitud;
  final double? destinoLatitud;
  final double? destinoLongitud;
  final String? pasajeroNombre;
  final String? choferNombre;
  final String? vehiculoNombre;
  final String? vehiculoPlaca;

  const DriverTrip({
    required this.id,
    required this.idViaje,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.tarifa,
    required this.estado,
    this.choferId,
    this.origenLatitud,
    this.origenLongitud,
    this.destinoLatitud,
    this.destinoLongitud,
    this.pasajeroNombre,
    this.choferNombre,
    this.vehiculoNombre,
    this.vehiculoPlaca,
  });

  factory DriverTrip.fromJson(Map<String, dynamic> json) {
    final origenMap = json['origen'];
    final destinoMap = json['destino'];
    final estimacionMap = json['estimacion'];
    final usuarioMap = json['usuario'];
    final choferMap = json['chofer'];
    final vehiculoMap = json['vehiculo'];

    return DriverTrip(
      id: (json['id'] ?? json['idViaje'] ?? '').toString(),
      idViaje: (json['idViaje'] ?? json['id'] ?? '').toString(),
      origen: _stringValue(
        json['origen'] ??
            json['origenTexto'] ??
            json['pickup'] ??
            json['direccionOrigen'] ??
            json['direccionRecogida'] ??
            (origenMap is Map ? origenMap['referencia'] ?? origenMap['direccion'] : null),
        'Origen no disponible',
      ),
      destino: _stringValue(
        json['destino'] ??
            json['destinoTexto'] ??
            json['dropoff'] ??
            json['direccionDestino'] ??
            json['direccionEntrega'] ??
            (destinoMap is Map ? destinoMap['referencia'] ?? destinoMap['direccion'] : null),
        'Destino no disponible',
      ),
      distanciaKm: _toDouble(
        json['distanciaKm'] ??
            json['distancia'] ??
            json['distanciaCalculada'] ??
            json['distanciaAproximada'] ??
            json['kilometros'] ??
            ((json['distanciaMetros'] is num) ? (json['distanciaMetros'] as num).toDouble() / 1000 : null) ??
            (estimacionMap is Map ? estimacionMap['distanciaKm'] : null),
      ),
      tarifa: _toDouble(
        json['tarifaCalculada'] ??
        json['tarifa'] ??
            json['precio'] ??
            json['monto'] ??
            json['costo'] ??
            json['costoTotal'] ??
            json['precioAproximado'] ??
            json['tarifaAproximada'] ??
            (estimacionMap is Map ? estimacionMap['precioAproximado'] : null),
      ),
      estado: (json['nombreEstado'] ??
              json['estadoViaje'] ??
              json['estado'] ??
              json['nombre_estado'] ??
              'SOLICITADO')
          .toString()
          .toUpperCase(),
      choferId: (json['idChofer'] ??
              json['id_chofer'] ??
              (choferMap is Map ? choferMap['id'] : null) ??
              (usuarioMap is Map ? usuarioMap['idChofer'] : null))
          ?.toString(),
      origenLatitud: _toNullableDouble(
        json['origenLatitud'] ??
            json['latitudOrigen'] ??
            (origenMap is Map ? origenMap['latitud'] : null),
      ),
      origenLongitud: _toNullableDouble(
        json['origenLongitud'] ??
            json['longitudOrigen'] ??
            (origenMap is Map ? origenMap['longitud'] : null),
      ),
      destinoLatitud: _toNullableDouble(
        json['destinoLatitud'] ??
            json['latitudDestino'] ??
            (destinoMap is Map ? destinoMap['latitud'] : null),
      ),
      destinoLongitud: _toNullableDouble(
        json['destinoLongitud'] ??
            json['longitudDestino'] ??
            (destinoMap is Map ? destinoMap['longitud'] : null),
      ),
      pasajeroNombre: _stringValue(
        json['nombreUsuario'] ??
            json['pasajeroNombre'] ??
            (usuarioMap is Map ? usuarioMap['nombre'] ?? usuarioMap['nombreCompleto'] : null),
        '',
      ),
      choferNombre: _stringValue(
        json['nombreChofer'] ??
            (choferMap is Map ? choferMap['nombre'] ?? choferMap['nombreCompleto'] : null),
        '',
      ),
      vehiculoNombre: _stringValue(
        json['vehiculoDescripcion'] ??
            json['vehiculoNombre'] ??
            (vehiculoMap is Map ? vehiculoMap['modelo'] ?? vehiculoMap['descripcion'] ?? vehiculoMap['marca'] : null),
        '',
      ),
      vehiculoPlaca: _stringValue(
        json['placaVehiculo'] ??
            json['vehiculoPlaca'] ??
            json['placa'] ??
            (vehiculoMap is Map ? vehiculoMap['placa'] : null),
        '',
      ),
    );
  }

  DriverTrip copyWith({
    String? id,
    String? idViaje,
    String? origen,
    String? destino,
    double? distanciaKm,
    double? tarifa,
    String? estado,
    String? choferId,
    double? origenLatitud,
    double? origenLongitud,
    double? destinoLatitud,
    double? destinoLongitud,
    String? pasajeroNombre,
    String? choferNombre,
    String? vehiculoNombre,
    String? vehiculoPlaca,
  }) {
    return DriverTrip(
      id: id ?? this.id,
      idViaje: idViaje ?? this.idViaje,
      origen: origen ?? this.origen,
      destino: destino ?? this.destino,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      tarifa: tarifa ?? this.tarifa,
      estado: estado ?? this.estado,
      choferId: choferId ?? this.choferId,
      origenLatitud: origenLatitud ?? this.origenLatitud,
      origenLongitud: origenLongitud ?? this.origenLongitud,
      destinoLatitud: destinoLatitud ?? this.destinoLatitud,
      destinoLongitud: destinoLongitud ?? this.destinoLongitud,
      pasajeroNombre: pasajeroNombre ?? this.pasajeroNombre,
      choferNombre: choferNombre ?? this.choferNombre,
      vehiculoNombre: vehiculoNombre ?? this.vehiculoNombre,
      vehiculoPlaca: vehiculoPlaca ?? this.vehiculoPlaca,
    );
  }

  String get distanciaLabel => '${distanciaKm.toStringAsFixed(1)} km';
  String get tarifaLabel => 'Bs ${tarifa.toStringAsFixed(2)}';
  bool get hasPickupCoordinates => origenLatitud != null && origenLongitud != null;
  bool get hasDestinationCoordinates => destinoLatitud != null && destinoLongitud != null;

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _stringValue(dynamic value, String fallback) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return fallback;
    }
    return text;
  }
}
