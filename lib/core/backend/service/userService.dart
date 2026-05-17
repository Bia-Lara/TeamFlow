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

    var repeattedMail = await usersColl.where('email', isEqualTo: user.email).get();
    var repeattedName = await usersColl.where('name', isEqualTo: user.name).get();


    if (repeattedMail.docs.isNotEmpty) throw Exception("Email já cadastrado!");
    if (repeattedName.docs.isNotEmpty) throw Exception("Nome já cadastrado!");

    user.email = email;
    user.password = pw_hash.generateSaltedHash(user.password);

    return userRepository.register(user);
  }
}