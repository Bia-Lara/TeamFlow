import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/task_card_widget.dart';
import '../../../tasks/domain/task.dart';
import '../../../groups/data/group.entity.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/notifications/tab_change_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _mock = MockData();

  List<Task> get _tasks => _mock.getTasksForUser(_mock.currentUser.id!);
  List<Group> get _groups => _mock.getGroupsForUser(_mock.currentUser.id!);

  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _goToTab(int index) {
    TabChangeNotification(index).dispatch(context);
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
    final tasks = _tasks;
    final groups = _groups;
    final pendingCount = tasks.where((t) => !t.isCompleted).length;
    // Mostra só as 5 tarefas mais recentes (pendentes primeiro)
    final recentTasks = List<Task>.from(tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return (b.dueDate ?? DateTime(2000)).compareTo(a.dueDate ?? DateTime(2000));
      });
    final displayTasks = recentTasks.take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const HeaderWidget(),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCardWidget(
                    title: "Tarefas",
                    value: tasks.length.toString(),
                    icon: Icons.check_box_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E3BFF), Color(0xFF2A2C7C)],
                    ),
                  ),
                  StatCardWidget(
                    title: "Pendentes",
                    value: pendingCount.toString(),
                    icon: Icons.access_time,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

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

              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final memberCount = group.memberIds?.length ?? 0;
                    final gradient = _groupGradients[index % _groupGradients.length];
                    return GroupCardWidget(
                      title: group.name ?? '',
                      members: '$memberCount membros',
                      gradient: gradient,
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayTasks.length,
                itemBuilder: (context, index) {
                  final task = displayTasks[index];
                  return TaskCardWidget(
                    title: task.title ?? "",
                    group: task.groupName ?? "",
                    isCompleted: task.isCompleted,
                    onToggle: () => _toggleTask(task),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
