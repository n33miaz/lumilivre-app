import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/loan.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;

  const LoanCard({super.key, required this.loan});

  (String, Color) _getRemainingTime() {
    final now = DateTime.now();
    final difference = loan.dataDevolucao.difference(now);
    final days = difference.inDays;

    if (days < 0) {
      return (
        'Atrasado ${days.abs()} ${days.abs() == 1 ? 'dia' : 'dias'}',
        Colors.redAccent,
      );
    }
    if (days == 0) {
      return ('Vence hoje', Colors.orangeAccent);
    }
    if (days <= 7) {
      return (
        '${days + 1} ${days + 1 == 1 ? 'dia' : 'dias'} restantes',
        Colors.orangeAccent,
      );
    }
    return ('${(days / 7).ceil()} semanas restantes', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    final (remainingTime, timeColor) = _getRemainingTime();
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Capa do Livro
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                loan.imagemUrl ??
                    'https://via.placeholder.com/80x120.png?text=Lumi',
                width: 80,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Detalhes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loan.livroTitulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Retirado em: ${DateFormat('dd/MM/yyyy').format(loan.dataEmprestimo)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tags',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.timer_outlined, size: 16, color: timeColor),
                      const SizedBox(width: 4),
                      Text(
                        remainingTime,
                        style: TextStyle(
                          color: timeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
