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
  Future<List<Loan>>? _loansFuture;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLoans();
    });
  }

  void _loadLoans() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated &&
        authProvider.user?.matriculaAluno != null) {
      final matricula = authProvider.user!.matriculaAluno!;
      final token = authProvider.user!.token;

      setState(() {
        if (_showHistory) {
          _loansFuture = _apiService.getMyLoansHistory(matricula, token);
        } else {
          _loansFuture = _apiService.getMyLoans(matricula, token);
        }
      });
    }
  }

  void _toggleLoanView(bool showHistory) {
    if (_showHistory != showHistory) {
      setState(() {
        _showHistory = showHistory;
      });
      _loadLoans();
    }
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
                    onPressed: _loadLoans,
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
            return LoanCard(loan: loans[index]);
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
