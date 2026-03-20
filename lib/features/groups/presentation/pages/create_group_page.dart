import 'package:flutter/material.dart';
import '../../data/group.entity.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {

  final nameController = TextEditingController();
  final descController = TextEditingController();

  void createGroup() {

    final name = nameController.text.trim();
    final desc = descController.text.trim();

    if (name.isEmpty) return;

    final group = Group(
      name: name,
      description: desc,
      memberIds: [],
    );

    Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),

      body: Column(
        children: [

          // 🔥 HEADER PADRÃO
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
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  "Criar novo grupo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Organize sua equipe e tarefas",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 👇 FORM
          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                // 🧾 NOME
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1733),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),

                    decoration: const InputDecoration(
                      hintText: "Nome do grupo",
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.group, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 📝 DESCRIÇÃO
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1733),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,

                    decoration: const InputDecoration(
                      hintText: "Descrição (opcional)",
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.description, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🚀 BOTÃO
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: createGroup,
                    borderRadius: BorderRadius.circular(16),

                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8F7BFF), Color(0xFF6C63FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          "Criar grupo",
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
          )
        ],
      ),
    );
  }
}