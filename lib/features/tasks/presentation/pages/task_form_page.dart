import 'package:flutter/material.dart';
import 'package:team_flow/features/groups/data/group.entity.dart';
import 'package:uuid/uuid.dart';
import '../../domain/task.dart';
import '../../../../core/backend/service/taskService.dart';
import '../../../../core/backend/persistence/firebase/FirebaseGroupRepository.dart'; // 1. Import do repositório real
import '../../../auth/data/user_session.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;

  const TaskFormPage({super.key, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _taskService = TaskService();
  // 2. Instanciando o repositório real de grupos através do padrão Singleton que você criou
  final _groupRepository = FirebaseGroupRepository.instance; 

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.media;
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = TimeOfDay.now();
  
  String? _selectedGroupId; // Mudado para Nullable para controlar o estado inicial
  List<_GroupOption> _groupOptions = [];
  
  bool _isSaving = false;
  late Future<List<Group>> _groupsFuture; // Armazena a requisição assíncrona dos grupos

  bool get _isEditing => widget.task != null;

  // Busca o ID do usuário logado na sessão real do app
  String get _userId => UserSession().currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();

    // 3. Dispara a busca dos grupos reais vinculados ao usuário logado
    _groupsFuture = _loadRealGroups();

    if (_isEditing) {
      final t = widget.task!;
      _titleController.text = t.title ?? '';
      _descController.text = t.description ?? '';
      _priority = t.priority;
      _selectedGroupId = t.groupId;
      if (t.dueDate != null) {
        _dueDate = t.dueDate!;
        _dueTime = TimeOfDay.fromDateTime(t.dueDate!);
      }
    }
  }

  // 4. Método auxiliar para buscar os grupos reais do Firebase
  Future<List<Group>> _loadRealGroups() async {
    try {
      // Busca no Firebase filtrando os grupos onde o usuário atual é membro
      final groups = await _groupRepository.getByStringColumn('memberIds', _userId);
      
      setState(() {
        _groupOptions = groups
            .map((g) => _GroupOption(id: g.id!, name: g.name ?? ''))
            .toList();

        // Se não for edição e houver grupos, pré-seleciona o primeiro da lista
        if (!_isEditing && _groupOptions.isNotEmpty) {
          _selectedGroupId = _groupOptions.first.id;
        }
      });
      return groups;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String get _selectedGroupName {
    try {
      return _groupOptions.firstWhere((g) => g.id == _selectedGroupId).name;
    } catch (_) {
      return '';
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Digite o título da tarefa');
      return;
    }

    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) {
      _showSnackBar('Selecione um grupo para associar esta tarefa');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final task = Task(
        id: _isEditing ? widget.task!.id : const Uuid().v4(),
        userId: _userId,
        title: title,
        description: _descController.text.trim(),
        groupId: _selectedGroupId, // ID selecionado dinamicamente do Dropdown
        groupName: _selectedGroupName,
        dueDate: dueDateTime,
        priority: _priority,
        isCompleted: _isEditing ? widget.task!.isCompleted : false,
      );

      Task? savedTask;
      if (_isEditing) {
        savedTask = await _taskService.updateTask(task, _userId);
      } else {
        // CORREÇÃO: Passando as propriedades corretas que o seu TaskService configurado exige
        await _taskService.createTask(task, _selectedGroupId, _userId);
        savedTask = task;
      }

      if (mounted) Navigator.pop(context, savedTask);
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao salvar tarefa: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1733),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir tarefa', style: TextStyle(color: Colors.white)),
        content: const Text('Tem certeza que deseja excluir esta tarefa?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await _taskService.deleteTask(_userId, widget.task!.id!);
      if (mounted) Navigator.pop(context, 'delete');
    } catch (e) {
      if (mounted) _showSnackBar('Erro ao excluir tarefa: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF4757),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF0F1733),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF0F1733),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

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
    if (_groupOptions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1733),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Nenhum grupo disponível',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1733),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGroupId,
          isExpanded: true,
          dropdownColor: const Color(0xFF0F1733),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
          style: const TextStyle(color: Colors.white),
          items: _groupOptions.map((g) {
            return DropdownMenuItem(
              value: g.id,
              child: Row(
                children: [
                  const Icon(Icons.group, color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Text(g.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedGroupId = value);
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
          // Header Gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3B3B98)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    if (_isEditing)
                      IconButton(
                        onPressed: _isSaving ? null : _confirmDelete,
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
                  _isEditing ? 'Atualize os dados da tarefa' : 'Preencha os dados da tarefa',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // Corpo do Formulário envelopado no FutureBuilder
          Expanded(
            child: FutureBuilder<List<Group>>(
              future: _groupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar grupos do Firebase',
                      style: TextStyle(color: Colors.redAccent.shade100),
                    ),
                  );
                }

                return SingleChildScrollView(
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
                      const Text('Prioridade', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      _buildPrioritySelector(),
                      const SizedBox(height: 20),
                      const Text('Grupo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 10),
                      _buildGroupSelector(), // Carrega os itens reativos gerados pelo _loadRealGroups
                      const SizedBox(height: 20),
                      const Text('Data e hora', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                                    const Icon(Icons.calendar_today, color: Colors.white38, size: 20),
                                    const SizedBox(width: 10),
                                    Text(_formatDate(_dueDate), style: const TextStyle(color: Colors.white)),
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
                                    const Icon(Icons.access_time, color: Colors.white38, size: 20),
                                    const SizedBox(width: 10),
                                    Text(_formatTime(_dueTime), style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      // Botão de Envio
                      SizedBox(
                        width: double.infinity,
                        child: InkWell(
                          onTap: _isSaving ? null : _save,
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isSaving
                                    ? [const Color(0xFF555555), const Color(0xFF333333)]
                                    : [const Color(0xFF8F7BFF), const Color(0xFF6C63FF)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupOption {
  final String id;
  final String name;
  const _GroupOption({required this.id, required this.name});
}