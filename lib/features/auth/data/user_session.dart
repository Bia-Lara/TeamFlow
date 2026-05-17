import '../../profile/data/user.entity.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  void logout() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}
