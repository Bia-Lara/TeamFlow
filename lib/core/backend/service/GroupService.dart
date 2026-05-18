import '../Persistency.dart';
import '../persistence/firebase/FirebaseGroupRepository.dart';
import '../../../features/groups/data/group.entity.dart';

class GroupService {
  final Persistency<Group, String> groupRepository = FirebaseGroupRepository.instance;

  GroupService();

  Future<Group> createGroup(Group group) async {
    if (group.name == null || group.name!.trim().isEmpty) {
      throw Exception("O nome do grupo é obrigatório!");
    }
    
    if (group.memberIds == null || group.memberIds!.isEmpty) {
      throw Exception("O grupo precisa ter pelo menos um membro (criador)!");
    }

    final existingGroups = await groupRepository.getByStringColumn("name", group.name!.trim());
    if (existingGroups.isNotEmpty) {
      throw Exception("Já existe um grupo cadastrado com este nome!");
    }

    return groupRepository.register(group);
  }

  Future<Group> getGroup(String id) async {
    return groupRepository.getById(id);
  }
  
  
  Future<List<Group>> getGroupsByName(String name) async {
    return groupRepository.getByStringColumn("name", name);
  }
}