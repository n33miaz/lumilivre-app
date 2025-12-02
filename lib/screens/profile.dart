import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/loan_card.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/screens/settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  Future<List<Loan>>? _loansFuture;
  bool _showHistory = false;

  String? _studentName;
  int _currentIndex = 0;

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

    _loadInitialData();
  }

  void _loadInitialData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      final matricula = authProvider.user!.matriculaAluno!;
      final token = authProvider.user!.token;

      _loadLoans(matricula, token);

      _fetchStudentName(matricula, token);
    }
  }

  void _loadLoans(String matricula, String token) {
    setState(() {
      if (_showHistory) {
        _loansFuture = _apiService.getMyLoansHistory(matricula, token);
      } else {
        _loansFuture = _apiService.getMyLoans(matricula, token);
      }
    });
  }

  void _toggleLoanView(bool showHistory) {
    if (_showHistory != showHistory) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        setState(() {
          _showHistory = showHistory;
        });
        _loadLoans(
          authProvider.user!.matriculaAluno!,
          authProvider.user!.token,
        );
      }
    }
  }

  Future<void> _fetchStudentName(String matricula, String token) async {
    // Implementação segura caso o método não exista na API ainda
    try {
      // final name = await _apiService.getStudentName(matricula, token);
      // if (mounted && name != null) setState(() => _studentName = name);
    } catch (e) {
      print('Erro ao buscar nome: $e');
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
          _buildLoansTab(context), 
          const Center(child: Text('Livros Curtidos')),
          const Center(child: Text('Ranking de Leitores')),
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
                'Ranking: #12 de 345', // MOCK
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

  // --- EMPRÉSTIMOS ---
  Widget _buildLoansTab(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Botões de Filtro (Toggle)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: _FilterButton(
                  label: 'Em Andamento',
                  isSelected: !_showHistory,
                  onTap: () => _toggleLoanView(false),
                ),
              ),
              Expanded(
                child: _FilterButton(
                  label: 'Histórico',
                  isSelected: _showHistory,
                  onTap: () => _toggleLoanView(true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Lista de Empréstimos
        Expanded(child: _buildLoansList()),
      ],
    );
  }

  Widget _buildLoansList() {
    if (_loansFuture == null) {
      return const Center(child: Text('Faça login para ver seus empréstimos.'));
    }

    return FutureBuilder<List<Loan>>(
      future: _loansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Não foi possível carregar os dados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (auth.user?.matriculaAluno != null) {
                        _loadLoans(
                          auth.user!.matriculaAluno!,
                          auth.user!.token,
                        );
                      }
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showHistory ? Icons.history : Icons.book_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  _showHistory
                      ? 'Nenhum empréstimo no histórico.'
                      : 'Nenhum empréstimo ativo no momento.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final loans = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 20, top: 8),
          itemCount: loans.length,
          itemBuilder: (context, index) {
            return LoanCard(
              loan: loans[index],
            );
          },
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? LumiLivreTheme.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
