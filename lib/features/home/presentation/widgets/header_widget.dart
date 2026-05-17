import 'package:flutter/material.dart';
import '../../../auth/data/user_session.dart';
import '../../../../core/data/mock_data.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockData();
    final user = UserSession().currentUser ?? mockData.currentUser;
    final initials =
        (user.name?.split(' ').map((e) => e[0]).join() ?? 'U').toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFF5B7CFF),
          child: Text(
            initials,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bem-vindo,",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            Text(
              user.name ?? 'Usuário',
              style: const TextStyle(
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
