import '../../profile/data/user.entity.dart';
import '../../../core/backend/persistence/SQLite/sqlite_backend.dart';

class AuthService {
  AuthService();

  Future<User> register(User user) async {
    return SqliteBackend.instance.register(user);
  }

  Future<User?> getUserById(String id) async {
    return SqliteBackend.instance.getById(id);
  }

  Future<User> updateUser(User user) async {
    return SqliteBackend.instance.updateUser(user);
  }

  Future<void> deleteUser(String userId) async {
    return SqliteBackend.instance.deleteUser(userId);
  }

  Future<bool> verifyPassword(String userId, String password) async {
    return SqliteBackend.instance.verifyPassword(userId, password);
  }

  Future<List<User>> getAllUsers() async {
    return SqliteBackend.instance.allUsers();
  }

  Future<User> login(String email, String password) async {
    return SqliteBackend.instance.login(email, password);
  }
}
