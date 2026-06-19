import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const yapacani = LatLng(-17.4050, -63.8750);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa TropiMotos'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: yapacani,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tropimotos_app',
          ),
          const MarkerLayer(
            markers: [
              Marker(
                point: yapacani,
                width: 50,
                height: 50,
                child: Icon(
                  Icons.location_pin,
                  size: 45,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}