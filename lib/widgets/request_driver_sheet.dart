import 'package:flutter/material.dart';

import '../models/ride_estimate.dart';
import 'custom_button.dart';
import 'ride_metric_chip.dart';

class RequestDriverSheet extends StatelessWidget {
  final String destinationText;
  final String helperText;
  final RideEstimate? estimate;
  final bool isRequesting;
  final VoidCallback onSelectDestination;
  final VoidCallback onRequestDriver;

  const RequestDriverSheet({
    super.key,
    required this.destinationText,
    required this.helperText,
    required this.estimate,
    required this.isRequesting,
    required this.onSelectDestination,
    required this.onRequestDriver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasEstimate = estimate != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 28,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Tu próximo viaje', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(helperText, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.place_outlined, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('¿A dónde quieres ir?', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 4),
                          Text(
                            destinationText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: onSelectDestination,
                      child: const Text('Elegir'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  RideMetricChip(
                    icon: Icons.payments_outlined,
                    label: 'Precio',
                    value: hasEstimate ? estimate!.priceLabel : '--',
                  ),
                  const SizedBox(width: 10),
                  RideMetricChip(
                    icon: Icons.route_outlined,
                    label: 'Distancia',
                    value: hasEstimate ? estimate!.distanceLabel : '--',
                  ),
                  const SizedBox(width: 10),
                  RideMetricChip(
                    icon: Icons.schedule_outlined,
                    label: 'Tiempo',
                    value: hasEstimate ? estimate!.durationLabel : '--',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'Solicitar chofer',
                onPressed: hasEstimate ? onRequestDriver : onSelectDestination,
                isLoading: isRequesting,
                icon: Icons.two_wheeler,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
