import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/loan.dart';
import '../models/loan_status_code.dart';
import '../utils/constants.dart';

enum LoanCardStatus { active, dueToday, overdue, pending, rejected, returned }

class LoanCard extends StatelessWidget {
  final Loan loan;
  final bool isRequest;

  const LoanCard({super.key, required this.loan, this.isRequest = false});

  /// Cor, texto e ícone do selo de status.
  ///
  /// As comparações eram com o código pt-BR do enum (`REJEITADA`, `CONCLUIDO`) e
  /// a API manda o nome do enum em inglês, então nenhuma casava. Não era detalhe
  /// cosmético: sem reconhecer `COMPLETED`, todo empréstimo do histórico caía no
  /// cálculo de prazo abaixo e aparecia em vermelho como "Atrasado (N dias)" —
  /// justamente porque já foi devolvido e a data de devolução ficou no passado.
  ///
  /// As cores vêm da paleta de status e do esquema do tema, não de `Colors.*`: o
  /// selo é tinta sobre a carta, e `Colors.green`/`Colors.grey` cravados eram
  /// escuros sobre a carta escura.
  (LoanCardStatus, Color, String, IconData) _getStatusAttributes(
    AppLocalizations l10n,
    LumiStatusColors statusColors,
    ColorScheme scheme,
  ) {
    final code = loan.statusCode;

    if (isRequest) {
      if (code.isClosedRequest) {
        return (
          LoanCardStatus.rejected,
          scheme.onSurfaceVariant,
          l10n.loanStatusRejected,
          Icons.cancel_outlined,
        );
      }
      return (
        LoanCardStatus.pending,
        scheme.primary,
        l10n.loanStatusPending,
        Icons.hourglass_empty,
      );
    }

    if (code.isReturnedLoan) {
      return (
        LoanCardStatus.returned,
        scheme.onSurfaceVariant,
        l10n.loanStatusReturned,
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
        statusColors.danger,
        l10n.loanStatusOverdue(difference.abs()),
        Icons.warning_amber_rounded,
      );
    } else if (difference == 0) {
      return (
        LoanCardStatus.dueToday,
        statusColors.warning,
        l10n.loanStatusDueToday,
        Icons.access_time,
      );
    } else {
      return (
        LoanCardStatus.active,
        statusColors.success,
        l10n.loanStatusDueInDays(difference),
        Icons.calendar_today,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final startDate = DateFormat('dd/MM/yyyy').format(loan.dataEmprestimo);
    final (
      statusEnum,
      statusColor,
      statusText,
      statusIcon,
    ) = _getStatusAttributes(
      l10n,
      LumiStatusColors.of(context),
      theme.colorScheme,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 130,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(LumiLivreTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
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
              topLeft: Radius.circular(LumiLivreTheme.radiusCard),
              bottomLeft: Radius.circular(LumiLivreTheme.radiusCard),
            ),
            child: _buildCover(loan.imagemUrl),
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
                            ? l10n.loanRequestedOn(startDate)
                            : l10n.loanBorrowedOn(startDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
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

  /// Capa do exemplar. Sem URL (ou se o download falhar) cai na capa padrao
  /// local — o placeholder remoto que existia aqui saiu do ar.
  Widget _buildCover(String? imageUrl) {
    const width = 90.0;
    const height = 130.0;

    Widget fallback() => Image.asset(
      'assets/images/capa-padrao.png',
      width: width,
      height: height,
      fit: BoxFit.cover,
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return fallback();
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback(),
    );
  }
}
