import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/driver_trip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_trip_provider.dart';
import '../../widgets/role_badge.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
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
    final auth = context.read<AuthProvider>();
    final provider = context.read<DriverTripProvider>();
    final driverId = auth.user?.id.isNotEmpty == true ? auth.user!.id : '1';

    final success = await provider.acceptTrip(trip: trip, driverId: driverId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Viaje aceptado correctamente.' : 'No se pudo aceptar el viaje.'),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
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
      ),
      body: SafeArea(
        child: Consumer<DriverTripProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: provider.loadTrips,
              child: ListView(
                padding: const EdgeInsets.all(20),
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
                  if (provider.errorMessage != null)
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
                  if (!provider.isLoading && provider.trips.isEmpty)
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
                    ...provider.trips.map((trip) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _DriverTripCard(
                            trip: trip,
                            onAccept: trip.estado == 'SOLICITADO'
                                ? () => _acceptTrip(context, trip)
                                : null,
                          ),
                        )),
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
