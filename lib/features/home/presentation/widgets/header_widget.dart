import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFF5B7CFF),
          child: Text(
            "JD",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(width: 12),

        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Bem-vindo,",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),

            Text(
              "Joao Dias",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const Spacer(),
      ],
    );
  }
}