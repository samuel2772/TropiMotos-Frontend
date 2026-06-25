import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/driver_trip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_trip_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/role_badge.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool _isAvailable = true;
  DriverTrip? _acceptedTrip;
  bool _isStartingTrip = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DriverTripProvider>();
      provider.loadTrips();
      provider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    context.read<DriverTripProvider>().stopAutoRefresh();
    super.dispose();
  }

  Future<void> _acceptTrip(BuildContext context, DriverTrip trip) async {
    final provider = context.read<DriverTripProvider>();
    final storage = StorageService();
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    final driverId = await storage.getUserDriverId();
    final vehicleId = await storage.getUserVehicleId();

    if (!mounted) return;

    debugPrint('=== ACEPTAR VIAJE ===');
    debugPrint('tripId: ${trip.idViaje}');
    debugPrint('idChofer: $driverId');
    debugPrint('idVehiculo: $vehicleId');
    debugPrint('url: pendiente en service');
    debugPrint('body: pendiente en service');

    if (driverId == null || driverId.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('No se pudo identificar el chofer autenticado.'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    if (vehicleId == null || vehicleId.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('No se pudo identificar el vehiculo del chofer autenticado.'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    final success = await provider.acceptTrip(
      trip: trip,
      driverId: driverId,
      vehicleId: vehicleId,
    );
    if (!context.mounted) return;

    if (success) {
      setState(() {
        _acceptedTrip = trip.copyWith(
          origen: trip.origen,
          destino: trip.destino,
          distanciaKm: trip.distanciaKm,
          tarifa: trip.tarifa,
          estado: 'ACEPTADO',
          choferId: driverId,
          origenLatitud: trip.origenLatitud,
          origenLongitud: trip.origenLongitud,
          destinoLatitud: trip.destinoLatitud,
          destinoLongitud: trip.destinoLongitud,
          pasajeroNombre: trip.pasajeroNombre,
          choferNombre: auth.user?.nombre,
          vehiculoNombre: trip.vehiculoNombre,
          vehiculoPlaca: trip.vehiculoPlaca,
        );
      });
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(success ? 'Viaje aceptado correctamente.' : 'No se pudo aceptar el viaje.'),
        backgroundColor: success ? null : theme.colorScheme.error,
      ),
    );
  }

  Future<void> _startTrip() async {
    final trip = _acceptedTrip;
    if (trip == null) return;

    setState(() => _isStartingTrip = true);
    final success = await context.read<DriverTripProvider>().startTrip(trip.idViaje);
    if (!mounted) return;

    setState(() {
      _isStartingTrip = false;
      if (success) {
        _acceptedTrip = trip.copyWith(
          estado: 'INICIADO',
          distanciaKm: trip.distanciaKm,
          tarifa: trip.tarifa,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Viaje iniciado correctamente.' : 'No se pudo iniciar el viaje.'),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    context.go('/login');
  }

  DriverTrip? _getTripForMap(List<DriverTrip> trips) {
    if (!_isAvailable) return null;

    final acceptedTrip = _acceptedTrip;
    if (acceptedTrip != null && _shouldShowMapForTrip(acceptedTrip)) {
      return acceptedTrip;
    }

    for (final trip in trips) {
      if (_shouldShowMapForTrip(trip)) {
        return trip;
      }
    }

    return null;
  }

  bool _shouldShowMapForTrip(DriverTrip trip) {
    const activeStates = {'SOLICITADO', 'ACEPTADO', 'EN_CURSO', 'INICIADO'};
    return trip.hasPickupCoordinates &&
        trip.hasDestinationCoordinates &&
        activeStates.contains(trip.estado.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TropiMotos Driver'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<DriverTripProvider>(
          builder: (context, provider, _) {
            final tripForMap = _getTripForMap(provider.trips);

            return RefreshIndicator(
              onRefresh: provider.loadTrips,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (tripForMap != null) _DriverTopMapSection(trip: tripForMap),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F0F0F), Color(0xFF242424)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.nombre ?? 'Chofer',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                user?.email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                              const SizedBox(height: 14),
                              RoleBadge(role: user?.role),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isAvailable ? 'Disponible' : 'No disponible',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _isAvailable
                                                ? 'Estas recibiendo solicitudes nuevas.'
                                                : 'No se mostraran viajes mientras estes desconectado.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.72),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Switch.adaptive(
                                      value: _isAvailable,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAvailable = value;
                                        });
                                      },
                                      activeThumbColor: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Viajes solicitados',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (provider.isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Actualizacion automatica cada 5 segundos.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        if (_acceptedTrip != null) ...[
                          _AcceptedTripCard(
                            trip: _acceptedTrip!,
                            isStarting: _isStartingTrip,
                            onStart: _startTrip,
                          ),
                          const SizedBox(height: 18),
                        ],
                        if (_isAvailable && provider.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        if (!_isAvailable)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.pause_circle_outline, size: 52, color: colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  'Estas no disponible',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Activa el switch superior para volver a ver viajes solicitados.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        else if (!provider.isLoading && provider.trips.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, size: 52, color: colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay viajes solicitados',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        else
                          ...provider.trips.map(
                            (trip) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _DriverTripCard(
                                trip: trip,
                                onAccept: trip.estado == 'SOLICITADO'
                                    ? () => _acceptTrip(context, trip)
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DriverTripCard extends StatelessWidget {
  final DriverTrip trip;
  final VoidCallback? onAccept;

  const _DriverTripCard({required this.trip, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estado: ${trip.estado}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: trip.estado == 'ACEPTADO'
                      ? const Color(0xFF00C853).withValues(alpha: 0.16)
                      : colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  trip.estado,
                  style: TextStyle(
                    color: trip.estado == 'ACEPTADO' ? const Color(0xFF00C853) : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TripLine(label: 'Origen', value: trip.origen, icon: Icons.trip_origin),
          const SizedBox(height: 10),
          _TripLine(label: 'Destino', value: trip.destino, icon: Icons.place_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              _TripMetric(label: 'Distancia', value: trip.distanciaLabel),
              const SizedBox(width: 10),
              _TripMetric(label: 'Tarifa', value: trip.tarifaLabel),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(trip.estado == 'ACEPTADO' ? 'Viaje aceptado' : 'Aceptar viaje'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TripLine({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripMetric extends StatelessWidget {
  final String label;
  final String value;

  const _TripMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _AcceptedTripCard extends StatelessWidget {
  final DriverTrip trip;
  final bool isStarting;
  final VoidCallback onStart;

  const _AcceptedTripCard({
    required this.trip,
    required this.isStarting,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C853).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Viaje aceptado',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (trip.pasajeroNombre?.isNotEmpty == true) ...[
            Text('Pasajero', style: theme.textTheme.bodySmall),
            Text(trip.pasajeroNombre!, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 10),
          ],
          _TripLine(label: 'Origen', value: trip.origen, icon: Icons.trip_origin),
          const SizedBox(height: 10),
          _TripLine(label: 'Destino', value: trip.destino, icon: Icons.place_outlined),
          const SizedBox(height: 14),
          Row(
            children: [
              _TripMetric(label: 'Tarifa', value: trip.tarifaLabel),
              const SizedBox(width: 10),
              _TripMetric(label: 'Distancia', value: trip.distanciaLabel),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isStarting || trip.estado == 'INICIADO' ? null : onStart,
              icon: isStarting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(trip.estado == 'INICIADO' ? 'Viaje en curso' : 'Iniciar viaje'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverTopMapSection extends StatefulWidget {
  final DriverTrip trip;

  const _DriverTopMapSection({required this.trip});

  @override
  State<_DriverTopMapSection> createState() => _DriverTopMapSectionState();
}

class _DriverTopMapSectionState extends State<_DriverTopMapSection> {
  final MapController _mapController = MapController();

  LatLng get _passengerPoint => LatLng(
        widget.trip.origenLatitud!,
        widget.trip.origenLongitud!,
      );

  LatLng get _destinationPoint => LatLng(
        widget.trip.destinoLatitud!,
        widget.trip.destinoLongitud!,
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitMap();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _DriverTopMapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip.idViaje != widget.trip.idViaje) {
      _fitMap();
    }
  }

  void _fitMap() {
    final bounds = LatLngBounds.fromPoints([
      _passengerPoint,
      _destinationPoint,
    ]);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _passengerPoint,
          initialZoom: 15,
          onMapReady: _fitMap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tropimotos.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_passengerPoint, _destinationPoint],
                strokeWidth: 4,
                color: colorScheme.primary,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _passengerPoint,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const _DriverMapMarker(
                  emoji: '📍',
                  backgroundColor: Color(0xFF009688),
                ),
              ),
              Marker(
                point: _destinationPoint,
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const _DriverMapMarker(
                  emoji: '🏁',
                  backgroundColor: Color(0xFFFFC107),
                ),
              ),
            ],
          ),
          RichAttributionWidget(
            attributions: const [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverMapMarker extends StatelessWidget {
  final String emoji;
  final Color backgroundColor;

  const _DriverMapMarker({
    required this.emoji,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
