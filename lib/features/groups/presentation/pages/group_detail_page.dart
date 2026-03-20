import 'package:flutter/material.dart';
import '../../data/group.entity.dart';
import 'add_members_page.dart';
import '../../../profile/data/user.entity.dart';
import '../widgets/members_list.dart';

class GroupDetailPage extends StatelessWidget {

  final Group group;

  const GroupDetailPage({super.key, required this.group});

  @override
  Widget build(BuildContext context) {

    final membersCount = group.memberIds?.length ?? 0;

    final users = [
      User(id: "1", name: "João Dias"),
      User(id: "2", name: "Ana Santos"),
      User(id: "3", name: "Maria Rosa"),
    ];


    String getInitials(String name) {
      final parts = name.trim().split(" ");

      if (parts.length == 1) {
        return parts[0][0].toUpperCase();
      }

      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    User? getUserById(String id) {
      try {
        return users.firstWhere((u) => u.id == id);
      } catch (e) {
        return null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),

      body: SingleChildScrollView(
        child: Column(
          children: [

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

                     Row(
                        children: [

                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddMembersPage(group: group),
                                ),
                              );
                            },
                            icon: const Icon(Icons.group_add, color: Colors.white),
                          ),

                          const SizedBox(width: 12),

                          const Icon(Icons.settings, color: Colors.white),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    group.name ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    group.description ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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

                  _statItem("Membros", membersCount.toString()),
                  _divider(),
                  _statItem("Tarefas", "0"),
                  _divider(),
                  _statItem("Progresso", "0%"),
                ],
              ),
            ),

            const SizedBox(height: 30),

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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMembersPage(group: group),
                        ),
                      );
                    },
                    child: const Text("Gerenciar"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: membersCount,
              itemBuilder: (context, index) {

                final memberId = group.memberIds![index];
                final user = getUserById(memberId);

                if (user == null) return const SizedBox();

                return MemberTile(user: user);
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