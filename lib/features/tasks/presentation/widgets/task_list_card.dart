import 'package:flutter/material.dart';
import '../../domain/task.dart';
import 'priority_badge.dart';

class TaskListCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskListCard({
    super.key,
    required this.task,
    this.onToggle,
    this.onTap,
  });

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1733), Color(0xFF1B2550)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: task.isCompleted
                        ? const Color(0xFF00D6A1)
                        : Colors.white38,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title ?? '',
                        style: TextStyle(
                          color: task.isCompleted
                              ? Colors.white54
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            task.groupName ?? '',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          if (task.dueDate != null) ...[
                            const Text(
                              '  ·  ',
                              style: TextStyle(color: Colors.white38),
                            ),
                            Text(
                              _formatTime(task.dueDate),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PriorityBadge(priority: task.priority),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
