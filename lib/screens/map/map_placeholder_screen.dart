import 'package:flutter/material.dart';
import '../../services/location_service.dart';

class MapPlaceholderScreen extends StatefulWidget {
  const MapPlaceholderScreen({super.key});

  @override
  State<MapPlaceholderScreen> createState() => _MapPlaceholderScreenState();
}

class _MapPlaceholderScreenState extends State<MapPlaceholderScreen> {
  final _locationService = LocationService();
  String? _currentAddress;
  bool _locationGranted = false;
  bool _checkingLocation = true;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _checkLocationStatus() async {
    final granted = await _locationService.isLocationGranted();
    if (granted) {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _locationGranted = true;
          _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, '
              'Lng: ${position.longitude.toStringAsFixed(4)}';
        });
      }
    }
    setState(() => _checkingLocation = false);
  }

  Future<void> _requestLocation() async {
    final granted = await _locationService.requestPermission();
    if (granted) {
      _checkLocationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
      ),
      body: SafeArea(
        child: _checkingLocation
            ? const Center(child: CircularProgressIndicator())
            : _locationGranted
                ? _buildMapReadyView(colorScheme)
                : _buildLocationPermissionView(context, colorScheme),
      ),
    );
  }

  Widget _buildMapReadyView(ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Google Maps',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'El mapa se activara cuando configures tu Google Maps API Key en AndroidManifest.xml',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Ubicacion actual:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentAddress ?? 'Obteniendo...',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStep('1', 'Obtener Google Maps API Key'),
              _buildStep('2', 'Agregar a AndroidManifest.xml'),
              _buildStep('3', 'Agregar google_maps_flutter al pubspec.yaml'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionView(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_searching,
              size: 80,
              color: colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Permiso de Ubicacion',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'TropiMotos necesita acceder a tu ubicacion para mostrar el mapa y solicitar viajes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _requestLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Activar Ubicacion'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
