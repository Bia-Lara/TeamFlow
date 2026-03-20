class Task {
  final String? id;
  final String? userId;
  final String? title;
  final String? description;
  final String? groupId;
  final DateTime? dueDate;
  bool isCompleted;

  Task({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.groupId,
    this.dueDate,
    this.isCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      groupId: json['groupId'],
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
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
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}