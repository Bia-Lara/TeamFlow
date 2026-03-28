import 'package:flutter/material.dart';
import '../../data/user.entity.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
import '../../../../core/data/mock_data.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _mock = MockData();

  User get _user => _mock.currentUser;

  int get _totalTasks => _mock.getTasksForUser(_user.id!).length;
  int get _completedTasks =>
      _mock.getTasksForUser(_user.id!).where((t) => t.isCompleted).length;
  int get _groupCount => _mock.getGroupsForUser(_user.id!).length;
  int get _completedPercent =>
      _totalTasks > 0 ? ((_completedTasks / _totalTasks) * 100).round() : 0;

  void _openEditProfile() async {
    final result = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(user: _user),
      ),
    );
    if (result != null) {
      setState(() {
        _mock.currentUser = result;
        // Atualiza também na lista de users
        final idx = _mock.allUsers.indexWhere((u) => u.id == result.id);
        if (idx != -1) _mock.allUsers[idx] = result;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1733),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sair da conta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: integrar com backend — limpar sessão/token
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _confirmLogout,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1733),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white54,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // User info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F1733), Color(0xFF1B2550)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(
                          name: _user.name ?? '',
                          radius: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user.name ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user.email ?? '',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Membro',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$_groupCount grupos',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProfileStatsCard(
                      totalTasks: _totalTasks,
                      totalGroups: _groupCount,
                      completedPercent: _completedPercent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Menu items
              ProfileMenuItem(
                icon: Icons.person_outline,
                iconColor: const Color(0xFF6C63FF),
                title: 'Editar Perfil',
                subtitle: 'Nome, e-mail e dados pessoais',
                onTap: _openEditProfile,
              ),

              ProfileMenuItem(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFF00D6A1),
                title: 'Aparência',
                subtitle: 'Tema e preferências visuais',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Em breve'),
                      backgroundColor: Color(0xFF6C63FF),
                    ),
                  );
                },
              ),

              ProfileMenuItem(
                icon: Icons.help_outline,
                iconColor: const Color(0xFF00C2FF),
                title: 'Ajuda',
                subtitle: 'Dúvidas e suporte',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Em breve'),
                      backgroundColor: Color(0xFF6C63FF),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
