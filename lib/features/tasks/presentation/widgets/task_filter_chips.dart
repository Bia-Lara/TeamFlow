import 'package:flutter/material.dart';

enum TaskFilter { todas, pendentes, concluidas }

class TaskFilterChips extends StatelessWidget {
  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  const TaskFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskFilter.values.map((filter) {
        final isActive = selected == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFF0F1733),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF6C63FF)
                      : Colors.white12,
                ),
              ),
              child: Text(
                _label(filter),
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white54,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.todas:
        return 'Todas';
      case TaskFilter.pendentes:
        return 'Pendentes';
      case TaskFilter.concluidas:
        return 'Concluídas';
    }
  }
}
