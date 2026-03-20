import 'package:flutter/material.dart';

class TaskCardWidget extends StatelessWidget {

  final String title;
  final String group;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const TaskCardWidget({
    super.key,
    required this.title,
    required this.group,
    this.isCompleted = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom:14),

        decoration: BoxDecoration(
          color: const Color(0xFF0F1733),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          children: [

            Icon(
              isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: isCompleted ? Colors.green : Colors.white54,
            ),

            const SizedBox(width:12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color: isCompleted ? Colors.white70 : Colors.white,
                      fontWeight: FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),

                  Text(
                    group,
                    style: const TextStyle(color: Colors.white54),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}