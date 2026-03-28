import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int totalTasks;
  final int totalGroups;
  final int completedPercent;

  const ProfileStatsCard({
    super.key,
    required this.totalTasks,
    required this.totalGroups,
    required this.completedPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1733),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(totalTasks.toString(), 'Tarefas'),
          _divider(),
          _statItem(totalGroups.toString(), 'Grupos'),
          _divider(),
          _statItem('$completedPercent%', 'Concluídas',
              valueColor: const Color(0xFF00D6A1)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
    );
  }
}
