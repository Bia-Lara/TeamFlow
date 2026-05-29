import '../../tasks/domain/task.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  List<String>? groupIds;
  List<Task>? tasks;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.groupIds,
    this.tasks,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      groupIds: json['groupIds'] != null
          ? List<String>.from(json['groupIds'])
          : null,
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
              .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'groupIds': groupIds,
      'tasks': tasks?.map((e) => e.toJson()).toList(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    List<String>? groupIds,
    List<Task>? tasks,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      groupIds: groupIds ?? this.groupIds,
      tasks: tasks ?? this.tasks,
    );
  }
}
