import 'package:flutter/material.dart';
import 'package:team_flow/core/backend/service/GroupService.dart';
import 'package:team_flow/core/backend/service/userService.dart';
import 'package:team_flow/core/backend/service/taskService.dart'; // Import do seu TaskService
import '../../../auth/data/user_session.dart';
import '../../data/group.entity.dart';
import 'add_members_page.dart';
import '../../../profile/data/user.entity.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/pages/task_form_page.dart';
import '../../../tasks/presentation/widgets/task_list_card.dart';
import '../widgets/members_list.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final UserService _userService = UserService();
  final GroupService _groupService = GroupService();
  final TaskService _taskService = TaskService(); // Instanciando o Service de tarefas

  List<User> _members = [];
  bool _isLoading = false;

  String get _userId => UserSession().currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Busca apenas os usuários reais correspondentes aos IDs contidos na entidade Group
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (widget.group.memberIds != null && widget.group.memberIds!.isNotEmpty) {
        List<User> loadedUsers = [];
        for (String id in widget.group.memberIds!) {
          final user = await _userService.userRepository.getById(id);
          loadedUsers.add(user);
        }
        _members = loadedUsers;
      } else {
        _members = [];
      }

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao carregar dados: ${e.toString().replaceAll("Exception: ", "")}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _removeMember(User user) async {
    final isSelf = user.id == _userId;
    setState(() => _isLoading = true);

    try {
      List<String> updatedMembers = List<String>.from(widget.group.memberIds ?? []);
      updatedMembers.remove(user.id);

      await _groupService.groupRepository.update(
        widget.group.copyWith(memberIds: updatedMembers),
      );

      widget.group.memberIds?.remove(user.id);

      if (isSelf) {
        if (mounted) {
          _showSnackBar('Você saiu do grupo');
          Navigator.pop(context);
        }
        return;
      }

      _showSnackBar('${user.name} removido do grupo');
      _loadData();
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao remover membro: ${e.toString().replaceAll("Exception: ", "")}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openEditTask(Task task) async {
    // Abre o formulário enviando a tarefa clicada para o modo de edição
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
    // Como estamos usando StreamBuilder para as tarefas, não é mais necessário chamar o _loadData() aqui!
    // O banco atualiza e a tela escuta a mudança sozinha.
  }

  void _toggleTask(Task task) async {
    try {
      // Inverte o estado de conclusão e atualiza usando a lógica centralizada do seu updateTask
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _taskService.updateTask(updatedTask, _userId);
    } catch (e) {
      _showSnackBar('Erro ao atualizar tarefa: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6C63FF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: _isLoading && _members.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : StreamBuilder<List<Task>>(
              // 1. Injetamos o stream de tarefas do grupo que criamos no TaskService
              stream: _taskService.streamGroupTasks(widget.group.id ?? ''),
              builder: (context, snapshot) {
                final groupTasks = snapshot.data ?? [];
                
                // 2. Cálculo dinâmico do progresso baseado no Stream em tempo real
                final completedCount = groupTasks.where((t) => t.isCompleted).length;
                final progress = groupTasks.isNotEmpty
                    ? ((completedCount / groupTasks.length) * 100).round()
                    : 0;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header gradient
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
                                IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddMembersPage(group: widget.group)),
                                    );
                                    _loadData();
                                  },
                                  icon: const Icon(Icons.group_add, color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              widget.group.name ?? "",
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.group.description ?? "",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F1733),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem("Membros", _members.length.toString()),
                            _divider(),
                            _statItem("Tarefas", groupTasks.length.toString()),
                            _divider(),
                            _statItem("Progresso", "$progress%"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Seção de Cabeçalho das Tarefas
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Tarefas",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${groupTasks.length} tarefas",
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. Renderização condicional da lista vinda do Stream
                      if (snapshot.connectionState == ConnectionState.waiting && groupTasks.isEmpty)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                        ))
                      else if (groupTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Nenhuma tarefa neste grupo', style: TextStyle(color: Colors.white38)),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupTasks.length,
                            itemBuilder: (context, index) {
                              final task = groupTasks[index];
                              return TaskListCard(
                                task: task,
                                onToggle: () => _toggleTask(task),
                                onTap: () => _openEditTask(task),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Seção de Membros
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Membros",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddMembersPage(group: widget.group)),
                                );
                                _loadData();
                              },
                              child: const Text("Adicionar"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final user = _members[index];
                          return MemberTile(
                            user: user,
                            onRemove: () => _removeMember(user),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _statItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white54)),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }
}