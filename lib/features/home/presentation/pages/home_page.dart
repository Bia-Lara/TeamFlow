import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/task_card_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                    value: "24",
                    icon: Icons.check_box_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4E3BFF), Color(0xFF2A2C7C)],
                    ),
                  ),

                  StatCardWidget(
                    title: "Pendentes",
                    value: "8",
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

              const TaskCardWidget(
                title: "Redesign da landing page",
                group: "Design"
              ),

              const TaskCardWidget(
                title: "Corrigir bug no login",
                group: "Dev"
              ),
            ],
          ),
        ),
      ),
    );
  }
}