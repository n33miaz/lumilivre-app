# LumiLivre App - Project Context

## Objetivo

`lumilivre-app` e o aplicativo Flutter voltado aos alunos. Ele funciona como vitrine digital do acervo, consulta detalhes e disponibilidade, permite solicitacao de emprestimo, exibe emprestimos/historico, favoritos, ranking e dados de perfil. Tambem existe modo convidado para navegacao limitada.

## Stack Tecnologica

- Linguagem: Dart.
- Framework: Flutter.
- SDK Dart: `^3.9.2`.
- Estado: Provider 6.1 com `ChangeNotifier`.
- HTTP: `http` 1.5.
- Persistencia local: `shared_preferences`.
- UI/assets: Material, `flutter_svg`, `cached_network_image`, assets locais.
- Internacionalizacao/formatacao: `intl`.
- Links externos: `url_launcher`.
- Seguranca local: `local_auth` para preferencia de biometria.
- Upload/imagem: `image_picker`, `http_parser`.
- Conectividade: `connectivity_plus`, `internet_connection_checker`.
- Testes: `flutter_test`, `flutter_lints`.
- Geracao visual: `flutter_launcher_icons`, `flutter_native_splash`.

## Arquitetura Observada

O app usa uma arquitetura Flutter pragmatica orientada a telas:

- `main.dart`: bootstrap, tratamento global de erros e registro dos providers.
- `providers`: estado transversal de autenticacao, tema e favoritos.
- `services`: comunicacao REST e regra pura auxiliar.
- `models`: parse e normalizacao dos contratos recebidos da API.
- `screens`: telas e navegacao.
- `widgets`: componentes reutilizaveis.
- `utils`: constantes, tema e parsers.
- `test`: testes de providers, modelos, servicos e regras de status.

O padrao e proximo de MVVM/Provider, com `ChangeNotifier` como view model simples e `ApiService` como service/facade de dados. Nao ha separacao formal por Clean Architecture, mas a regra critica de status de emprestimo foi extraida para `LoanStatusCalculator`, o que melhora testabilidade e coesao.

## Modulos Principais

- Autenticacao:
  - Login por matricula ou email.
  - Modo convidado.
  - Persistencia de token e usuario em `SharedPreferences`.
  - Sinalizacao de senha inicial obrigatoria.
- Catalogo:
  - Busca catalogo agrupado por genero em `/livros/catalogo-mobile`.
  - Cache local `catalog_cache_v1`.
  - Stale-while-revalidate: mostra cache local e atualiza remoto em segundo plano.
  - Paginacao visual por categorias.
- Busca e categorias:
  - Busca por texto em `/livros/mobile/buscar`.
  - Navegacao por categorias fixas e endpoint `/livros/genero/{nomeGenero}`.
- Detalhes do livro:
  - Consulta `/livros/{id}`.
  - Calcula status local de emprestimo.
  - Envia solicitacao por livro em `/solicitacoes/solicitar-mobile`.
- Perfil:
  - Dados do aluno em `/alunos/{matricula}`.
  - Upload de foto em `/alunos/{matricula}/foto`.
  - Tabs de emprestimos, favoritos e ranking.
- Emprestimos:
  - Ativos em `/emprestimos/aluno/{matricula}`.
  - Historico em `/emprestimos/aluno/{matricula}/historico`.
  - Solicitacoes em `/solicitacoes/aluno/{matricula}`.
- Ranking:
  - `/emprestimos/ranking` com filtros de curso, modulo e turno.
  - Listas auxiliares: `/cursos/home`, `/modulos`, `/turnos`.
- Configuracoes:
  - Tema claro/escuro/sistema.
  - Alteracao de senha.
  - Logout.
  - Preferencia de biometria salva localmente.

## Autenticacao e Comunicacao

- `ApiService` e singleton e opera como facade para `AuthApi`, `BookApi`, `CatalogApi`, `LoanApi`, `RankingApi`, `StudentApi`, `UploadApi`.
- `AuthProvider.login` chama `ApiService.login`.
- Token JWT e `userData` residem em `flutter_secure_storage` (`AuthStorage`).
- Chamadas sensiveis enviam `Authorization: Bearer <token>`.
- `LoginResponse` espera `id`, `email`, `role`, `matriculaAluno`, `token` e `isInitialPassword`.
- `isInitialPassword=true` bloqueia o navegador principal ate o usuario trocar senha.
- Troca de senha usa `PUT /usuarios/alterar-senha`.
- Modo convidado nao autentica token e deve bloquear a solicitacao de emprestimo.
- `main.dart` invoca `tryAutoLogin` no bootstrap e exibe splash enquanto valida; `app_bootstrap_test.dart` cobre os cenarios com/sem sessao.

