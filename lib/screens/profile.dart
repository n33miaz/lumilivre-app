import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre_app/models/loan.dart';
import 'package:lumilivre_app/services/api.dart';
import 'package:lumilivre_app/widgets/loan_card.dart';
import 'package:lumilivre_app/providers/auth.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: theme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Empréstimos', // TODO: mudar dinamicamente com a aba
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                background: _buildProfileHeader(authProvider, theme),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.favorite_border)),
                  Tab(icon: Icon(Icons.star_border)),
                  Tab(icon: Icon(Icons.how_to_vote_outlined)),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLoansList(),
            const Center(child: Text('Livros Favoritos')),
            const Center(child: Text('Livros Curtidos')),
            const Center(child: Text('Livros Votados')),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${authProvider.user?.email.split('@')[0] ?? 'Aluno'}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ranking: #12 de 345', // Mock
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
