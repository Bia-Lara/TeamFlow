import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Persistency.dart'; 
import '../../../../features/groups/data/group.entity.dart';

class FirebaseGroupRepository implements Persistency<Group, String> {
  FirebaseGroupRepository._internal();
  static final FirebaseGroupRepository instance = FirebaseGroupRepository._internal();

  final CollectionReference _groupsColl = FirebaseFirestore.instance.collection('groups');

  @override
  Future<Group> register(Group group) async {
    var docRef = _groupsColl.doc();

    var map = {
      "id": docRef.id,
      "name": group.name,
      "description": group.description,
      "memberIds": group.memberIds ?? []
    };

    await docRef.set(map);
    return group.copyWith(id: docRef.id, memberIds: group.memberIds ?? []);
  }

  @override
  Future<Group> getById(String key) async {
    var doc = await _groupsColl.doc(key).get();
    if (!doc.exists) throw Exception("Grupo não encontrado!");
    
    return Group.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Group>> getByStringColumn(String columnName, String? value) async {
    if (value == null) throw Exception("Valor de busca não pode ser nulo!");

    var snapshot = await _groupsColl.where(columnName, isEqualTo: value).get();

    return snapshot.docs.map((doc) {
      return Group.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  @override
  Future<Group> update(Group group) async {
    if (group.id == null) throw Exception("ID do grupo é obrigatório para atualização!");
    
    await _groupsColl.doc(group.id).update(group.toJson());
    return group;
  }

  @override
  Future<void> delete(String key) async {
    await _groupsColl.doc(key).delete();
  }
}