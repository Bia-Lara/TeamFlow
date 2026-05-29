enum TaskPriority { alta, media, baixa }

class Task {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final String? groupId;
  final String? groupName;
  final DateTime? dueDate;
  final TaskPriority priority;
  bool isCompleted;

  Task({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.groupId,
    this.groupName,
    this.dueDate,
    this.priority = TaskPriority.media,
    this.isCompleted = false,
  }) ;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.media,
      ),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'groupId': groupId,
      'groupName': groupName,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? groupId,
    String? groupName,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}