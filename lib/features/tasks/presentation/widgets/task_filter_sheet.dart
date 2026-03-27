import 'package:flutter/material.dart';
import '../../domain/task.dart';

class TaskFilterOptions {
  final TaskPriority? priority;
  final String? groupName;

  const TaskFilterOptions({this.priority, this.groupName});
}

class TaskFilterSheet extends StatefulWidget {
  final TaskFilterOptions current;
  final List<String> availableGroups;

  const TaskFilterSheet({
    super.key,
    required this.current,
    required this.availableGroups,
  });

  @override
  State<TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends State<TaskFilterSheet> {
  TaskPriority? _priority;
  String? _groupName;

  @override
  void initState() {
    super.initState();
    _priority = widget.current.priority;
    _groupName = widget.current.groupName;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1733),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtrar tarefas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    const TaskFilterOptions(),
                  );
                },
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Prioridade',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [null, ...TaskPriority.values].map((p) {
              final isActive = _priority == p;
              String label;
              if (p == null) {
                label = 'Todas';
              } else {
                switch (p) {
                  case TaskPriority.alta:
                    label = 'Alta';
                    break;
                  case TaskPriority.media:
                    label = 'Média';
                    break;
                  case TaskPriority.baixa:
                    label = 'Baixa';
                    break;
                }
              }
              return GestureDetector(
                onTap: () => setState(() => _priority = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF060B1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF6C63FF)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Grupo',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [null, ...widget.availableGroups].map((g) {
              final isActive = _groupName == g;
              return GestureDetector(
                onTap: () => setState(() => _groupName = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF6C63FF)
                        : const Color(0xFF060B1A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF6C63FF)
                          : Colors.white12,
                    ),
                  ),
                  child: Text(
                    g ?? 'Todos',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () {
                Navigator.pop(
                  context,
                  TaskFilterOptions(
                    priority: _priority,
                    groupName: _groupName,
                  ),
                );
              },
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
                    'Aplicar filtros',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
