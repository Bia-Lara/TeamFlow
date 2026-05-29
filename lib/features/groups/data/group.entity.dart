import '../../tasks/domain/task.dart';

class Group {
  String? id;
  String? name;
  String? description;
  List<String>? memberIds;
  List<Task>? tasks;

  Group({
    this.id,
    this.name,
    this.description,
    this.memberIds,
    this.tasks,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: json['memberIds'] != null
          ? List<String>.from(json['memberIds'])
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
      'description': description,
      'memberIds': memberIds,
      'tasks': tasks?.map((e) => e.toJson()).toList(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memberIds,
    List<Task>? tasks,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
      tasks: tasks ?? this.tasks,
    );
  }
}