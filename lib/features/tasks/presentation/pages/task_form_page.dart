import 'package:flutter/material.dart';
import '../../domain/task.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.media;
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  String _selectedGroup = 'Geral';

  final List<String> _groups = ['Design', 'Dev', 'Geral', 'Marketing'];

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.task!;
      _titleController.text = t.title ?? '';
      _descController.text = t.description ?? '';
      _priority = t.priority;
      _selectedGroup = t.groupName ?? 'Geral';
      if (t.dueDate != null) {
        _dueDate = t.dueDate!;
        _dueTime = TimeOfDay.fromDateTime(t.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    final task = Task(
      id: _isEditing ? widget.task!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _isEditing ? widget.task!.userId : '1',
      title: title,
      description: _descController.text.trim(),
      groupId: _isEditing ? widget.task!.groupId : null,
      groupName: _selectedGroup,
      dueDate: dueDateTime,
      priority: _priority,
      isCompleted: _isEditing ? widget.task!.isCompleted : false,
    );

    Navigator.pop(context, task);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF0F1733),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF0F1733),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1733),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Excluir tarefa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja excluir esta tarefa?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha dialog
              Navigator.pop(context, 'delete'); // volta com sinal de delete
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1733),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: TaskPriority.values.map((p) {
        final isActive = _priority == p;
        Color color;
        String label;
        switch (p) {
          case TaskPriority.alta:
            color = const Color(0xFFFF4757);
            label = 'Alta';
            break;
          case TaskPriority.media:
            color = const Color(0xFFFFBE21);
            label = 'Média';
            break;
          case TaskPriority.baixa:
            color = const Color(0xFF00D6A1);
            label = 'Baixa';
            break;
        }
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : const Color(0xFF0F1733),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? color : Colors.white12,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? color : Colors.white54,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1733),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGroup,
          isExpanded: true,
          dropdownColor: const Color(0xFF0F1733),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
          style: const TextStyle(color: Colors.white),
          items: _groups.map((g) {
            return DropdownMenuItem(
              value: g,
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Text(g),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedGroup = value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: Column(
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
                    if (_isEditing)
                      IconButton(
                        onPressed: _confirmDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing ? 'Editar tarefa' : 'Nova tarefa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isEditing
                      ? 'Atualize os dados da tarefa'
                      : 'Preencha os dados da tarefa',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    hint: 'Título da tarefa',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descController,
                    hint: 'Descrição (opcional)',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Prioridade',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPrioritySelector(),

                  const SizedBox(height: 20),
                  const Text(
                    'Grupo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildGroupSelector(),

                  const SizedBox(height: 20),
                  const Text(
                    'Data e hora',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1733),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white38, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(_dueDate),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1733),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white38, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _formatTime(_dueTime),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8F7BFF), Color(0xFF6C63FF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _isEditing ? 'Salvar alterações' : 'Criar tarefa',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
