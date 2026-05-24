import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Persistency.dart';
import '../../../../features/groups/data/group.entity.dart'; // Ajuste o path se necessário

class FirebaseGroupRepository implements Persistency<Group, String> {
  FirebaseGroupRepository._internal();
  static final FirebaseGroupRepository instance = FirebaseGroupRepository._internal();
  
  final CollectionReference _groupsColl = FirebaseFirestore.instance.collection('groups');

  @override
  Future<void> delete(String key) async {
    await _groupsColl.doc(key).delete();
  }

  @override
  Future<Group> getById(String key) async {
    final doc = await _groupsColl.doc(key).get();
    if (!doc.exists) throw Exception('Grupo/Casa não encontrado: $key');
    
    // Como você não usa um fromJson estático, instanciamos e populamos com os dados do Firestore
    var data = doc.data() as Map<String, dynamic>;
    return Group(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  @override
  Future<Group> register(Group group) async {
    var docRef = _groupsColl.doc();

    var map = {
      'id': docRef.id,
      'name': group.name,
      'description': group.description,
      'memberIds': group.memberIds ?? [],
    };

    await docRef.set(map);
    return group.copyWith(id: docRef.id, memberIds: group.memberIds ?? []);
  }

  @override
  Future<Group> update(Group group) async {
    if (group.id == null) throw Exception('ID do grupo não pode ser nulo para atualização');

    await _groupsColl.doc(group.id).update({
      'name': group.name,
      'description': group.description,
      'memberIds': group.memberIds ?? [],
    });

    return group;
  }

  @override
  Future<List<Group>> getByStringColumn(String columnName, String? value) async {
    if (value == null) throw Exception('Valor não deve ser nulo!');

    var snapshot = await _groupsColl.where(columnName, isEqualTo: value).get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Group(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        memberIds: List<String>.from(data['memberIds'] ?? []),
      );
    }).toList();
  }

  /// Busca todos os grupos onde a lista 'memberIds' do Firestore contém o ID do usuário
  Future<List<Group>> getByMemberId(String userId) async {
    var snapshot = await _groupsColl.where('memberIds', arrayContains: userId).get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Group(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        memberIds: List<String>.from(data['memberIds'] ?? []),
      );
    }).toList();
  }
}