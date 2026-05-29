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

  void createTask(Task task, String groupId, String userId) async {
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
}