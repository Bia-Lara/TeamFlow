import 'package:flutter/material.dart';
import '../../../profile/data/user.entity.dart';

class MemberTile extends StatelessWidget {
  final User user;

  const MemberTile({super.key, required this.user});

  String getInitials(String name) {
    final parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple,
        child: Text(
          getInitials(user.name ?? ""),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        user.name ?? "",
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Membro",
        style: TextStyle(color: Colors.white54),
      ),
      trailing: const Icon(Icons.more_vert, color: Colors.white54),
    );
  }
}