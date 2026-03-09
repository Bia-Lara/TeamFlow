import 'package:flutter/material.dart';

class StatCardWidget extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 160,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,color: Colors.white),
          ),

          const SizedBox(height:14),

          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height:8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}