import 'package:flutter/material.dart';
import '../../data/group.entity.dart';
import '../widgets/group_list_card.dart';
import 'group_detail_page.dart';
import 'create_group_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  List<Group> groups = [
    Group(
      id: "1",
      name: "Design Team",
      description: "UI/UX e design visual",
      memberIds: ["1", "2", "3"],
    ),
    Group(
      id: "2",
      name: "Desenvolvimento",
      description: "Backend e frontend",
      memberIds: ["1", "2"],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Grupos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                style: const TextStyle(color: Colors.white), // 👈 AQUI

                decoration: InputDecoration(
                  hintText: "Buscar grupos...",
                  hintStyle: const TextStyle(color: Colors.white54), // 👈 hint (opcional)

                  filled: true,
                  fillColor: const Color(0xFF0F1733),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {

                    final group = groups[index];

                    return GroupListCard(
                      group: group,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupDetailPage(group: group),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}