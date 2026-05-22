import 'package:flutter/material.dart';
import '../../domain/task.dart';
import '../../data/task_service.dart';
import '../../../../core/data/mock_data.dart';
import '../widgets/task_list_card.dart';
import '../widgets/task_section_header.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/task_filter_sheet.dart';
import '../widgets/task_search_bar.dart';
import 'task_form_page.dart';
import '../../../auth/data/user_session.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _mock = MockData();
  final _taskService = TaskService();

  TaskFilter _filter = TaskFilter.todas;
  TaskFilterOptions _advancedFilter = const TaskFilterOptions();
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showSearch = false;

  final Map<String, bool> _expandedSections = {
    'hoje': true,
    'amanha': true,
    'concluidas': true,
    'atrasadas': true,
    'futuras': true,
  };

  String get _userId => UserSession().currentUser?.id ?? _mock.currentUser.id!;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _applyFilters(List<Task> tasks) {
    switch (_filter) {
      case TaskFilter.pendentes:
        tasks = tasks.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.concluidas:
        tasks = tasks.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.todas:
        break;
    }

    if (_advancedFilter.priority != null) {
      tasks =
          tasks.where((t) => t.priority == _advancedFilter.priority).toList();
    }

    if (_advancedFilter.groupName != null) {
      tasks =
          tasks.where((t) => t.groupName == _advancedFilter.groupName).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      tasks = tasks.where((t) {
        return (t.title?.toLowerCase().contains(q) ?? false) ||
            (t.groupName?.toLowerCase().contains(q) ?? false) ||
            (t.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return tasks;
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime? date) {
    if (date == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  bool _isOverdue(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date.isBefore(today);
  }

  bool _isFuture(DateTime? date) {
    if (date == null) return false;
    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));
    final start = DateTime(
      dayAfterTomorrow.year,
      dayAfterTomorrow.month,
      dayAfterTomorrow.day,
    );
    return date.isAfter(start) || date.isAtSameMomentAs(start);
  }

  Future<void> _toggleTask(Task task) async {
    try {
      if (task.isCompleted) {
        // Desmarca: usa updateTask
        await _taskService.updateTask(
          task.copyWith(isCompleted: false),
          _userId,
        );
      } else {
        // Marca como concluída
        await _taskService.completeTask(_userId, task.id!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar tarefa: $e'),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    }
  }

  void _openFilterSheet(List<Task> allTasks) async {
    final groups = allTasks
        .map((t) => t.groupName)
        .where((g) => g != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    final result = await showModalBottomSheet<TaskFilterOptions>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => TaskFilterSheet(
        current: _advancedFilter,
        availableGroups: groups,
      ),
    );

    if (result != null) {
      setState(() => _advancedFilter = result);
    }
  }

  void _openEditTask(Task task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
    // Não precisa fazer nada — o stream atualiza automaticamente
  }

  Widget _buildSection(String key, String title, List<Task> tasks) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final isExpanded = _expandedSections[key] ?? true;

    return Column(
      children: [
        TaskSectionHeader(
          title: title,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() => _expandedSections[key] = !isExpanded);
          },
        ),
        if (isExpanded)
          ...tasks.map((task) => TaskListCard(
                task: task,
                onToggle: () => _toggleTask(task),
                onTap: () => _openEditTask(task),
              )),
      ],
    );
  }

  bool get _hasActiveFilters =>
      _advancedFilter.priority != null || _advancedFilter.groupName != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: StreamBuilder<List<Task>>(
          stream: _taskService.streamUserTasks(_userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erro ao carregar tarefas:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final allTasks = snapshot.data ?? [];
            final filtered = _applyFilters(allTasks);

            final todayTasks = filtered
                .where((t) => !t.isCompleted && _isToday(t.dueDate))
                .toList();
            final tomorrowTasks = filtered
                .where((t) => !t.isCompleted && _isTomorrow(t.dueDate))
                .toList();
            final overdueTasks = filtered
                .where((t) => !t.isCompleted && _isOverdue(t.dueDate))
                .toList();
            final futureTasks = filtered
                .where((t) => !t.isCompleted && _isFuture(t.dueDate))
                .toList();
            final completedTasks =
                filtered.where((t) => t.isCompleted).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minhas Tarefas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // Loading indicator sutil enquanto conecta
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() => _showSearch = !_showSearch);
                              if (!_showSearch) {
                                _searchController.clear();
                                _searchQuery = '';
                              }
                            },
                            child: Icon(
                              _showSearch ? Icons.search_off : Icons.search,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _openFilterSheet(allTasks),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _hasActiveFilters
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF0F1733),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    color: _hasActiveFilters
                                        ? Colors.white
                                        : Colors.white54,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Filtrar',
                                    style: TextStyle(
                                      color: _hasActiveFilters
                                          ? Colors.white
                                          : Colors.white54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_showSearch) ...[
                    TaskSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  TaskFilterChips(
                    selected: _filter,
                    onSelected: (f) => setState(() => _filter = f),
                  ),

                  // Sem tarefas
                  if (filtered.isEmpty &&
                      snapshot.connectionState != ConnectionState.waiting)
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white24, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma tarefa encontrada',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                  if (overdueTasks.isNotEmpty)
                    _buildSection('atrasadas', 'Atrasadas', overdueTasks),
                  _buildSection('hoje', 'Hoje', todayTasks),
                  _buildSection('amanha', 'Amanhã', tomorrowTasks),
                  if (futureTasks.isNotEmpty)
                    _buildSection('futuras', 'Próximos dias', futureTasks),
                  _buildSection('concluidas', 'Concluídas', completedTasks),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
