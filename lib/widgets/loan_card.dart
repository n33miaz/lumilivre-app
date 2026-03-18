import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/loan.dart';
import '../utils/constants.dart';

enum LoanCardStatus { active, dueToday, overdue, pending, rejected, returned }

class LoanCard extends StatelessWidget {
  final Loan loan;
  final bool isRequest;

  const LoanCard({super.key, required this.loan, this.isRequest = false});

  (LoanCardStatus, Color, String, IconData) _getStatusAttributes() {
    if (isRequest) {
      if (loan.status == 'REJEITADA') {
        return (
          LoanCardStatus.rejected,
          Colors.grey.shade600,
          'Solicitação Recusada',
          Icons.cancel_outlined,
        );
      }
      return (
        LoanCardStatus.pending,
        LumiLivreTheme.primary,
        'Aguardando Aprovação',
        Icons.hourglass_empty,
      );
    }

    if (loan.status == 'CONCLUIDO') {
      return (
        LoanCardStatus.returned,
        Colors.grey,
        'Devolvido',
        Icons.check_circle_outline,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      loan.dataDevolucao.year,
      loan.dataDevolucao.month,
      loan.dataDevolucao.day,
    );

    final difference = due.difference(today).inDays;

    if (difference < 0) {
      return (
        LoanCardStatus.overdue,
        Colors.redAccent,
        'Atrasado (${difference.abs()} dias)',
        Icons.warning_amber_rounded,
      );
    } else if (difference == 0) {
      return (
        LoanCardStatus.dueToday,
        Colors.orange,
        'Vence Hoje!',
        Icons.access_time,
      );
    } else {
      return (
        LoanCardStatus.active,
        Colors.green,
        'Devolve em $difference dias',
        Icons.calendar_today,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusEnum, statusColor, statusText, statusIcon) =
        _getStatusAttributes();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 130,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- CAPA ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              loan.imagemUrl ??
                  'https://via.placeholder.com/100x150.png?text=Lumi',
              width: 90,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 130,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.book, color: Colors.grey),
                );
              },
            ),
          ),

          // --- INFORMAÇÕES ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Título e Data
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.livroTitulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isRequest
                            ? 'Solicitado em: ${DateFormat('dd/MM/yyyy').format(loan.dataEmprestimo)}'
                            : 'Emprestado em: ${DateFormat('dd/MM/yyyy').format(loan.dataEmprestimo)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