## Regras de Negocio no App

`LoanStatusCalculator` define a regra de apresentacao do botao de emprestimo:

1. Emprestimo ativo do mesmo livro tem prioridade e vira `active` ou `overdue`.
2. Solicitacao pendente do mesmo livro vira `pending`.
3. Livro sem exemplares cadastrados vira `noCopies`.
4. Aluno com penalidade vira `blockedPenalty`.
5. Aluno com 3 ou mais emprestimos vira `limitReached`.
6. Livro sem exemplares disponiveis vira `unavailable`.
7. Caso contrario, vira `available`.

Outras regras locais:

- Convidado pode navegar, mas nao solicitar emprestimo nem ver dados pessoais.
- Favoritos sao locais por ID do livro.
- Tema e persistido localmente.
- Catalogo local e usado quando a rede falha.
- Imagens HTTP sao normalizadas para HTTPS em alguns parsers.
- Alteracao de senha exige senha atual, nova senha com minimo de 6 caracteres e confirmacao.

## Integracoes Externas

- LumiLivre API REST.
- `SharedPreferences` para cache e sessao local.
- `ImagePicker` para foto de perfil.
- `Connectivity` para banner offline.
- `url_launcher` abre fluxo web de "esqueci minha senha".
- `local_auth` verifica suporte e salva preferencia de biometria, mas o fluxo completo de login biometrico nao aparece implementado no codigo analisado.

## Estrutura de Pastas

```text
lib/
  main.dart
  models/
  providers/
  screens/
    auth/
  services/
  utils/
  widgets/
assets/
  animations/
  icons/
  images/
test/
  helpers/
  models/
  providers/
  screens/
  services/
  utils/
android/
ios/
web/
```

## Comandos Essenciais

```powershell
# instalar dependencias
flutter pub get

# executar localmente
flutter run

# executar testes
flutter test

# analisar lint
flutter analyze

# build Android
flutter build apk

# build Web
flutter build web

# build iOS em ambiente macOS
flutter build ios
```

## Configuracao de API

A URL da API e obtida em tempo de build via `--dart-define=API_BASE_URL=...` em `lib/utils/constants.dart` (fallback para localhost no desenvolvimento). Os tres flavors (dev/staging/prod) encapsulam o alvo em `android/app/build.gradle.kts`.

```powershell
flutter run --flavor dev --dart-define=API_BASE_URL=http://10.0.2.2:8080
flutter build apk --flavor prod --dart-define=API_BASE_URL=https://api.lumilivre.com.br
```

## Qualidade, Escalabilidade e Pontos de Atencao

- A extracao de `LoanStatusCalculator` e um bom exemplo de regra pura testavel.
- O app possui testes relevantes para modelos, providers, parsers, status de emprestimo e cache.
- Token e `userData` agora residem em `flutter_secure_storage` (`auth_storage.dart`); `SharedPreferences` fica restrito a tema e favoritos.
- `tryAutoLogin` e invocado no bootstrap (`main.dart`) e testado em `app_bootstrap_test.dart`.
- Biometria segue como preferencia local; fluxo completo ainda nao implementado.

## Evolucao Arquitetural Recente

- **Secure storage**: `AuthStorage` encapsula `FlutterSecureStorage` e migra dados legados do `SharedPreferences` de forma transparente.
- **Split de ApiService**: `ApiService` tornou-se facade delegando a `AuthApi`, `BookApi`, `CatalogApi`, `LoanApi`, `RankingApi`, `StudentApi`, `UploadApi` — cada arquivo abaixo de 200 linhas.
- **Flavors**: `android/app/build.gradle.kts` define dev/staging/prod com `applicationIdSuffix`, `versionNameSuffix` e `manifestPlaceholders`.
- **Bootstrap**: `main.dart` aguarda `tryAutoLogin` antes de decidir a `home`, exibindo splash enquanto valida a sessao.
- **Codegen OpenAPI**: `scripts/generate_api.sh|.bat` + `lib/api/gen/` preparam clients gerados via `openapi-generator-cli` (consome `/v3/api-docs` do backend).
- **CI**: `.github/workflows/ci.yml` roda `flutter analyze`, `flutter test --coverage` e `flutter build apk --flavor dev`.
