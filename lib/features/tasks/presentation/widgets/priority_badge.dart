import 'package:flutter/material.dart';
import '../../domain/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case TaskPriority.alta:
        return const Color(0xFFFF4757);
      case TaskPriority.media:
        return const Color(0xFFFFBE21);
      case TaskPriority.baixa:
        return const Color(0xFF00D6A1);
    }
  }

  String get _label {
    switch (priority) {
      case TaskPriority.alta:
        return 'Alta';
      case TaskPriority.media:
        return 'Média';
      case TaskPriority.baixa:
        return 'Baixa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
