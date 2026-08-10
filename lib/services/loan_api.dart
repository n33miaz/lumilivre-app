import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/loan.dart';
import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

class LoanApi {
  LoanApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Loan>> getMyLoans(
    String readerRegistrationNumber,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/loans/reader/$readerRegistrationNumber',
    );

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      }
      throw Exception('Falha ao carregar emprestimos: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro em getMyLoans: $e');
      return [];
    }
  }

  Future<List<Loan>> getMyRequests(
    String readerRegistrationNumber,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/loan-requests/reader/$readerRegistrationNumber',
    );

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .map((item) => Loan.fromRequestJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar solicitacoes: $e');
      return [];
    }
  }

  Future<bool> requestLoan(
    String readerRegistrationNumber,
    String tombo,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/loan-requests?readerRegistrationNumber=$readerRegistrationNumber&copyCode=$tombo',
    );

    try {
      final response = await _client
          .post(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao solicitar: $e');
      return false;
    }
  }

  /// Solicita empréstimo do livro. Volta em silêncio quando dá certo e joga
  /// [ApiException] quando não — com [ApiException.apiMessage] preenchido sempre
  /// que o servidor explicou a recusa.
  ///
  /// Antes devolvia `bool` e a tela improvisava "Erro ao solicitar. Verifique se
  /// há exemplares." para qualquer coisa: penalidade ativa, limite de três
  /// empréstimos, exemplar que outro leitor pegou primeiro. As três recusas vêm
  /// do `RequestApprovalPolicy` com frase própria e traduzida — descartá-las era
  /// jogar fora a única informação útil.
  Future<void> requestLoanByBookId(
    String readerRegistrationNumber,
    String livroId,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/loan-requests/by-book?readerRegistrationNumber=$readerRegistrationNumber&bookId=$livroId',
    );

    try {
      final response = await _client
          .post(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw ApiException.fromResponse(response);
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) debugPrint('Erro ao solicitar: $failure');
      throw failure;
    }
  }

  /// Histórico de empréstimos devolvidos do leitor.
  ///
  /// Joga [ApiException] em vez de devolver lista vazia. Engolir a falha
  /// transformava "não deu para buscar" em "você nunca pegou um livro": a tela
  /// mostrava o estado vazio do histórico depois de uma queda de rede, e não
  /// tinha como oferecer nova tentativa porque não sabia que algo falhou.
  Future<List<Loan>> getMyLoansHistory(
    String readerRegistrationNumber,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/loans/reader/$readerRegistrationNumber/history',
    );

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      }
      if (response.statusCode == 204) {
        return [];
      }
      throw ApiException.fromResponse(response);
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) {
        debugPrint('Erro em getMyLoansHistory: $failure');
      }
      throw failure;
    }
  }
}
