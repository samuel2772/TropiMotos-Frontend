import 'package:flutter/material.dart';
import '../../models/user.dart';

class RoleBadge extends StatelessWidget {
  final UserRole? role;
  final double fontSize;

  const RoleBadge({
    super.key,
    this.role,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (role) {
      case UserRole.admin:
        bgColor = const Color(0xFF7C4DFF).withOpacity(0.15);
        textColor = const Color(0xFF7C4DFF);
        label = 'Administrador';
        icon = Icons.admin_panel_settings;
        break;
      case UserRole.chofer:
        bgColor = const Color(0xFF00BCD4).withOpacity(0.15);
        textColor = const Color(0xFF00BCD4);
        label = 'Chofer';
        icon = Icons.motorcycle;
        break;
      case UserRole.cliente:
      default:
        bgColor = colorScheme.primary.withOpacity(0.15);
        textColor = colorScheme.primary;
        label = 'Cliente';
        icon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
