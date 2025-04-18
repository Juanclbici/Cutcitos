import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String estado;

  const StatusChip({super.key, required this.estado});

  Color _getColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmado':
        return Colors.amber;
      case 'entregado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_top;
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'entregado':
        return Icons.local_shipping;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(estado);
    final icon = _getIcon(estado);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Chip(
          label: Text(
            estado.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color.withOpacity(0.15),
        ),
      ],
    );
  }
}
