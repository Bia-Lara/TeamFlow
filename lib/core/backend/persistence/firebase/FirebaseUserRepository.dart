import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Persistency.dart';
import '../../../../features/profile/data/user.entity.dart';

class FirebaseUserRepository implements Persistency<User, String> {
  FirebaseUserRepository._internal();
  static final FirebaseUserRepository instance = FirebaseUserRepository._internal();
  CollectionReference _usersColl = FirebaseFirestore.instance.collection('users');
  
  @override
  void delete(String key) {
    // TODO: implement delete
  }
  
  @override
  Future<User> getById(String key) {
    // TODO: implement getById
    throw UnimplementedError();
  }
  
  @override
  Future<User> register(User user) async {
    // TODO: implement register
    var docRef = _usersColl.doc();

    var map = {
      "id": docRef.id,
      "email": user.email,
      "name": user.name,
      "password": user.password,
      "groupIds": user.groupIds
    };

    await docRef.set(map);
    return user.copyWith(id: docRef.id, groupIds: user.groupIds ?? []);
  }
  
  @override
  Future<User> update(User user) {
    // TODO: implement update
    throw UnimplementedError();
  }
  
  @override
  Future<List<User>> getByStringColumn(String columnName, String? value) async {
    // TODO: implement getByStringColumn
    if (value == null) throw Exception("Valor não deve ser nulo!");

    var snapshot = await _usersColl.where(columnName, isEqualTo: value).get(); 
    
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;

      return User.fromJson(data);
    }).toList();
  }
}