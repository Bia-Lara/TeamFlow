class TaskEntity {
  String? id;
  String? userId;
  String? title;
  String? description;
  String? groupId;
  String? groupName;
  DateTime? dueDate;
  String? priority;
  bool? isCompleted;

  TaskEntity({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.groupId,
    this.groupName,
    this.dueDate,
    this.priority,
    this.isCompleted,
  });

  factory TaskEntity.fromJson(Map<String, dynamic> json) {
    return TaskEntity(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      groupId: json['groupId'] as String?,
      groupName: json['groupName'] as String?,
      // Converte a String do JSON de volta para um objeto DateTime
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
      priority: json['priority'] as String?,
      isCompleted: json['isCompleted'] as bool?,
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
      // Converte o DateTime para o formato de texto ISO-8601 (Ex: 2026-05-28T20:11:00Z)
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? groupId,
    String? groupName,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
  }) {
    return TaskEntity(
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