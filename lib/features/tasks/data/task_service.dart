import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/task.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cria uma nova tarefa no Firestore
  Future<Task> createTask(Task task, String userId) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add({
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'dueDate': task.dueDate?.toIso8601String(),
        'isCompleted': task.isCompleted,
        'groupId': task.groupId,
        'groupName': task.groupName,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return task.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erro ao criar tarefa: $e');
    }
  }

  /// Busca todas as tarefas do usuário
  Future<List<Task>> getUserTasks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('dueDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  /// Busca tarefas por grupo
  Future<List<Task>> getTasksByGroup(String userId, String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('groupId', isEqualTo: groupId)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas do grupo: $e');
    }
  }

  /// Atualiza uma tarefa existente
  Future<Task> updateTask(Task task, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update({
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'dueDate': task.dueDate?.toIso8601String(),
        'isCompleted': task.isCompleted,
        'groupId': task.groupId,
        'groupName': task.groupName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return task;
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }

  /// Marca uma tarefa como concluída
  Future<void> completeTask(String userId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .update({
        'isCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao completar tarefa: $e');
    }
  }

  /// Deleta uma tarefa
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }

  /// Obtém stream em tempo real das tarefas do usuário
  Stream<List<Task>> streamUserTasks(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Obtém tarefas incompletas próximas ao vencimento
  Future<List<Task>> getUpcomingTasks(String userId,
      {int daysAhead = 7}) async {
    try {
      final now = DateTime.now();
      final future = now.add(Duration(days: daysAhead));

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .where('dueDate', isGreaterThanOrEqualTo: now.toIso8601String())
          .where('dueDate', isLessThanOrEqualTo: future.toIso8601String())
          .orderBy('dueDate')
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas próximas: $e');
    }
  }

  /// Busca tarefas por prioridade
  Future<List<Task>> getTasksByPriority(String userId, String priority) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('priority', isEqualTo: priority)
          .where('isCompleted', isEqualTo: false)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas por prioridade: $e');
    }
  }
}
