import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:team_flow/features/tasks/domain/task.dart';
import '../../Persistency.dart';
import '../../../../features/groups/data/group.entity.dart'; // Ajuste o path se necessário

class FirebaseGroupRepository implements Persistency<Group, String> {
  FirebaseGroupRepository._internal();
  static final FirebaseGroupRepository instance = FirebaseGroupRepository._internal();
  
  final CollectionReference _groupsColl = FirebaseFirestore.instance.collection('groups');

  CollectionReference get groupsCollection => _groupsColl;


  @override
  Future<void> delete(String key) async {
    await _groupsColl.doc(key).delete();
  }

  @override
  Future<Group> getById(String key) async {
    final doc = await _groupsColl.doc(key).get();
    if (!doc.exists) throw Exception('Grupo/Casa não encontrado: $key');
    
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
      'tasks': group.tasks?.map((e) => e.toJson()).toList() ?? [],
    });

    return group;
  }

  @override
  Future<List<Group>> getByStringColumn(String columnName, String? value) async {
    if (value == null) throw Exception('Valor não deve ser nulo!');

    Query query = _groupsColl;

    if (columnName == 'memberIds') {
      query = query.where(columnName, arrayContains: value);
    } else {
      query = query.where(columnName, isEqualTo: value);
    }

    var snapshot = await query.get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      
      if (data['id'] == null) {
        data['id'] = doc.id;
      }
      
      return Group.fromJson(data);
    }).toList();
  }

  Future<List<Group>> getByMemberId(String userId) async {
    var snapshot = await _groupsColl.where('memberIds', arrayContains: userId).get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return Group(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        memberIds: List<String>.from(data['memberIds'] ?? []),
        tasks: (data['tasks'] as List?)
            ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    }).toList();
  }
}