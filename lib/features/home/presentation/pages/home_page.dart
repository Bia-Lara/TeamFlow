import 'package:flutter/material.dart';
import 'package:team_flow/core/backend/service/GroupService.dart'; // Importando seu GroupService
import '../widgets/header_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/group_card_widget.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/widgets/task_list_card.dart';
import '../../../../core/backend/service/taskService.dart';
import '../../../groups/data/group.entity.dart';
import '../../../../core/notifications/tab_change_notification.dart';
import '../../../auth/data/user_session.dart';
import '../../../groups/presentation/pages/group_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskService = TaskService();
  final _groupService = GroupService(); // Instanciando seu GroupService real

  List<Group> _groups = [];
  bool _isLoadingGroups = false;

  // Força o ID vindo estritamente da sessão do usuário conectado
  String get _userId => UserSession().currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserGroups();
  }

  /// Busca os grupos/casas reais do usuário logado no Firestore
  Future<void> _loadUserGroups() async {
    if (_userId.isEmpty) return;
    
    setState(() => _isLoadingGroups = true);
    try {
      final userGroups = await _groupService.getGroupsByUser(_userId);
      if (mounted) {
        setState(() {
          _groups = userGroups;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar grupos: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  void _goToTab(int index) {
    TabChangeNotification(index).dispatch(context);
  }

  Future<void> _toggleTask(Task task) async {
    try {
    final updatedStatus = !task.isCompleted;
    
    await _taskService.updateTask(task.copyWith(isCompleted: updatedStatus), _userId,);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: $e'),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    }
  }

  static const _groupGradients = [
    LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)]),
    LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF00A8A8)]),
    LinearGradient(colors: [Color(0xFFFFB75E), Color(0xFFED8F03)]),
    LinearGradient(colors: [Color(0xFF00D6A1), Color(0xFF00A878)]),
    LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: StreamBuilder<List<Task>>(
          stream: _taskService.streamUserTasks(_userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar tarefas:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final tasks = snapshot.data ?? [];
            final pendingCount = tasks.where((t) => !t.isCompleted).length;

            final displayTasks = List<Task>.from(tasks)
              ..sort((a, b) {
                if (a.isCompleted != b.isCompleted) {
                  return a.isCompleted ? 1 : -1;
                }
                return (b.dueDate ?? DateTime(2000))
                    .compareTo(a.dueDate ?? DateTime(2000));
              });
            final recentTasks = displayTasks.take(5).toList();

            final isLoadingTasks = snapshot.connectionState == ConnectionState.waiting;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  const HeaderWidget(),
                  const SizedBox(height: 30),
                  
                  // Bloco de Estatísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatCardWidget(
                        title: "Tarefas",
                        value: isLoadingTasks ? '...' : tasks.length.toString(),
                        icon: Icons.check_box_outlined,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4E3BFF), Color(0xFF2A2C7C)],
                        ),
                      ),
                      StatCardWidget(
                        title: "Pendentes",
                        value: isLoadingTasks ? '...' : pendingCount.toString(),
                        icon: Icons.access_time,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Seção Meus Grupos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Meus Grupos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goToTab(2),
                        child: const Text(
                          "Ver todos",
                          style: TextStyle(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Listagem Horizontal de Grupos
                  SizedBox(
                    height: 130,
                    child: _isLoadingGroups
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C63FF),
                              strokeWidth: 2,
                            ),
                          )
                        : _groups.isEmpty
                            ? const Center(
                                child: Text(
                                  'Você não participa de nenhuma casa.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              )
                            : ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: _groups.length,
  itemBuilder: (context, index) {
    final group = _groups[index];
    final memberCount = group.memberIds?.length ?? 0;
    final gradient = _groupGradients[index % _groupGradients.length];
    
    return GestureDetector(
      onTap: () async {
        // Redireciona para a tela de detalhes enviando o grupo selecionado
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailPage(group: group),
          ),
        );
        // Quando você voltar da tela de detalhes, recarrega os grupos 
        // caso algum membro tenha sido adicionado ou removido por lá
        _loadUserGroups();
      },
      child: GroupCardWidget(
        title: group.name ?? '',
        members: '$memberCount membros',
        gradient: gradient,
      ),
    );
  },
) ,
                  ),
                  const SizedBox(height: 30),
                  
                  // Seção Tarefas Recentes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tarefas Recentes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goToTab(1),
                        child: const Text(
                          "Ver todas",
                          style: TextStyle(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Listagem de Tarefas Recentes
                  if (isLoadingTasks)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (recentTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Nenhuma tarefa ainda.',
                        style: TextStyle(color: Colors.white38),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentTasks.length,
                      itemBuilder: (context, index) {
                        final task = recentTasks[index];
                        return TaskListCard(
                          task: task,
                          onToggle: () => _toggleTask(task),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}