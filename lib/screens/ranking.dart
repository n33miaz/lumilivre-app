import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lumilivre/models/ranking.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/ranking_podium.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<RankingItem> _ranking = [];

  // Filtros
  List<FilterItem> _cursos = [];
  List<FilterItem> _modulos = [];
  List<FilterItem> _turnos = [];

  int? _selectedCursoId;
  int? _selectedModuloId;
  int? _selectedTurnoId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    final token = auth.user!.token;

    // Carrega filtros e dados em paralelo
    final results = await Future.wait([
      _apiService.getCursos(token),
      _apiService.getSimpleList('modulos', token),
      _apiService.getSimpleList('turnos', token),
      _fetchRankingData(token),
    ]);

    if (mounted) {
      setState(() {
        _cursos = results[0] as List<FilterItem>;
        _modulos = results[1] as List<FilterItem>;
        _turnos = results[2] as List<FilterItem>;
        // O ranking já é setado dentro de _fetchRankingData, mas aqui garantimos o loading
        _isLoading = false;
      });
    }
  }

  Future<List<RankingItem>> _fetchRankingData(String token) async {
    final data = await _apiService.getRanking(
      token: token,
      cursoId: _selectedCursoId,
      moduloId: _selectedModuloId,
      turnoId: _selectedTurnoId,
      top: 50, // Trazemos top 50 para a lista
    );
    _ranking = data;
    return data;
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await _fetchRankingData(auth.user!.token);
    setState(() => _isLoading = false);
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar Ranking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildDropdown('Curso', _cursos, _selectedCursoId, (val) {
                  setModalState(() => _selectedCursoId = val);
                }),
                const SizedBox(height: 16),
                _buildDropdown('Módulo', _modulos, _selectedModuloId, (val) {
                  setModalState(() => _selectedModuloId = val);
                }),
                const SizedBox(height: 16),
                _buildDropdown('Turno', _turnos, _selectedTurnoId, (val) {
                  setModalState(() => _selectedTurnoId = val);
                }),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    child: const Text('APLICAR FILTROS'),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setModalState(() {
                        _selectedCursoId = null;
                        _selectedModuloId = null;
                        _selectedTurnoId = null;
                      });
                    },
                    child: const Text(
                      'Limpar Filtros',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<FilterItem> items,
    int? value,
    Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e.id,
              child: Text(e.nome, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (!auth.isAuthenticated) {
      return const Center(child: Text('Faça login para ver o ranking.'));
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Separa top 3 e o resto
    final top3 = _ranking.take(3).toList();
    final restList = _ranking.skip(3).toList();

    // Verifica posição do usuário logado
    final myMatricula = auth.user?.matriculaAluno;
    int myRankIndex = _ranking.indexWhere((r) => r.matricula == myMatricula);
    RankingItem? myRankItem = myRankIndex != -1 ? _ranking[myRankIndex] : null;
    bool amIInTop3 = myRankIndex != -1 && myRankIndex < 3;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterModal,
        backgroundColor: LumiLivreTheme.primary,
        icon: const Icon(Icons.filter_list, color: Colors.white),
        label: const Text('Filtrar', style: TextStyle(color: Colors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _applyFilters,
        child: CustomScrollView(
          slivers: [
            // Pódio
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: _ranking.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: Text("Nenhum aluno encontrado.")),
                      )
                    : RankingPodium(topThree: top3),
              ),
            ),

            // Lista do 4º em diante
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = restList[index];
                final position = index + 4;
                final isMe = item.matricula == myMatricula;

                return _RankingCard(item: item, position: position, isMe: isMe);
              }, childCount: restList.length),
            ),

            // Espaço extra para o FAB não cobrir o último item
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      // Barra fixa inferior se o usuário estiver no ranking mas não no top 3
      bottomNavigationBar: (myRankItem != null && !amIInTop3)
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _RankingCard(
                item: myRankItem,
                position: myRankIndex + 1,
                isMe: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            )
          : null,
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingItem item;
  final int position;
  final bool isMe;
  final double elevation;
  final Color? backgroundColor;

  const _RankingCard({
    required this.item,
    required this.position,
    required this.isMe,
    this.elevation = 2,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: elevation,
      color:
          backgroundColor ??
          (isMe
              ? LumiLivreTheme.primary.withOpacity(0.1)
              : Theme.of(context).cardColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMe
            ? const BorderSide(color: LumiLivreTheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Posição
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Text(
                '#$position',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Nome
            Expanded(
              child: Text(
                item.nome,
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: LumiLivreTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.emprestimosCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
