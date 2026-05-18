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