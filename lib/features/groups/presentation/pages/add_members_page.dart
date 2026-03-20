import 'package:flutter/material.dart';
import '../../data/group.entity.dart';

class AddMembersPage extends StatefulWidget {
  final Group group;

  const AddMembersPage({super.key, required this.group});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {

  final TextEditingController controller = TextEditingController();

  void addMember() {
    final email = controller.text.trim();

    if (email.isEmpty) return;

    widget.group.memberIds ??= [];
    widget.group.memberIds!.add(email);

    controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Membro adicionado com sucesso"),
        backgroundColor: Color(0xFF8F7BFF),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),

      body: Column(
        children: [

          // 🔥 HEADER IGUAL AO GROUP DETAIL
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
                  widget.group.description ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 👇 RESTANTE DA TELA
          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const Text(
                  "Adicionar novo membro",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F1733), Color(0xFF1B2550)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    children: [

                      TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),

                        decoration: InputDecoration(
                          hintText: "email@exemplo.com",
                          hintStyle: const TextStyle(color: Colors.white38),

                          prefixIcon: const Icon(Icons.email, color: Colors.white54),

                          filled: true,
                          fillColor: const Color(0xFF060B1A),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: addMember,
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
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}