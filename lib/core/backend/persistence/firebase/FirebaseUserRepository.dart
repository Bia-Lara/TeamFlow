import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Persistency.dart';
import '../../../../features/profile/data/user.entity.dart';

class FirebaseUserRepository implements Persistency<User, String> {
  FirebaseUserRepository._internal();
  static final FirebaseUserRepository instance =
      FirebaseUserRepository._internal();
  CollectionReference _usersColl =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<void> delete(String key) async {
    await _usersColl.doc(key).delete();
  }

  @override
  Future<User> getById(String key) async {
    final doc = await _usersColl.doc(key).get();
    if (!doc.exists) throw Exception('Usuário não encontrado: $key');
    return User.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<User> register(User user) async {
    var docRef = _usersColl.doc();

    var map = {
      'id': docRef.id,
      'email': user.email,
      'name': user.name,
      'password': user.password,
      'groupIds': user.groupIds ?? [],
    };

    await docRef.set(map);
    return user.copyWith(id: docRef.id, groupIds: user.groupIds ?? []);
  }

  @override
  Future<User> update(User user) async {
    if (user.id == null) throw Exception('ID do usuário não pode ser nulo');

    await _usersColl.doc(user.id).update({
      'email': user.email,
      'name': user.name,
      'password': user.password,
      'groupIds': user.groupIds ?? [],
    });

    return user;
  }

  @override
  Future<List<User>> getByStringColumn(String columnName, String? value) async {
    if (value == null) throw Exception('Valor não deve ser nulo!');

    var snapshot = await _usersColl.where(columnName, isEqualTo: value).get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return User.fromJson(data);
    }).toList();
  }
}
