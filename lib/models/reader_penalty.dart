import 'package:flutter/foundation.dart';

/// Penalidade do leitor, como a API conta.
///
/// Vem de `GET /api/readers/{matricula}` (`ReaderResponse`): `penaltyCode` é um
/// par `{code, label}` já traduzido pelo servidor, e `penaltyExpiresAt` é a data
/// em que a restrição deixa de valer.
///
/// A data importa tanto quanto o código. As políticas da API
/// (`RequestApprovalPolicy`, `LoanPolicy`, `ReservationPolicy`) só recusam
/// quando `penaltyExpiresAt` está no futuro — o código sozinho é histórico. O app
/// olhava apenas o código, então um leitor cuja penalidade venceu continuava
/// vendo o botão de solicitar travado enquanto o servidor teria aceitado o
/// pedido. [blocksLoans] existe para o app parar de discordar do servidor.
@immutable
class ReaderPenalty {
  const ReaderPenalty({
    required this.code,
    required this.label,
    this.expiresAt,
  });

  /// Código estável (`WARNING`, `BLOCK`, …), para lógica.
  final String code;

  /// Rótulo do código no idioma da requisição ("Advertência", "Warning").
  final String label;

  /// Quando a restrição termina. `null` significa penalidade registrada que não
  /// impede nada — a API não bloqueia sem data.
  final DateTime? expiresAt;

  bool get blocksLoans {
    final expiry = expiresAt;
    return expiry != null && expiry.isAfter(DateTime.now());
  }

  /// Lê a penalidade de dentro da resposta de leitor. Devolve `null` quando não
  /// há penalidade ou quando o campo veio fora do formato esperado — ausência de
  /// dado não pode virar aviso na tela do aluno.
  static ReaderPenalty? fromReaderJson(Map<String, dynamic> json) {
    final raw = json['penaltyCode'];
    if (raw is! Map) {
      return null;
    }

    final code = raw['code']?.toString();
    if (code == null || code.isEmpty) {
      return null;
    }

    final label = raw['label']?.toString();
    final expiresAt = DateTime.tryParse(
      json['penaltyExpiresAt']?.toString() ?? '',
    );

    return ReaderPenalty(
      code: code,
      label: (label == null || label.isEmpty) ? code : label,
      expiresAt: expiresAt?.toLocal(),
    );
  }
}
