import 'package:flutter/material.dart';
import 'package:team_flow/core/backend/service/GroupService.dart'; // Import do seu GroupService
import '../../data/group.entity.dart';
import '../widgets/group_list_card.dart';
import 'group_detail_page.dart';
import '../../../auth/data/user_session.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final GroupService _groupService = GroupService();
  final _searchController = TextEditingController();
  
  List<Group> _allGroups = [];       // Guarda a lista completa vinda do Firebase
  List<Group> _filteredGroups = [];  // Guarda o resultado filtrado pela barra de busca
  bool _isLoading = false;
  String _searchQuery = '';

  String get _userId => UserSession().currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Busca todos os grupos do usuário no Firestore de forma assíncrona
  Future<void> _fetchGroups() async {
    if (_userId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final groups = await _groupService.getGroupsByUser(_userId);
      if (mounted) {
        setState(() {
          _allGroups = groups;
          _applyFilter(_searchQuery); // Garante que se houver texto, ele filtre na hora
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar grupos: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: const Color(0xFFFF4757),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Filtra a lista local em memória de forma instantânea ao digitar
  void _applyFilter(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredGroups = List.from(_allGroups);
    } else {
      final q = query.toLowerCase();
      _filteredGroups = _allGroups
          .where((g) => (g.name?.toLowerCase().contains(q) ?? false))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Grupos",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1733),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _applyFilter(value);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Buscar grupos...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _applyFilter('');
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.white38),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Conteúdo da Listagem / Loading
              Expanded(
                child: _isLoading && _allGroups.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                    : _filteredGroups.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum grupo encontrado',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredGroups.length,
                            itemBuilder: (context, index) {
                              final group = _filteredGroups[index];
                              return GroupListCard(
                                group: group,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => GroupDetailPage(group: group),
                                    ),
                                  );
                                  // Atualiza os dados da listagem se houveram modificações
                                  _fetchGroups();
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}