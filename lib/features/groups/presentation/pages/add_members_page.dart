import 'package:flutter/material.dart';
import '../../data/group.entity.dart';
import '../../../../core/data/mock_data.dart';
import '../../../profile/data/user.entity.dart';

class AddMembersPage extends StatefulWidget {
  final Group group;

  const AddMembersPage({super.key, required this.group});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final _mock = MockData();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addMember() {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Digite um e-mail', isError: true);
      return;
    }

    // Verifica se o usuário existe
    final user = _mock.allUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => User(),
    );

    if (user.id == null) {
      _showSnackBar('Usuário não encontrado', isError: true);
      return;
    }

    // Verifica se já é membro
    if (widget.group.memberIds?.contains(user.id) ?? false) {
      _showSnackBar('${user.name} já é membro deste grupo', isError: true);
      return;
    }

    // TODO: integrar com backend — POST /groups/:id/members
    setState(() {
      _mock.addMemberToGroupByEmail(widget.group.id!, email);
    });

    _controller.clear();
    _showSnackBar('${user.name} adicionado ao grupo', isError: false);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFFF4757) : const Color(0xFF6C63FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMembers = _mock.getMembersOfGroup(widget.group.id!);

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Icon(Icons.group_add, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.group.name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${currentMembers.length} membros atualmente',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Adicionar novo membro",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Digite o e-mail de um usuário cadastrado",
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Input card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F1733), Color(0xFF1B2550)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF060B1A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "email@exemplo.com",
                              hintStyle: TextStyle(color: Colors.white24),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: _addMember,
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8F7BFF), Color(0xFF6C63FF)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  "Adicionar membro",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Current members
                  Text(
                    "Membros atuais (${currentMembers.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...currentMembers.map((user) => _memberChip(user)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberChip(User user) {
    String getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1733),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF8F7BFF),
              child: Text(
                getInitials(user.name ?? ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Color(0xFF00D6A1), size: 20),
          ],
        ),
      ),
    );
  }
}
