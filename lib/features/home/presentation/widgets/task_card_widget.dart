import 'package:flutter/material.dart';

class TaskCardWidget extends StatelessWidget {

  final String title;
  final String group;

  const TaskCardWidget({
    super.key,
    required this.title,
    required this.group
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom:14),

      decoration: BoxDecoration(
        color: const Color(0xFF0F1733),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          const Icon(Icons.circle_outlined,color: Colors.white54),

          const SizedBox(width:12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
    );
  }
}