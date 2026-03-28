import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.radius = 40,
    this.onEditTap,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF5B7CFF),
          child: Text(
            _getInitials(name),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.5,
            ),
          ),
        ),
        if (onEditTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: radius * 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
