import 'package:flutter/material.dart';
import 'package:team_flow/core/backend/service/GroupService.dart';
import 'package:team_flow/core/backend/service/userService.dart';
import '../../data/group.entity.dart';
import '../../../profile/data/user.entity.dart';

class AddMembersPage extends StatefulWidget {
  final Group group;

  const AddMembersPage({super.key, required this.group});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final _controller = TextEditingController();

  // Guarda os objetos de Usuário reais carregados do backend
  List<User> _currentMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGroupMembers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Busca os dados completos de cada usuário que está no grupo
  Future<void> _loadGroupMembers() async {
    if (widget.group.memberIds == null || widget.group.memberIds!.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      List<User> loadedUsers = [];
      for (String id in widget.group.memberIds!) {
        final user = await _userService.userRepository.getById(id);
        loadedUsers.add(user);
      }
      if (mounted) {
        setState(() {
          _currentMembers = loadedUsers;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao carregar membros: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addMember() async {
    final email = _controller.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Digite um e-mail', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Busca o usuário usando APENAS o método criado na UserService
      final user = await _userService.getUserByEmail(email);

      if (user.id == null) {
        _showSnackBar('Usuário inválido', isError: true);
        return;
      }

      // 2. Verifica se o ID retornado já está na lista local do widget
      if (widget.group.memberIds?.contains(user.id) ?? false) {
        _showSnackBar('${user.name} já é membro deste grupo', isError: true);
        return;
      }

      // 3. Adiciona o membro usando APENAS a GroupService
      await _groupService.addMemberToGroup(widget.group.id!, user.id!);

      // 4. Atualiza o estado da UI refletindo a mudança em tempo real
      if (mounted) {
        widget.group.memberIds ??= [];
        widget.group.memberIds!.add(user.id!);

        setState(() {
          _currentMembers.add(user);
        });

        _controller.clear();
        _showSnackBar('${user.name} adicionado ao grupo', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll("Exception: ", ""), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  '${_currentMembers.length} membros atualmente',
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
                            enabled: !_isLoading,
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
                            onTap: _isLoading ? null : _addMember,
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isLoading
                                      ? [Colors.grey, Colors.grey]
                                      : [const Color(0xFF8F7BFF), const Color(0xFF6C63FF)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
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
                    "Membros atuais (${_currentMembers.length})",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading && _currentMembers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                      ),
                    )
                  else
                    ..._currentMembers.map((user) => _memberChip(user)),
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
      if (parts.isEmpty || parts[0].isEmpty) return '?';
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