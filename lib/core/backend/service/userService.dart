import 'dart:convert';

import '../Persistency.dart';
import '../persistence/firebase/FirebaseUserRepository.dart';
import '../../../../features/profile/data/user.entity.dart';
import '../../security/password_hash.dart' as pw_hash;

class UserService {
  Persistency<User, String> userRepository = FirebaseUserRepository.instance;

  UserService();

Future<User> getUserByEmail(String email) async {
  final emailClean = email.trim().toLowerCase();
  if (emailClean.isEmpty) throw Exception("O e-mail não pode ser vazio");

  final usersFound = await userRepository.getByStringColumn("email", emailClean);
  if (usersFound.isEmpty) throw Exception("Usuário não encontrado");

  return usersFound.first;
}

  Future<User> register(User user) async {
    String? email = user.email?.toLowerCase();
    if (user.email == null) throw Exception("Valor inválido para o campo: Email");
    if (user.name == null) throw Exception("Valor inválido para o campo: Nome");
    if (user.password == null) throw Exception("Valor inválido para o campo: Senha");

    var repeatedEmail = await userRepository.getByStringColumn("email", user.email);
    
    var repeatedName = await userRepository.getByStringColumn("name", user.name); 

    if (repeatedEmail.isNotEmpty) throw Exception("Email já cadastrado!");
    if (repeatedName.isNotEmpty) throw Exception("Nome já cadastrado!");

    var password = user.password ?? '';
    var hashedPassword = pw_hash.generateSaltedHash(password); 
    user.email = email;
    user.password = jsonEncode({
      'hash': hashedPassword['hash'],
      'salt': hashedPassword['salt']
    });

    return userRepository.register(user);
  }

  Future<User> login(String email, String password) async {
    final emailClean = email.trim().toLowerCase();

    if (emailClean.isEmpty || password.isEmpty) throw Exception("E-mail e senha são obrigatórios!");
  
    final usersFound = await userRepository.getByStringColumn("email", emailClean);

    if (usersFound.isEmpty) throw Exception("E-mail ou senha incorretos");

    final user = usersFound.first;

    if (user.password == null || user.password!.isEmpty) throw Exception("E-mail ou senha incorretos");
    

    try {
      final storedPasswordData = jsonDecode(user.password!) as Map<String, dynamic>;
      final salt = storedPasswordData['salt'] as String;
      final hash = storedPasswordData['hash'] as String;

      final isPasswordValid = pw_hash.verifyPassword(password, salt, hash);

      if (!isPasswordValid) {
        throw Exception("E-mail ou senha incorretos");
      }
    } catch (e) {
      throw Exception("Erro ao processar autenticação. Entre em contato com o suporte.");
  }

  return user.copyWith(password: null);
}
}