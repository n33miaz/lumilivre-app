/// Helpers reutilizáveis para testes do LumiLivre.
/// Centraliza fixtures e utilitários para DRY.
library;

import 'package:flutter/material.dart';

class BookFixtures {
  BookFixtures._();
  static const Map<String, dynamic> validApiResponse = {
    'id': 1,
    'titulo': 'Duna',
    'autor': 'Frank Herbert',
    'imagem': 'https://example.com/duna.jpg',
    'avaliacao': 4.8,
  };
  static const Map<String, dynamic> alternativeKeys = {
    'id': 2,
    'title': 'O Senhor dos Anéis',
    'author': 'J.R.R. Tolkien',
    'imageUrl': 'https://example.com/lotr.jpg',
    'rating': 4.9,
  };
  static const Map<String, dynamic> minimalData = {'id': 3};
  static const Map<String, dynamic> withStringNumbers = {
    'id': '10',
    'titulo': 'Test Book',
    'autor': 'Test Author',
    'imagem': '',
    'avaliacao': '4,5',
  };
  static const Map<String, dynamic> withNullValues = {
    'id': null,
    'titulo': null,
    'autor': null,
    'imagem': null,
    'avaliacao': null,
  };
}

class BookDetailsFixtures {
  BookDetailsFixtures._();
  static const Map<String, dynamic> validApiResponse = {
    'isbn': '978-3-16-148410-0',
    'nome': 'Duna',
    'dataLancamento': [1965, 8, 1],
    'numeroPaginas': 896,
    'cdd': '823',
    'editora': 'Ace Books',
    'classificacaoEtaria': 'Livre',
    'edicao': '1',
    'volume': 1,
    'sinopse': 'Uma saga épica no deserto.',
    'autor': 'Frank Herbert',
    'tipoCapa': 'Capa dura',
    'imagem': 'https://example.com/duna.jpg',
    'generos': ['Ficção Científica', 'Aventura'],
    'exemplaresDisponiveis': 3,
    'totalExemplares': 5,
    'avaliacao': 4.8,
  };
  static const Map<String, dynamic> minimalData = {
    'isbn': null,
    'nome': null,
    'dataLancamento': null,
    'numeroPaginas': null,
    'cdd': null,
    'editora': null,
    'classificacaoEtaria': null,
    'edicao': null,
    'sinopse': null,
    'autor': null,
    'tipoCapa': null,
    'generos': null,
    'exemplaresDisponiveis': null,
    'totalExemplares': null,
    'avaliacao': null,
  };
}

class LoanFixtures {
  LoanFixtures._();
  static const Map<String, dynamic> activeLoan = {
    'id': 1,
    'dataEmprestimo': [2025, 3, 1],
    'dataDevolucao': [2025, 3, 15],
    'status': 'ATIVO',
    'penalidade': null,
    'livroId': 10,
    'livroTitulo': 'Duna',
    'imagemUrl': 'https://example.com/duna.jpg',
  };
  static const Map<String, dynamic> overdueLoan = {
    'id': 2,
    'dataEmprestimo': [2024, 1, 1],
    'dataDevolucao': [2024, 1, 15],
    'status': 'ATRASADO',
    'penalidade': 'Multa',
    'livroId': 20,
    'livroTitulo': 'Livro Atrasado',
    'imagemUrl': null,
  };
  static const Map<String, dynamic> pendingRequest = {
    'id': 3,
    'dataSolicitacao': '2025-03-10T10:00:00',
    'status': 'PENDENTE',
    'livroId': 30,
    'livroNome': 'Livro Solicitado',
  };
  static const Map<String, dynamic> rejectedRequest = {
    'id': 4,
    'dataSolicitacao': '2025-03-05T10:00:00',
    'status': 'REJEITADA',
    'livroId': 40,
    'livroNome': 'Livro Rejeitado',
  };
}

class UserFixtures {
  UserFixtures._();
  static const Map<String, dynamic> validLoginResponse = {
    'id': 1,
    'email': 'aluno@escola.com',
    'role': 'ALUNO',
    'matriculaAluno': '2025001',
    'token': 'jwt-token-mock-123',
    'isInitialPassword': false,
  };
  static const Map<String, dynamic> initialPasswordUser = {
    'id': 2,
    'email': 'novo@escola.com',
    'role': 'ALUNO',
    'matriculaAluno': '2025002',
    'token': 'jwt-token-mock-456',
    'isInitialPassword': true,
  };
}

class RankingFixtures {
  RankingFixtures._();
  static const Map<String, dynamic> validItem = {
    'matricula': '2025001',
    'nome': 'João Silva',
    'emprestimosCount': 15,
  };
  static const Map<String, dynamic> minimalItem = {
    'matricula': null,
    'nome': null,
    'emprestimosCount': null,
  };
}

class CatalogFixtures {
  CatalogFixtures._();
  static const List<Map<String, dynamic>> validCatalog = [
    {
      'nome': 'Ficção Científica',
      'livros': [
        {
          'id': 1,
          'titulo': 'Duna',
          'autor': 'Frank Herbert',
          'imagem': 'https://example.com/duna.jpg',
          'avaliacao': 4.8,
        },
        {
          'id': 2,
          'titulo': 'Fundação',
          'autor': 'Isaac Asimov',
          'imagem': 'http://example.com/fundacao.jpg',
          'avaliacao': 4.7,
        },
      ],
    },
    {
      'nome': 'Romance',
      'livros': [
        {
          'id': 3,
          'titulo': 'Orgulho e Preconceito',
          'autor': 'Jane Austen',
          'imagem': '',
          'avaliacao': 4.5,
        },
      ],
    },
  ];
  static const List<Map<String, dynamic>> emptyGenre = [
    {'nome': 'Vazio', 'livros': []},
  ];
  static const List<Map<String, dynamic>> invalidEntries = [
    {'nome': null, 'livros': null},
    {
      'nome': 'Válido',
      'livros': [
        {
          'id': 1,
          'titulo': 'Livro OK',
          'autor': 'Autor OK',
          'imagem': '',
          'avaliacao': 0,
        },
      ],
    },
  ];
}

/// Cria widget testável com MaterialApp envolvendo o child.
Widget createTestableWidget({required Widget child, ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(),
    home: Scaffold(body: child),
  );
}
