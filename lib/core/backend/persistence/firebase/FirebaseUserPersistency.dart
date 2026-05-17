import 'package:cloud_firestore/cloud_firestore.dart';
import '../Persistency.dart';
import '../../../../features/profile/data/user.entity.dart';

class FirebaseUserPersistence implements Persistency<User, String> {
  FirebaseUserPersistence._internal();
  static final FirebaseUserPersistence instance = FirebaseUserPersistence._internal();
  static final CollectionReference _usersColl = FirebaseFirestore.instance.collection('users');
  
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
}