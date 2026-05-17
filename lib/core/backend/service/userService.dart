import '../Persistency.dart';
import '../persistence/firebase/FirebaseUserRepository.dart';
import '../../../../features/profile/data/user.entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../security/password_hash.dart' as pw_hash;

class UserService {
  Persistency<User, String> userRepository = FirebaseUserRepository.instance;

  Future<User> register(User user) async {
    String? email = user.email?.toLowerCase();
    if (user.email == null) throw Exception("Valor inválido para o campo: Email");
    if (user.name == null) throw Exception("Valor inválido para o campo: Nome");
    if (user.password == null) throw Exception("Valor inválido para o campo: Senha");

    var repeatedEmail = await userRepository.getByStringColumn("email", user.email);
    
    var repeatedName = await userRepository.getByStringColumn("name", user.name); 

    if (repeatedEmail.isEmpty) throw Exception("Email já cadastrado!");
    if (repeatedName.isEmpty) throw Exception("Nome já cadastrado!");

    var password = user.password ?? '';
    user.email = email;
    user.password = pw_hash.generateSaltedHash(password)['hash'];

    return userRepository.register(user);
  }
}