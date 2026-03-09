import 'package:flutter/material.dart';

class GroupCardWidget extends StatelessWidget {

  final String title;
  final String members;
  final Gradient gradient;

  const GroupCardWidget({
    super.key,
    required this.title,
    required this.members,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right:16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: gradient,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            members,
            style: const TextStyle(color: Colors.white),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              fontSize:18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}