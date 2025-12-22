<div align="center">
  <!-- Banner -->
  <a href="https://n33miaz.github.io/n33miaz-links/#lumitcc">
    <img width="100%" src="https://github-stats-api-fmwm.onrender.com/api/banner?title=LumiLivre&subtitle=Library%20Management%20System&tag=(TCC)%20Bachelor%27s%20Thesis&title_color=762075&text_color=c9d1d9&v=1" alt="LumiLivre Banner" />
  </a>

  <!-- Pins dos Repositórios -->
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiweb"><img src="https://github-stats-api-fmwm.onrender.com/api/pin?username=n33miaz&repo=lumilivre-web&custom_title=WebSite&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=280" height="140" /></a>&nbsp;&nbsp;&nbsp;
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiapp"><img src="https://github-stats-api-fmwm.onrender.com/api/pin?username=n33miaz&repo=lumilivre-app&custom_title=Application&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=280" height="140" /></a>&nbsp;&nbsp;&nbsp;
  <a href="https://n33miaz.github.io/n33miaz-links/#lumiapi"><img src="https://github-stats-api-fmwm.onrender.com/api/pin?username=n33miaz&repo=lumilivre-api&custom_title=API%20Restfull&bg_color=0d1117&title_color=762075&text_color=c9d1d9&icon_color=762075&hide_border=true&min_width=280" height="140" /></a>
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
  <h1>Funcionalidades Principais</h1>
</div>

### 📚 Catálogo & Busca
- **Vitrine Virtual:** Carrosséis de livros organizados por categorias (Aventura, Romance, TCCs, etc.).
- **Busca Inteligente:** Pesquisa por título, autor ou ISBN.
- **Detalhes do Livro:** Sinopse, classificação etária, número de páginas e **disponibilidade em tempo real** (integração com estoque físico).

### 🔄 Empréstimos & Solicitações
- **Solicitação Digital:** O aluno solicita um livro pelo app e aguarda a aprovação do bibliotecário.
- **Status em Tempo Real:** Acompanhamento de solicitações (Pendente, Aprovado, Recusado).
- **Histórico:** Visualização de todos os empréstimos já realizados e devolvidos.

### 👤 Perfil & Gamificação
- **Ranking de Leitores:** Sistema de gamificação que exibe os alunos que mais leem na instituição.
- **Carteirinha Virtual:** Dados do aluno e foto de perfil integrados.
- **Favoritos:** Lista de desejos para leituras futuras.

### ⚙️ Recursos Técnicos Avançados
- **Modo Offline (Cache):** O catálogo é salvo localmente (`SharedPreferences`), permitindo consulta mesmo sem internet.
- **Biometria:** Login rápido utilizando impressão digital ou reconhecimento facial (`local_auth`).
- **Temas:** Suporte completo a **Modo Claro** e **Modo Escuro**.

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

<br/>

<div align="center">
  <h1>Segurança</h1>
</div>

- **Autenticação JWT:** Todas as requisições sensíveis utilizam tokens JWT validados pelo backend.
- **Secure Storage:** O token é armazenado de forma segura no dispositivo.
- **Validação de Senha Inicial:** O app força a troca de senha no primeiro acesso para garantir a segurança da conta do aluno.

<br/>

<div align="center">
  <sub>LumiLivre © 2025 - Todos os direitos reservados.</sub>
</div>
