<div align="center">
  <!-- Banner -->
  <a href="https://n33miaz.github.io/n33miaz-links/#lumitcc"><img width="100%" src="https://github-stats-api-onkr.onrender.com/api/banner?title=LumiLivre&subtitle=Library%20Management%20System&tag=(TCC)%20Bachelor%27s%20Thesis&title_color=762075&text_color=c9d1d9&v=1" /></a>

  <!-- Pins-->
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiweb"><img src="https://github-stats-api-onkr.onrender.com/api/pin?username=n33miaz&repo=lumilivre-web&custom_title=WebSite&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=270&show_description=false&v=1" /></a>
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiapp"><img src="https://github-stats-api-onkr.onrender.com/api/pin?username=n33miaz&repo=lumilivre-app&custom_title=Application&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=270&show_description=false&v=1" /></a>
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiapi"><img src="https://github-stats-api-onkr.onrender.com/api/pin?username=n33miaz&repo=lumilivre-api&custom_title=API%20Restfull&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=270&show_description=false&v=1" /></a>
</div>

<br/>

<div align="center">

![License](https://img.shields.io/badge/license-MIT-purple?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?style=flat-square&logo=dart)
![Android](https://img.shields.io/badge/Android-ready-3DDC84?style=flat-square&logo=android)
![iOS](https://img.shields.io/badge/iOS-ready-000000?style=flat-square&logo=apple)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-blue?style=flat-square&logo=githubactions)

</div>

<br/>

<div align="center">
  <h1>Sobre o Projeto</h1>
</div>

O **LumiLivre APP** é a ponta do ecossistema voltada para os **alunos**. Desenvolvido em **Flutter**, o aplicativo funciona como uma vitrine digital, permitindo que os estudantes explorem o acervo da biblioteca, verifiquem a disponibilidade de livros e realizem solicitações de empréstimo de forma autônoma.

Diferente de sistemas tradicionais, o app foca na experiência do usuário (UX), oferecendo recursos como **Gamificação (Ranking de Leitura)**, **Modo Offline** para consulta de catálogo e **Autenticação Biométrica**.

<br/>

<div align="center">
  <h1>Screenshots</h1>
</div>

<div align="center">
  <img src="assets/images/prints/print_splash.jpg" width="200" alt="Splash Screen" style="border-radius: 15px; margin: 10px;">
  <img src="assets/images/prints/print_login.jpg" width="200" alt="Tela de Login" style="border-radius: 15px; margin: 10px;">
</div>

<br/>

<div align="center">
  <h1>Stack Técnica</h1>
</div>

| Camada | Tecnologia |
|--------|------------|
| Linguagem / SDK | Dart 3.9 + Flutter |
| Estado | Provider 6.1 (`ChangeNotifier`) |
| HTTP | `http` 1.5 (+ `dio` para clients gerados) |
| Persistência segura | **flutter_secure_storage** (token + user) |
| Persistência leve | `shared_preferences` (tema, favoritos) |
| UI | Material 3, `flutter_svg`, `cached_network_image`, Lottie |
| Segurança local | `local_auth` |
| Upload | `image_picker`, `http_parser` |
| Conectividade | `connectivity_plus`, `internet_connection_checker` |
| Contratos | **openapi-generator-cli** (scripts/generate_api) |
| Testes | `flutter_test`, `flutter_lints` |
| Build por ambiente | **Flavors Android (dev/staging/prod)** + `--dart-define=API_BASE_URL` |

<br/>

<div align="center">
  <h1>Funcionalidades Principais</h1>
</div>

### 📚 Catálogo & Busca
- **Vitrine Virtual:** carrosséis por categoria com **infinite scroll**.
- **Busca Inteligente:** por título, autor ou ISBN.
- **Detalhes do Livro:** sinopse, classificação, disponibilidade em tempo real (estoque físico).
- **Modo Offline:** cache local via `SharedPreferences` (`catalog_cache_v1`) com stale-while-revalidate.

### 🔄 Empréstimos & Solicitações
- **Solicitação Digital:** aluno solicita pelo app, bibliotecário aprova no web.
- **Status em Tempo Real** (PENDENTE/ACEITA/REJEITADA).
- **Histórico** de empréstimos e solicitações.

### 👤 Perfil & Gamificação
- **Ranking** de leitores com filtros por curso/módulo/turno.
- **Foto de perfil** com upload para Supabase.
- **Favoritos** locais por ID.

### ⚙️ Recursos Técnicos Avançados
- **Secure Storage:** token JWT em `flutter_secure_storage` (Keystore/Keychain).
- **Restore de sessão** no boot (`tryAutoLogin` em `main.dart` + splash durante validação).
- **Biometria:** suporte via `local_auth`.
- **Temas:** claro / escuro / sistema.
- **ApiService** dividido em facade (`AuthApi`, `BookApi`, `CatalogApi`, `LoanApi`, `RankingApi`, `StudentApi`, `UploadApi`) — cada domínio abaixo de 200 linhas.

### Ambientes

O app usa **flavors Android** e `--dart-define=API_BASE_URL` para selecionar a API:

```bash
flutter run --flavor dev     --dart-define=API_BASE_URL=http://127.0.0.1:8080
flutter run --flavor staging --dart-define=API_BASE_URL=https://staging.lumilivre.example
flutter run --flavor prod
```

Sem `API_BASE_URL`, o app usa `https://lumilivre-api.onrender.com`.

<br/>

<div align="center">
  <h1>Arquitetura do Sistema</h1>
</div>

Utilizamos uma arquitetura cliente-servidor moderna baseada em microsserviços e nuvem para garantir escalabilidade.

```mermaid
flowchart TD
    classDef mobile fill:#02569B,stroke:#fff,stroke-width:2px,color:#fff;
    classDef web fill:#61DAFB,stroke:#fff,stroke-width:2px,color:#000;
    classDef api fill:#762075,stroke:#fff,stroke-width:2px,color:#fff;
    classDef db fill:#336791,stroke:#fff,stroke-width:2px,color:#fff;
    classDef storage fill:#3ECF8E,stroke:#fff,stroke-width:2px,color:#fff;
    classDef external fill:#ddd,stroke:#333,stroke-width:1px,color:#000,stroke-dasharray: 5 5;

    UserMobile["Application (Aluno)"]:::mobile
    UserWeb["WebSite (Bibliotecário)"]:::web

    subgraph Cloud["-"]
        direction TB
        API["API RestFull"]:::api
        DB[("PostgreSQL")]:::db
        Storage["Supabase Storage"]:::storage
    end

    External["Google Books / BrasilAPI"]:::external

    UserMobile -->|REST API / JSON| API
    UserWeb -->|REST API / JSON| API

    API -->|JPA / Hibernate| DB
    API -->|Upload Capas e PDF's| Storage
    API -.->|Consulta Metadados| External
```

### Estrutura interna

```
lib/
  main.dart                 (bootstrap + tryAutoLogin + splash)
  providers/                (AuthProvider, ThemeProvider, FavoritesProvider)
  services/                 (ApiService facade + AuthApi/BookApi/CatalogApi/LoanApi/RankingApi/StudentApi/UploadApi)
  services/auth_storage.dart (flutter_secure_storage)
  api/gen/                  (clients gerados pelo openapi-generator-cli)
  models/ · screens/ · widgets/ · utils/
assets/ (images, icons, animations)
android/ · ios/ · web/
test/    (providers, services, models, utils, bootstrap)
scripts/ (generate_api.sh | .bat)
```

<br/>

<div align="center">
  <h1>Segurança</h1>
</div>

- **Autenticação JWT** em todas as requisições sensíveis.
- **Secure Storage** (Keystore/Keychain) para token e dados de usuário.
- **Validação de Senha Inicial** no primeiro acesso (bloqueia navegação principal até a troca).
- **Convidado** navega sem token, mas não consegue solicitar empréstimo nem acessar dados pessoais.

<br/>

<div align="center">
  <h1>Como rodar localmente</h1>
</div>

```powershell
# 1. Dependências
flutter pub get

# 2. Gerar clients OpenAPI (opcional; requer API com /v3/api-docs)
.\scripts\generate_api.bat

# 3. Executar
flutter run --flavor dev --dart-define=API_BASE_URL=http://10.0.2.2:8080

# 4. Testes
flutter analyze
flutter test

# 5. Build de produção
flutter build apk --flavor prod --dart-define=API_BASE_URL=https://api.lumilivre.com.br
flutter build ios --flavor prod --dart-define=API_BASE_URL=https://api.lumilivre.com.br
```

<br/>

<div align="center">
  <h1>Licença</h1>
</div>

Distribuído sob a licença **MIT**. Veja `LICENSE` para mais detalhes.

<br/>

<div align="center">
  <sub>LumiLivre © 2026 - Todos os direitos reservados.</sub>
</div>
