import 'package:flutter/material.dart';
import '../../domain/task.dart';
import '../../data/mock_tasks.dart';
import '../widgets/task_list_card.dart';
import '../widgets/task_section_header.dart';
import '../widgets/task_filter_chips.dart';
import '../widgets/task_filter_sheet.dart';
import '../widgets/task_search_bar.dart';
import 'task_form_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> _allTasks = [];
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

  @override
  void initState() {
    super.initState();
    _allTasks = getMockTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    var tasks = List<Task>.from(_allTasks);

    // Filtro por status
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

    // Filtro avançado - prioridade
    if (_advancedFilter.priority != null) {
      tasks = tasks.where((t) => t.priority == _advancedFilter.priority).toList();
    }

    // Filtro avançado - grupo
    if (_advancedFilter.groupName != null) {
      tasks = tasks.where((t) => t.groupName == _advancedFilter.groupName).toList();
    }

    // Pesquisa
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

  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  void _openFilterSheet() async {
    final groups = _allTasks
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
    if (result == null) return;
    if (result is String && result == 'delete') {
      setState(() => _allTasks.removeWhere((t) => t.id == task.id));
    } else if (result is Task) {
      setState(() {
        final index = _allTasks.indexWhere((t) => t.id == result.id);
        if (index != -1) {
          _allTasks[index] = result;
        }
      });
    }
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
    final filtered = _filteredTasks;

    final todayTasks =
        filtered.where((t) => !t.isCompleted && _isToday(t.dueDate)).toList();
    final tomorrowTasks =
        filtered.where((t) => !t.isCompleted && _isTomorrow(t.dueDate)).toList();
    final overdueTasks =
        filtered.where((t) => !t.isCompleted && _isOverdue(t.dueDate)).toList();
    final futureTasks =
        filtered.where((t) => !t.isCompleted && _isFuture(t.dueDate)).toList();
    final completedTasks =
        filtered.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: Padding(
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
                        onTap: _openFilterSheet,
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

              // Search bar
              if (_showSearch) ...[
                TaskSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Filter chips
              TaskFilterChips(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),

              // Sections
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
        ),
      ),
    );
  }
}
