class Group {
  String? id;
  String? name;
  String? description;
  List<String>? memberIds;

  Group({
    this.id,
    this.name,
    this.description,
    this.memberIds,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      memberIds: json['memberIds'] != null
          ? List<String>.from(json['memberIds'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberIds': memberIds,
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? memberIds,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}