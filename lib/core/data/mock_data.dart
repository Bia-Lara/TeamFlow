import '../../features/profile/data/user.entity.dart';
import '../../features/groups/data/group.entity.dart';
import '../../features/tasks/domain/task.dart';

/// Fonte centralizada de dados mockados.
/// TODO: substituir por chamadas ao backend (API REST).
class MockData {
  // Singleton
  static final MockData _instance = MockData._internal();
  factory MockData() => _instance;
  MockData._internal() {
    _initData();
  }

  late User currentUser;
  late List<User> allUsers;
  late List<Group> groups;
  late List<Task> tasks;

  void _initData() {
    allUsers = [
      User(id: '1', name: 'João Dias', email: 'joao.dias@email.com', password: '123456', groupIds: ['1', '2', '3']),
      User(id: '2', name: 'Ana Santos', email: 'ana.santos@email.com', password: '123456', groupIds: ['1']),
      User(id: '3', name: 'Maria Rosa', email: 'maria.rosa@email.com', password: '123456', groupIds: ['1', '2']),
      User(id: '4', name: 'Carlos Lima', email: 'carlos.lima@email.com', password: '123456', groupIds: ['2', '3']),
      User(id: '5', name: 'Pedro Souza', email: 'pedro.souza@email.com', password: '123456', groupIds: ['3']),
    ];

    currentUser = allUsers[0];

    groups = [
      Group(id: '1', name: 'Design Team', description: 'UI/UX e design visual', memberIds: ['1', '2', '3']),
      Group(id: '2', name: 'Desenvolvimento', description: 'Backend e frontend', memberIds: ['1', '3', '4']),
      Group(id: '3', name: 'Geral', description: 'Comunicação geral do time', memberIds: ['1', '4', '5']),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    tasks = [
      Task(id: '1', userId: '1', title: 'Criar wireframes do app', description: 'Criar wireframes de todas as telas principais', groupId: '1', groupName: 'Design Team', dueDate: today.add(const Duration(hours: 9)), priority: TaskPriority.alta, isCompleted: false),
      Task(id: '2', userId: '1', title: 'Reunião com o time', description: 'Alinhamento semanal sobre o progresso', groupId: '3', groupName: 'Geral', dueDate: today.add(const Duration(hours: 14)), priority: TaskPriority.media, isCompleted: false),
      Task(id: '3', userId: '1', title: 'Revisar pull requests', description: 'Revisar PRs pendentes no repositório', groupId: '2', groupName: 'Desenvolvimento', dueDate: today.add(const Duration(hours: 16, minutes: 30)), priority: TaskPriority.alta, isCompleted: false),
      Task(id: '4', userId: '1', title: 'Entregar protótipo final', description: 'Finalizar protótipo para aprovação', groupId: '1', groupName: 'Design Team', dueDate: tomorrow.add(const Duration(hours: 10)), priority: TaskPriority.alta, isCompleted: false),
      Task(id: '5', userId: '1', title: 'Atualizar documentação', description: 'Atualizar documentação técnica', groupId: '2', groupName: 'Desenvolvimento', dueDate: tomorrow.add(const Duration(hours: 15)), priority: TaskPriority.baixa, isCompleted: false),
      Task(id: '6', userId: '1', title: 'Configurar CI/CD', description: 'Configurar pipeline de integração contínua', groupId: '2', groupName: 'Desenvolvimento', dueDate: yesterday.add(const Duration(hours: 11)), priority: TaskPriority.alta, isCompleted: true),
      Task(id: '7', userId: '1', title: 'Criar paleta de cores', description: 'Definir paleta do design system', groupId: '1', groupName: 'Design Team', dueDate: yesterday.add(const Duration(hours: 9)), priority: TaskPriority.media, isCompleted: true),
      Task(id: '8', userId: '1', title: 'Corrigir bug no login', description: 'Resolver problema de autenticação', groupId: '2', groupName: 'Desenvolvimento', dueDate: yesterday.add(const Duration(hours: 14)), priority: TaskPriority.alta, isCompleted: true),
    ];
  }

  // --- Helpers para simular queries do backend ---

  List<Group> getGroupsForUser(String userId) {
    return groups.where((g) => g.memberIds?.contains(userId) ?? false).toList();
  }

  List<Task> getTasksForUser(String userId) {
    return tasks.where((t) => t.userId == userId).toList();
  }

  List<Task> getTasksForGroup(String groupId) {
    return tasks.where((t) => t.groupId == groupId).toList();
  }

  User? getUserById(String id) {
    try {
      return allUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  List<User> getMembersOfGroup(String groupId) {
    final group = groups.firstWhere((g) => g.id == groupId, orElse: () => Group());
    final ids = group.memberIds ?? [];
    return allUsers.where((u) => ids.contains(u.id)).toList();
  }

  void removeMemberFromGroup(String groupId, String userId) {
    final group = groups.firstWhere((g) => g.id == groupId, orElse: () => Group());
    group.memberIds?.remove(userId);
  }

  void addMemberToGroupByEmail(String groupId, String email) {
    final user = allUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => User(),
    );
    if (user.id == null) return;
    final group = groups.firstWhere((g) => g.id == groupId, orElse: () => Group());
    group.memberIds ??= [];
    if (!group.memberIds!.contains(user.id)) {
      group.memberIds!.add(user.id!);
    }
  }
}
