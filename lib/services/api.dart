import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/book_details.dart';
import '../models/loan.dart';

class ApiService {
  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'user': user, 'senha': password}),
      );

      if (response.statusCode == 200) {
        return loginResponseFromJson(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Falha no login');
      }
    } catch (e) {
      print('Erro na chamada de login: $e');
      throw Exception(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final url = Uri.parse('$apiBaseUrl/auth/esqueci-senha');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['mensagem'] ?? 'Solicitação enviada.';
      } else {
        throw Exception('Falha ao solicitar reset.');
      }
    } catch (e) {
      print('Erro em requestPasswordReset: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<bool> validateResetToken(String token) async {
    final url = Uri.parse('$apiBaseUrl/auth/validar-token/$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valido'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erro em validateResetToken: $e');
      return false;
    }
  }

  Future<String> changePasswordWithToken(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$apiBaseUrl/auth/mudar-senha');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'token': token, 'novaSenha': newPassword}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['mensagem'] ?? 'Senha alterada com sucesso.';
      } else {
        throw Exception(
          data['mensagem'] ?? 'Não foi possível alterar a senha.',
        );
      }
    } catch (e) {
      print('Erro em changePasswordWithToken: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<Map<String, List<Book>>> getCatalog() async {
    final url = Uri.parse('$apiBaseUrl/livros/catalogo-mobile');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        Map<String, List<Book>> catalog = {};

        for (var genreData in data) {
          String genreName = genreData['nome'];
          List<Book> books = (genreData['livros'] as List).map((bookData) {
            return Book(
              id: bookData['isbn'] ?? UniqueKey().toString(),
              title: bookData['titulo'],
              author: bookData['autor'],
              imageUrl:
                  bookData['imagem'] ??
                  'https://via.placeholder.com/140x210.png?text=No+Image',
            );
          }).toList();
          catalog[genreName] = books;
        }
        return catalog;
      } else {
        throw Exception('Falha ao carregar o catálogo.');
      }
    } catch (e) {
      print('Erro em getCatalog: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<BookDetails> getBookDetails(String isbn) async {
    final url = Uri.parse('$apiBaseUrl/livros/$isbn');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return bookDetailsFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao carregar detalhes do livro.');
      }
    } catch (e) {
      print('Erro em getBookDetails: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<List<Loan>> getMyLoans(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/emprestimos/aluno/$matricula/ativos');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao carregar empréstimos.');
      }
    } catch (e) {
      print('Erro em getMyLoans: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre) async {
    final url = Uri.parse('$apiBaseUrl/livros/genero/$genre');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        return data.map((bookData) {
          return Book(
            id:
                bookData['isbn'] ??
                UniqueKey().toString(),
            title: bookData['titulo'],
            author: bookData['autor'],
            imageUrl:
                bookData['imagem'] ??
                'https://via.placeholder.com/140x210.png?text=No+Image',
          );
        }).toList();
      } else {
        throw Exception('Falha ao carregar livros do gênero: $genre');
      }
    } catch (e) {
      print('Erro em getBooksByGenre: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}
