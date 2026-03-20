import 'package:flutter/material.dart';
import '../../features/groups/presentation/pages/create_group_page.dart';

class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),

      decoration: const BoxDecoration(
        color: Color(0xFF0B1026),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -5),
          )
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          _buildItem(Icons.home_outlined, "Início", 0),

          _buildItem(Icons.check_box_outlined, "Tarefas", 1),

          _buildAddButton(context),

          _buildItem(Icons.groups_outlined, "Grupos", 2),

          _buildItem(Icons.person_outline, "Perfil", 3),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, int index) {

    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF6C63FF) : Colors.white54,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateGroupPage(),
          ),
        );
      },

      child: Container(
        height: 60,
        width: 60,

        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF8F7BFF)
            ],
          ),
        ),

        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}