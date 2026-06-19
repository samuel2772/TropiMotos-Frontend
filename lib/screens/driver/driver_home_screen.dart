import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/driver_trip_request.dart';
import '../../providers/auth_provider.dart';
import '../../services/driver_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/driver_request_card.dart';
import '../../widgets/role_badge.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverService _driverService = DriverService();

  bool _isAvailable = true;
  bool _isLoadingRequests = true;
  bool _isUpdatingAvailability = false;
  List<DriverTripRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoadingRequests = true);
    final requests = await _driverService.getPendingRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _isLoadingRequests = false;
    });
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() => _isUpdatingAvailability = true);
    await _driverService.updateAvailability(value);
    if (!mounted) return;
    setState(() {
      _isAvailable = value;
      _isUpdatingAvailability = false;
    });
    _showMessage(value ? 'Ahora estas disponible.' : 'Ahora estas no disponible.');
  }

  Future<void> _acceptRequest(DriverTripRequest request) async {
    await _driverService.acceptRequest(request.id);
    if (!mounted) return;
    setState(() {
      _requests = _requests.where((item) => item.id != request.id).toList();
    });
    _showMessage('Solicitud aceptada: ${request.destino}');
  }

  Future<void> _rejectRequest(DriverTripRequest request) async {
    await _driverService.rejectRequest(request.id);
    if (!mounted) return;
    setState(() {
      _requests = _requests.where((item) => item.id != request.id).toList();
    });
    _showMessage('Solicitud rechazada.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Chofer'),
        actions: [
          IconButton(
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar solicitudes',
          ),
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRequests,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF111111), Color(0xFF2B2B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
                          child: Text(
                            user?.initials ?? '?',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.nombre ?? 'Chofer TropiMotos',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    RoleBadge(role: user?.role),
                    const SizedBox(height: 20),
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
                                  _isAvailable ? 'Disponible para viajes' : 'No disponible',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isAvailable
                                      ? 'Recibiras solicitudes nuevas en esta pantalla.'
                                      : 'Los pasajeros no veran tu unidad por ahora.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.68),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch.adaptive(
                            value: _isAvailable,
                            onChanged: _isUpdatingAvailability ? null : _toggleAvailability,
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
                      'Solicitudes pendientes',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_requests.length}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Datos simulados por ahora. Luego se conectaran al backend Spring Boot.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              if (_isLoadingRequests)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_requests.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.24)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 54, color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'No hay solicitudes pendientes',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cuando haya nuevas solicitudes de viaje, apareceran aqui.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else
                ..._requests.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: DriverRequestCard(
                      request: request,
                      onAccept: () => _acceptRequest(request),
                      onReject: () => _rejectRequest(request),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Cerrar Sesion',
                icon: Icons.logout,
                outlined: true,
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
