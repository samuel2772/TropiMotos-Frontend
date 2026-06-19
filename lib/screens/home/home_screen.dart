import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/ride_estimate.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../services/trip_service.dart';
import '../../widgets/request_driver_sheet.dart';
import '../../widgets/role_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final TripService _tripService = TripService();
  final MapController _mapController = MapController();

  Position? _currentPosition;
  LatLng? _selectedDestination;
  LatLng _cameraTarget = const LatLng(-17.7833, -63.1821);
  RideEstimate? _estimate;
  String _destinationLabel = 'Selecciona un destino en el mapa';
  bool _isLoadingLocation = true;
  bool _isRequestingDriver = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadCurrentLocation());
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    final granted = await _locationService.requestPermission();

    if (!granted) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      _showMessage('Activa el GPS para ver tu ubicacion actual.');
      return;
    }

    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      setState(() => _isLoadingLocation = false);
      _showMessage('No se pudo obtener tu ubicacion actual.');
      return;
    }

    final currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = position;
      _cameraTarget = currentLatLng;
      _isLoadingLocation = false;
    });

    _mapController.move(currentLatLng, 15.5);
  }

  Future<void> _openDestinationSheet() async {
    final controller = TextEditingController(
      text: _selectedDestination == null || _destinationLabel.startsWith('Punto')
          ? ''
          : _destinationLabel,
    );

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el destino',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca un punto del mapa o usa el centro actual para fijar el destino.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Referencia del destino',
                  hintText: 'Ej: Av. Banzer y 4to anillo',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                  icon: const Icon(Icons.my_location_outlined),
                  label: const Text('Usar punto actual del mapa'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (_selectedDestination == null) {
      _setDestination(_cameraTarget, label: result);
      return;
    }

    if (result != null) {
      setState(() {
        _destinationLabel = result.isEmpty ? _fallbackLabel(_selectedDestination!) : result;
      });
    }
  }

  void _setDestination(LatLng destination, {String? label}) {
    if (_currentPosition == null) return;

    final estimate = _tripService.calculateEstimate(
      originLat: _currentPosition!.latitude,
      originLng: _currentPosition!.longitude,
      destinationLat: destination.latitude,
      destinationLng: destination.longitude,
    );

    setState(() {
      _selectedDestination = destination;
      _estimate = estimate;
      _destinationLabel = (label == null || label.isEmpty) ? _fallbackLabel(destination) : label;
    });
  }

  Future<void> _requestDriver() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (_currentPosition == null) {
      _showMessage('Primero debemos obtener tu ubicacion.');
      return;
    }
    if (_selectedDestination == null || _estimate == null) {
      _showMessage('Selecciona un destino para calcular el viaje.');
      return;
    }
    if (user == null) {
      _showMessage('No se pudo identificar al usuario autenticado.');
      return;
    }

    setState(() => _isRequestingDriver = true);

    final result = await _tripService.requestDriver(
      user: user,
      originLat: _currentPosition!.latitude,
      originLng: _currentPosition!.longitude,
      destinationLat: _selectedDestination!.latitude,
      destinationLng: _selectedDestination!.longitude,
      destinationLabel: _destinationLabel,
      estimate: _estimate!,
    );

    if (!mounted) return;
    setState(() => _isRequestingDriver = false);

    _showMessage(
      result['success'] == true
          ? (result['message'] as String? ?? 'Solicitud enviada')
          : (result['error'] as String? ?? 'No se pudo solicitar el chofer'),
      isError: result['success'] != true,
    );
  }

  String _fallbackLabel(LatLng destination) {
    return 'Punto (${destination.latitude.toStringAsFixed(4)}, ${destination.longitude.toStringAsFixed(4)})';
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          width: 56,
          height: 56,
          child: const _MapPin(
            icon: Icons.my_location,
            color: Color(0xFF111111),
            backgroundColor: Color(0xFFFFC107),
          ),
        ),
      );
    }

    if (_selectedDestination != null) {
      markers.add(
        Marker(
          point: _selectedDestination!,
          width: 56,
          height: 56,
          child: const _MapPin(
            icon: Icons.place,
            color: Colors.white,
            backgroundColor: Color(0xFF009688),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayName = user?.nombre ?? 'Pasajero';

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _cameraTarget,
              initialZoom: 14,
              onTap: (_, destination) => _setDestination(destination),
              onPositionChanged: (camera, _) {
                _cameraTarget = camera.center;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tropimotos.app',
              ),
              MarkerLayer(markers: _buildMarkers()),
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hola, $displayName',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user?.email ?? 'Usuario autenticado',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(width: 8),
                              RoleBadge(role: user?.role, fontSize: 11),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _HeaderIconButton(
                    icon: Icons.receipt_long_outlined,
                    onTap: () => context.go('/trips'),
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.person_outline,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 260,
            child: FloatingActionButton.small(
              heroTag: 'center_location_btn',
              backgroundColor: colorScheme.surface,
              onPressed: _loadCurrentLocation,
              child: Icon(Icons.my_location, color: colorScheme.primary),
            ),
          ),
          if (_isLoadingLocation)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomSheet: RequestDriverSheet(
        destinationText: _destinationLabel,
        helperText: _selectedDestination == null
            ? 'Toca un punto del mapa para seleccionar destino.'
            : 'Ya calculamos una tarifa aproximada para tu viaje.',
        estimate: _estimate,
        isRequesting: _isRequestingDriver,
        onSelectDestination: _openDestinationSheet,
        onRequestDriver: _requestDriver,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _MapPin({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 42,
        height: 42,
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
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
