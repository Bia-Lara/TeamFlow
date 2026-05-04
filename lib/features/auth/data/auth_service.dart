import '../../profile/data/user.entity.dart';
import '../../../../core/backend/sqlite_backend.dart';

class AuthService {
  AuthService();

  Future<User> register(User user) async {
    return SqliteBackend.instance.register(user);
  }
}
