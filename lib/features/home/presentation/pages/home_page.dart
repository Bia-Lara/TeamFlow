import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/task_card_widget.dart';
import '../../../tasks/domain/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks(); // 🔥 chama ao iniciar
  }

  Future<void> loadTasks() async {
    final response = [
      {
        "id": "1",
        "title": "Redesign da landing page",
        "groupId": "1",
        "groupName": "Design",
        "priority": "media",
        "isCompleted": false
      },
      {
        "id": "2",
        "title": "Corrigir bug no login",
        "groupId": "2",
        "groupName": "Dev",
        "priority": "alta",
        "isCompleted": true
      }
    ];

    setState(() {
      tasks = response.map((e) => Task.fromJson(e)).toList();
    });
  }

  void toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:20),

          child: ListView(
            children: [

              const SizedBox(height:20),
              const HeaderWidget(),
              const SizedBox(height:30),

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
                    value: tasks
                        .where((t) => !t.isCompleted)
                        .length
                        .toString(),
                    icon: Icons.access_time,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                  ),
                ],
              ),

              const SizedBox(height:30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Meus Grupos",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Ver todos",
                    style: TextStyle(color: Colors.purple),
                  )
                ],
              ),

              const SizedBox(height:20),

              SizedBox(
                height:130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [

                    GroupCardWidget(
                      title: "Design",
                      members: "5 membros",
                      gradient: LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)],
                      ),
                    ),

                    GroupCardWidget(
                      title: "Dev",
                      members: "8 membros",
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF00A8A8)],
                      ),
                    ),

                    GroupCardWidget(
                      title: "Marketing",
                      members: "3 membros",
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height:30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    "Tarefas Recentes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Ver todas",
                    style: TextStyle(color: Colors.purple),
                  )
                ],
              ),

              const SizedBox(height:20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {

                  final task = tasks[index];

                  return TaskCardWidget(
                    title: task.title ?? "",
                    group: task.groupName ?? "",
                    isCompleted: task.isCompleted,
                    onToggle: () => toggleTask(task),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}