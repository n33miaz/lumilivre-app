import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/loan.dart';
import '../utils/constants.dart';
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      }
      throw Exception('Falha ao carregar emprestimos: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro em getMyLoans: $e');
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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .map((item) => Loan.fromRequestJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar solicitacoes: $e');
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
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao solicitar: $e');
      return false;
    }
  }

  Future<bool> requestLoanByBookId(
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
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Erro ao solicitar: $e');
      return false;
    }
  }

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
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      }
      throw Exception('Falha ao carregar historico: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro em getMyLoansHistory: $e');
      return [];
    }
  }
}
