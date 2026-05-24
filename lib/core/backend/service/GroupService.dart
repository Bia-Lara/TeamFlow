import '../Persistency.dart';
import '../persistence/firebase/FirebaseGroupRepository.dart';
import '../../../features/groups/data/group.entity.dart';

class GroupService {
  // Seguindo a sua estrutura do UserService
  Persistency<Group, String> groupRepository = FirebaseGroupRepository.instance;

  GroupService();

  /// Cria um novo grupo/casa e define o usuário logado como primeiro membro
  Future<Group> createGroup(String name, String? description, String creatorUserId) async {
    if (name.trim().isEmpty) throw Exception("Valor inválido para o campo: Nome do Grupo");

    // Opcional: Validar se já existe um grupo com o mesmo nome
    var repeatedName = await groupRepository.getByStringColumn("name", name.trim());
    if (repeatedName.isNotEmpty) throw Exception("Já existe um grupo cadastrado com este nome!");

    final newGroup = Group(
      name: name.trim(),
      description: description?.trim(),
      memberIds: [creatorUserId], // O criador entra automaticamente no grupo
    );

    return groupRepository.register(newGroup);
  }

  /// Busca todos os grupos aos quais o usuário pertence
  Future<List<Group>> getGroupsByUser(String userId) async {
    if (userId.isEmpty) throw Exception("ID de usuário inválido");
    
    // Cast para acessar o método específico do repositório Firebase
    final repo = groupRepository as FirebaseGroupRepository;
    return await repo.getByMemberId(userId);
  }

  /// Adiciona um novo membro à casa (útil para quando forem convidar alguém)
  Future<Group> addMemberToGroup(String groupId, String newUserId) async {
    final group = await groupRepository.getById(groupId);
    
    List<String> currentMembers = List<String>.from(group.memberIds ?? []);
    
    if (currentMembers.contains(newUserId)) {
      throw Exception("Este usuário já é membro deste grupo!");
    }

    currentMembers.add(newUserId);
    final updatedGroup = group.copyWith(memberIds: currentMembers);

    return await groupRepository.update(updatedGroup);
  }
}