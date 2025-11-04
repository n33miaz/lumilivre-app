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

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      _loansFuture = _apiService.getMyLoans(
        authProvider.user!.matriculaAluno!,
        authProvider.user!.token,
      );
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
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  _currentIndex == 2 ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  _currentIndex == 3
                      ? Icons.how_to_vote
                      : Icons.how_to_vote_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoansList(),
          const Center(child: Text('Livros Favoritos')),
          const Center(child: Text('Livros Curtidos')),
          const Center(child: Text('Livros Votados')),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, ThemeData theme) {
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
                authProvider.user?.email.split('@')[0] ?? 'Aluno',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 30,
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
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Você não possui empréstimos ativos.'),
          );
        }

        final loans = snapshot.data!;
        return ListView.builder(
          itemCount: loans.length,
          itemBuilder: (context, index) {
            return LoanCard(loan: loans[index]);
          },
        );
      },
    );
  }
}
