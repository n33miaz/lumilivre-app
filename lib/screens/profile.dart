import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/settings.dart';
import 'package:lumilivre/screens/ranking.dart';
import 'package:lumilivre/screens/loans_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  String? _studentName;
  int _currentIndex = 0;

  // Dados do Ranking para o Header
  int? _myRankPosition;
  // ignore: unused_field
  int? _totalStudents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });

    _loadHeaderData();
  }

  void _loadHeaderData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      final matricula = authProvider.user!.matriculaAluno!;
      final token = authProvider.user!.token;

      _fetchStudentName(matricula, token);
      _fetchMyRank(matricula, token);
    }
  }

  Future<void> _fetchStudentName(String matricula, String token) async {
    try {
      final name = await _apiService.getStudentName(matricula, token);
      if (mounted && name != null) setState(() => _studentName = name);
    } catch (e) {
      print('Erro ao buscar nome: $e');
    }
  }

  Future<void> _fetchMyRank(String matricula, String token) async {
    try {
      // Busca o ranking geral (top 100 para garantir)
      final ranking = await _apiService.getRanking(token: token, top: 100);
      final index = ranking.indexWhere((r) => r.matricula == matricula);

      if (mounted) {
        setState(() {
          _totalStudents = ranking.length;
          if (index != -1) {
            _myRankPosition = index + 1;
          }
        });
      }
    } catch (e) {
      print('Erro ao buscar ranking: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        toolbarHeight: 150,
        elevation: 0,
        title: _buildProfileHeader(authProvider, theme),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: LumiLivreTheme.label,
          indicatorWeight: 4.0,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
          indicatorSize: TabBarIndicatorSize.label,
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (_) => Colors.transparent,
          ),
          tabs: [
            // EMPRÉSTIMOS
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.asset(
                  _currentIndex == 0
                      ? 'assets/icons/loans-active.svg'
                      : 'assets/icons/loans.svg',
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            // CURTIDOS
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  _currentIndex == 1 ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            // RANKING
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.asset(
                  _currentIndex == 2
                      ? 'assets/icons/ranking-active.svg'
                      : 'assets/icons/ranking.svg',
                  height: 28,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Aba de Empréstimos (Refatorada)
          const LoansTab(),

          // 2. Aba de Curtidos (Placeholder)
          const Center(child: Text('Livros Curtidos')),

          // 3. Aba de Ranking (Já criada anteriormente)
          const RankingScreen(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, ThemeData theme) {
    String displayName =
        _studentName ?? authProvider.user?.email.split('@')[0] ?? 'Aluno';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _myRankPosition != null
                    ? 'Ranking: #$_myRankPosition'
                    : 'Ranking: --',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
