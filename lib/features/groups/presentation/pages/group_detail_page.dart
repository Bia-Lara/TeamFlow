import 'package:flutter/material.dart';
import '../../data/group.entity.dart';
import 'add_members_page.dart';
import '../../../profile/data/user.entity.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/pages/task_form_page.dart';
import '../../../tasks/presentation/widgets/task_list_card.dart';
import '../widgets/members_list.dart';
import '../../../../core/data/mock_data.dart';

class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final _mock = MockData();

  List<User> get _members => _mock.getMembersOfGroup(widget.group.id!);
  List<Task> get _groupTasks => _mock.getTasksForGroup(widget.group.id!);

  void _removeMember(User user) {
    setState(() {
      _mock.removeMemberFromGroup(widget.group.id!, user.id!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user.name} removido do grupo'),
        backgroundColor: const Color(0xFF6C63FF),
      ),
    );
  }

  void _openEditTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
    if (result == null) return;
    if (result is String && result == 'delete') {
      setState(() {
        _mock.tasks.removeWhere((t) => t.id == task.id);
      });
    } else if (result is Task) {
      setState(() {
        final index = _mock.tasks.indexWhere((t) => t.id == result.id);
        if (index != -1) _mock.tasks[index] = result;
      });
    }
  }

  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final members = _members;
    final groupTasks = _groupTasks;
    final completedCount = groupTasks.where((t) => t.isCompleted).length;
    final progress = groupTasks.isNotEmpty
        ? ((completedCount / groupTasks.length) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SingleChildScrollView(
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
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMembersPage(group: widget.group),
                            ),
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.group_add, color: Colors.white),
                      ),
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
                    widget.group.description ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stats
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
                  _statItem("Membros", members.length.toString()),
                  _divider(),
                  _statItem("Tarefas", groupTasks.length.toString()),
                  _divider(),
                  _statItem("Progresso", "$progress%"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tarefas do grupo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tarefas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${groupTasks.length} tarefas",
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (groupTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Nenhuma tarefa neste grupo',
                  style: TextStyle(color: Colors.white38),
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

            // Membros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Membros",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMembersPage(group: widget.group),
                        ),
                      );
                      setState(() {});
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
              itemCount: members.length,
              itemBuilder: (context, index) {
                final user = members[index];
                return MemberTile(
                  user: user,
                  onRemove: () => _removeMember(user),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white24,
    );
  }
}
