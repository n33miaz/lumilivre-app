import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/loan_card.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';

class LoansTab extends StatefulWidget {
  const LoansTab({super.key});

  @override
  State<LoansTab> createState() => _LoansTabState();
}

class _LoansTabState extends State<LoansTab> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<Loan> _activeList = [];
  List<Loan> _historyList = [];

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllLoans();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadAllLoans() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      final matricula = authProvider.user!.matriculaAluno!;
      final token = authProvider.user!.token;

      setState(() => _isLoading = true);

      try {
        final results = await Future.wait([
          _apiService.getMyLoans(matricula, token),
          _apiService.getMyLoansHistory(matricula, token),
          _apiService.getMyRequests(matricula, token),
        ]);

        final activeLoans = results[0];
        final historyLoans = results[1];
        final allRequests = results[2];

        final pendingRequests = allRequests
            .where((r) => r.status == 'PENDENTE')
            .toList();
        final rejectedRequests = allRequests
            .where((r) => r.status == 'REJEITADA' || r.status == 'CANCELADA')
            .toList();

        setState(() {
          _activeList = [...pendingRequests, ...activeLoans];
          _historyList = [...historyLoans, ...rejectedRequests];

          _isLoading = false;
        });
      } catch (e) {
        debugPrint("Erro ao carregar empréstimos: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
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
                  isSelected: _currentIndex == 0,
                  onTap: () => _onTabChanged(0),
                ),
              ),
              Expanded(
                child: _FilterButton(
                  label: 'Histórico',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onTabChanged(1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: [
                    _LoansListSimple(
                      loans: _activeList,
                      isHistory: false,
                      onRetry: _loadAllLoans,
                    ),
                    _LoansListSimple(
                      loans: _historyList,
                      isHistory: true,
                      onRetry: _loadAllLoans,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _LoansListSimple extends StatelessWidget {
  final List<Loan> loans;
  final bool isHistory;
  final VoidCallback onRetry;

  const _LoansListSimple({
    required this.loans,
    required this.isHistory,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHistory ? Icons.history : Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isHistory
                  ? 'Nenhum histórico encontrado.'
                  : 'Nenhum empréstimo ou solicitação ativa.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(onPressed: onRetry, child: const Text('Atualizar')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20, top: 8),
        itemCount: loans.length,
        itemBuilder: (context, index) {
          final loan = loans[index];
          return LoanCard(
            loan: loan,
            isRequest: loan.isRequest, // Passa a flag corretamente
          );
        },
      ),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
