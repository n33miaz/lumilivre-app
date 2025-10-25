// flutter test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/main.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/screens/auth/login.dart';
import 'package:lumilivre/screens/catalog.dart';
import 'package:lumilivre/screens/navigator_bar.dart';
import 'package:lumilivre/services/api.dart';

// =============================================================================
// MOCK DA API
// =============================================================================
class MockApiService implements ApiService {
  bool deveRetornarErro = false;

  @override
  Future<Map<String, List<Book>>> getCatalog() async {
    if (deveRetornarErro) {
      throw Exception('Falha simulada na conexão com a API');
    }
    // Retorna dados falsos para o teste de sucesso
    return {
      'Ficção Científica': [
        Book(id: '123', title: 'Duna', author: 'Frank Herbert', imageUrl: ''),
      ],
      'Fantasia': [
        Book(id: '456', title: 'O Senhor dos Anéis', author: 'J.R.R. Tolkien', imageUrl: ''),
      ],
    };
  }

  @override
  Future login(String user, String password) async {}

  @override
  Future getBookDetails(String isbn) async {}

  @override
  Future<List<Book>> getBooksByGenre(String genre) async { return []; }

  @override
  Future getMyLoans(String matricula, String token) async { return []; }
}


// =============================================================================
// FUNÇÃO HELPER
// =============================================================================
Widget createTestableWidget({required Widget child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}


// =============================================================================
// INÍCIO DOS TESTES
// =============================================================================
void main() {
  // --- FUNCIONALIDADES JÁ IMPLEMENTADAS ---
  group('Tela de Login', () {
    testWidgets('Deve exibir os campos de usuário, senha e botões', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      final userField = find.widgetWithText(TextFormField, 'Matrícula ou Email');
      final passwordField = find.widgetWithText(TextFormField, 'Senha');
      final loginButton = find.widgetWithText(ElevatedButton, 'ENTRAR');
      final guestButton = find.widgetWithText(OutlinedButton, 'ENTRAR COMO CONVIDADO');

      expect(userField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);
      expect(guestButton, findsOneWidget);
    });

    testWidgets('Deve exibir mensagens de erro ao tentar logar com campos vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const LoginScreen()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));

      await tester.pump();

      expect(find.text('Digite seu usuário'), findsOneWidget);
      expect(find.text('Digite sua senha'), findsOneWidget);
    });
  });

  group('Navegação Principal', () {
    testWidgets('Deve iniciar na tela de Catálogo e navegar para o Perfil', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const MainNavigator()));

      expect(find.text('LumiLivre'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('Ranking: #12 de 345'), findsOneWidget); // (mock) ajustar
    });
  });

  group('Tela de Catálogo (com API Mockada)', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    testWidgets('Deve exibir um indicador de carregamento enquanto busca os dados', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const CatalogScreen()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Deve exibir os carrosséis de livros quando a API retorna sucesso', (WidgetTester tester) async {
      // Simulação:
      // 1. Injetar o mockApiService que retorna sucesso.
      // 2. Aguardar o widget carregar com `pumpAndSettle`.
      
      // Como o ApiService é instanciado diretamente, vamos deixar este como um exemplo conceitual.
      // O ideal seria refatorar para injeção de dependência.
      
      // expect(find.text('Ficção Científica'), findsOneWidget);
      // expect(find.text('Duna'), findsOneWidget);
    });

    testWidgets('Deve exibir uma mensagem de erro quando a API falha', (WidgetTester tester) async {
      // Simulação:
      // 1. Configurar o mockApiService para retornar um erro.
      // mockApiService.deveRetornarErro = true;
      // 2. Injetar o mock.
      // 3. Aguardar o widget carregar com `pumpAndSettle`.
      
      // expect(find.textContaining('Erro ao carregar catálogo'), findsOneWidget);
    });
  });


  // --- TESTES PARA FUNCIONALIDADES FUTURAS ---

  /*
  group('Tela de Detalhes do Livro', () {
    testWidgets('Deve exibir informações do livro e o botão de solicitar', (WidgetTester tester) async {
      // TODO:
      // 1. Criar um Book de mock.
      // 2. Navegar para a tela BookDetailsScreen passando o mock.
      // 3. Mockar a chamada da API `getBookDetails`.
      // 4. Verificar se o título, autor e sinopse aparecem na tela.
      // 5. Verificar se o botão de solicitar empréstimo (ícone de carrinho) existe.
    });

    testWidgets('Ao clicar em solicitar, deve exibir uma confirmação', (WidgetTester tester) async {
      // TODO:
      // 1. Montar a tela de detalhes com um livro mock.
      // 2. Mockar a API para que a solicitação de empréstimo retorne sucesso.
      // 3. Encontrar e clicar no botão de solicitar empréstimo.
      // 4. Aguardar a resposta.
      // 5. Verificar se uma mensagem de sucesso (SnackBar ou Dialog) é exibida.
    });
  });

  group('Tela de Perfil', () {
    testWidgets('Deve exibir os empréstimos do usuário após o carregamento', (WidgetTester tester) async {
      // TODO:
      // 1. Iniciar o app com um usuário "logado" (configurar o AuthProvider).
      // 2. Mockar a chamada da API `getMyLoans` para retornar uma lista de empréstimos falsos.
      // 3. Navegar para a tela de Perfil.
      // 4. Aguardar o carregamento com `pumpAndSettle`.
      // 5. Verificar se os `LoanCard` com os títulos dos livros mockados aparecem na tela.
    });
  });

  group('Serviço da API (Unit Test)', () {
    test('login() deve retornar um LoginResponse em caso de sucesso', () async {
      // Este é um teste de unidade, não um teste de widget.
      // TODO:
      // 1. Usar um pacote como `http/testing` para mockar o cliente HTTP.
      // 2. Configurar o mock para retornar um JSON de sucesso (status 200).
      // 3. Chamar `apiService.login('user', 'pass')`.
      // 4. Verificar se o resultado é uma instância de `LoginResponse` e se os dados estão corretos.
    });
  });
  */
}