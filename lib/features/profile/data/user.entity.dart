class User {
  String? id;
  String? name;
  String? email;
  String? password;
  List<String>? groupIds;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.groupIds,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'groupIds': groupIds,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    List<String>? groupIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      groupIds: groupIds ?? this.groupIds,
    );
  }
}
