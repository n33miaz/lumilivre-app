import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/loan.dart';
import '../utils/constants.dart';

class LoanApi {
  LoanApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Loan>> getMyLoans(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/emprestimos/aluno/$matricula');

    try {
      final response = await _client
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao carregar empréstimos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro em getMyLoans: $e');
      return [];
    }
  }

  Future<List<Loan>> getMyRequests(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/solicitacoes/aluno/$matricula');

    try {
      final response = await _client
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Loan.fromRequestJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Erro ao buscar solicitações: $e');
      return [];
    }
  }

  Future<bool> requestLoan(String matricula, String tombo, String token) async {
    final url = Uri.parse(
      '$apiBaseUrl/solicitacoes/solicitar?matriculaAluno=$matricula&tomboExemplar=$tombo',
    );

    try {
      final response = await _client
          .post(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erro ao solicitar: $e');
      return false;
    }
  }

  Future<bool> requestLoanByBookId(
    String matricula,
    int livroId,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/solicitacoes/solicitar-mobile?matriculaAluno=$matricula&livroId=$livroId',
    );

    try {
      final response = await _client
          .post(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao solicitar: $e');
      return false;
    }
  }

  Future<List<Loan>> getMyLoansHistory(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/emprestimos/aluno/$matricula/historico');

    try {
      final response = await _client
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro em getMyLoansHistory: $e');
      return [];
    }
  }
}
