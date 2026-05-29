import 'package:team_flow/features/tasks/domain/task.dart';

import '../Persistency.dart';
import '../../../../features/profile/data/user.entity.dart';
import '../persistence/firebase/FirebaseUserRepository.dart';
import '../persistence/firebase/FirebaseGroupRepository.dart';
import '../../../features/groups/data/group.entity.dart';


class TaskService {
  Persistency<User, String> userRepository = FirebaseUserRepository.instance;
  Persistency<Group, String> groupRepository= FirebaseGroupRepository.instance;
  
  TaskService();

  Future<void> createTask(Task task, String? groupId, String? userId) async {
    if (groupId == null) throw Exception('Grupo da tarefa não pode ser nulo');
    if (userId == null) throw Exception('Grupo da tarefa não pode ser nulo');
    if (task.id == null) throw Exception('ID da tarefa não pode ser nulo');

    Group group = await groupRepository.getById(groupId);
    User user = await userRepository.getById(userId);

    List<Task> userTasks = List<Task>.from(user.tasks ?? []);
    userTasks.add(task);
    final updatedUser = user.copyWith(tasks: userTasks);
    await userRepository.update(updatedUser);

    var groupTasks = List<Task>.from(group.tasks ?? []);
    groupTasks.add(task);
    final updatedGroup = group.copyWith(tasks: groupTasks);
    await groupRepository.update(updatedGroup);
  }

  Future<Task> updateTask(Task task, String userId) async {
    final groupId = task.groupId;
    if (groupId == null) throw Exception('Grupo da tarefa não pode ser nulo');

    Group group = await groupRepository.getById(groupId);
    User user = await userRepository.getById(userId);

    List<Task> userTasks = List<Task>.from(user.tasks ?? []);
    userTasks = userTasks.map((oldTask) {
      return oldTask.id == task.id ? task : oldTask;
    }).toList();
    
    final updatedUser = user.copyWith(tasks: userTasks);
    await userRepository.update(updatedUser);

    List<Task> groupTasks = List<Task>.from(group.tasks ?? []);
    groupTasks = groupTasks.map((oldTask) {
      return oldTask.id == task.id ? task : oldTask;
    }).toList();
    
    final updatedGroup = group.copyWith(tasks: groupTasks);
    await groupRepository.update(updatedGroup);

    return task;
  }

Future<void> deleteTask(String? userId, String taskId) async {
    if (userId == null) throw Exception('ID do usuário não pode ser nulo');

    User user = await userRepository.getById(userId);

    final taskToDelete = user.tasks?.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Tarefa não encontrada no usuário'),
    );

    if (taskToDelete == null) throw Exception('Tarefa não encontrada');
    final groupId = taskToDelete.groupId;
    if (groupId == null) throw Exception('Grupo da tarefa não encontrado');

    List<Task> userTasks = List<Task>.from(user.tasks ?? []);
    userTasks = userTasks.where((t) => t.id != taskId).toList();
    
    final updatedUser = user.copyWith(tasks: userTasks);
    await userRepository.update(updatedUser);

    Group group = await groupRepository.getById(groupId);
    
    List<Task> groupTasks = List<Task>.from(group.tasks ?? []);
    groupTasks = groupTasks.where((t) => t.id != taskId).toList();
    
    final updatedGroup = group.copyWith(tasks: groupTasks);
    await groupRepository.update(updatedGroup);
  }

  Stream<List<Task>> streamUserTasks(String userId) {
    final firebaseRepo = userRepository as FirebaseUserRepository;

    return firebaseRepo.usersCollection
        .doc(userId)
        .snapshots()
        .map((docSnapshot) {
          if (docSnapshot.exists && docSnapshot.data() != null) {
            final user = User.fromJson(docSnapshot.data() as Map<String, dynamic>);
            return user.tasks ?? [];
          }
          return [];
        });
  }

  Stream<List<Task>> streamGroupTasks(String groupId) {
    final firebaseRepo = groupRepository as FirebaseGroupRepository;

    return firebaseRepo.groupsCollection
        .doc(groupId)
        .snapshots()
        .map((docSnapshot) {
          if (docSnapshot.exists && docSnapshot.data() != null) {
            final group = Group.fromJson(docSnapshot.data() as Map<String, dynamic>);
            return group.tasks ?? [];
          }
          return [];
        });
  }
}