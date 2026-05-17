import 'dart:async';

import '../../../../features/profile/data/user.entity.dart';

class InMemoryBackend {
  InMemoryBackend._internal();
  static final InMemoryBackend instance = InMemoryBackend._internal();

  final List<User> _users = [];

  Future<User> register(User user) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final email = user.email?.toLowerCase();
    if (email == null || email.isEmpty) {
      throw Exception('E-mail inválido');
    }

    final exists = _users.any((u) => u.email?.toLowerCase() == email);
    if (exists) {
      throw Exception('E-mail já cadastrado');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final created = user.copyWith(id: id, groupIds: user.groupIds ?? []);
    _users.add(created);

    return created;
  }

  User? getByEmail(String email) {
    for (final user in _users) {
      if (user.email?.toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  List<User> allUsers() => List.unmodifiable(_users);
}
