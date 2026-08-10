import 'package:flutter/material.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://lumilivre-api.onrender.com',
);

class LumiLivreTheme {
  static const Color primary = Color(0xFF762075);
  static const Color label = Color(0xFFC964C5);

  // --------------------------------------------------------------------
  // Papel e tinta
  //
  // O app estava em cinza azulado (#F3F4F6 no claro, #111827/#1F2937 no
  // escuro) — o mesmo cinza frio de template que as superfícies públicas do
  // web abandonaram. Ele tem dois defeitos: é o tom que faz uma interface
  // parecer gerada, e por puxar para o azul coloca o roxo da marca na mesma
  // família do fundo, de modo que #762075 lê como mais um degrau do cinza em
  // vez de ler como cor. Papel levemente amarelado devolve saturação percebida
  // ao roxo sem encostar em #762075 nem em #C964C5.
  //
  // Os degraus são os mesmos do web, valor a valor, para o site e o app serem
  // a mesma família de papel. Cada par de texto foi medido contra o fundo em
  // que é usado — as razões estão anotadas onde o degrau entra no esquema.
  // --------------------------------------------------------------------

  /// Face da ficha: a carta do tema claro.
  static const Color _paper50 = Color(0xFFFFFDF9);

  /// Meio degrau entre a ficha e a tela. Não existe no web, que tem três
  /// superfícies; aqui o Material pede quatro (`surfaceContainer` e as duas
  /// acima dela), e sem este passo duas delas seriam a mesma cor.
  static const Color _paper75 = Color(0xFFFCF9F4);

  /// A tela.
  static const Color _paper100 = Color(0xFFF8F5EE);

  /// Faixa recuada: campo, trilho, pastilha de posição.
  static const Color _paper200 = Color(0xFFF0EBE0);

  /// Filete de 1 px: borda de carta, de campo, de lista.
  static const Color _paper300 = Color(0xFFE4DCCB);

  /// Marca fraca. Nunca texto.
  static const Color _paper400 = Color(0xFFC4B9A3);

  /// Texto secundário. É o degrau mais claro que ainda passa AA em corpo
  /// pequeno sobre [_paper200] (4,56:1); sobre a carta dá 5,34:1 e sobre a tela
  /// 4,98:1.
  static const Color _paper500 = Color(0xFF726957);

  /// Texto. 14,7:1 sobre a carta, 13,7:1 sobre a tela.
  static const Color _paper800 = Color(0xFF2A2721);

  /// Filete de 2 px e faixa de aviso do sistema. Um degrau abaixo do texto
  /// porque a régua é divisória, não letra.
  static const Color _paper900 = Color(0xFF1A1814);

  /// Tinta: texto do tema escuro. 16,7:1 sobre a carta, 17,6:1 sobre a tela.
  static const Color _ink100 = Color(0xFFF5F1E8);

  /// Filete do tema escuro, sempre com alfa (ver [_darkNeutrals]).
  static const Color _ink200 = Color(0xFFD8D2C6);

  /// Texto secundário do escuro. 7,2:1 sobre a carta, 5,7:1 sobre a faixa mais
  /// clara.
  static const Color _ink400 = Color(0xFFA79F92);

  /// Um degrau acima do web, pelo mesmo motivo de [_paper75]: é o preenchimento
  /// do campo de texto, que precisa se separar da carta do diálogo.
  static const Color _ink650 = Color(0xFF2A2437);

  static const Color _ink700 = Color(0xFF211C2B);
  static const Color _ink800 = Color(0xFF191424);

  /// A ficha no escuro.
  static const Color _ink900 = Color(0xFF13101B);

  /// A tela no escuro.
  static const Color _ink950 = Color(0xFF0B0810);

  static const Color lightBackground = _paper100;
  static const Color lightText = _paper800;
  static const Color lightCard = _paper50;

  static const Color darkBackground = _ink950;
  static const Color darkText = _ink100;
  static const Color darkCard = _ink900;

  /// Tinta sobre o roxo da marca — AppBar do mural, cabeçalho do perfil, barra
  /// inferior e botão preenchido, que são #762075 nos dois temas.
  ///
  /// Não é `colorScheme.onPrimary` de propósito: no tema escuro `primary` passa
  /// a ser o tom claro da marca (ver [darkTheme]) e o par dele é escuro. Aqui a
  /// superfície é sempre o roxo, então a tinta é sempre branca (9,4:1).
  static const Color onBrand = Colors.white;

  /// Coração de "curtido" — mora aqui para não existir um vermelho por tela.
  static const Color like = Colors.redAccent;

  /// Estrela de avaliação do cartão de livro.
  static const Color rating = Colors.amber;

  /// Raios de canto do app, em três degraus.
  ///
  /// Conviviam 8, 10, 12, 14, 16 e 20 escritos à mão, mais o 28 que o Material 3
  /// dá de graça ao `AlertDialog` — quatro deles só entre os modais. Um degrau
  /// por tipo de superfície: controle, cartão e modal.
  ///
  /// O web recorta a ficha em 2 px, porque papel é cortado e não arredondado.
  /// Aqui não: 2 px numa tela de celular transforma todo alvo de toque num
  /// retângulo duro, e a ergonomia móvel vem antes do motivo.
  static const double radiusControl = 12.0;
  static const double radiusCard = 14.0;
  static const double radiusModal = 20.0;

  /// Espessura do filete que marca cabeçalho de bloco.
  ///
  /// É a peça que substitui a sombra: no lugar de um cartão flutuante, uma
  /// régua com peso de divisória de gaveta de fichário. Ver [rule] e
  /// `SectionRule`.
  static const double ruleWidth = 2.0;

  /// Cor desse filete, resolvida pelo brilho do tema.
  ///
  /// No claro é o degrau mais escuro do papel — mais escuro que o próprio texto,
  /// porque a régua é traço e não letra. No escuro é a tinta a 80%: cheia, ela
  /// vira uma barra branca atravessando a tela.
  static Color rule(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? _ink100.withValues(alpha: 0.8)
      : _paper900;

  static const _NeutralScale _lightNeutrals = _NeutralScale(
    background: _paper100,
    surface: _paper50,
    container: _paper75,
    containerHigh: _paper100,
    containerHighest: _paper200,
    line: _paper300,
    lineStrong: _paper400,
    muted: _paper500,
    text: _paper800,
    inverse: _paper900,
    onInverse: _paper50,
  );

  /// No escuro os filetes são a tinta com alfa, e não um cinza opaco: a mesma
  /// borda corre sobre a tela (#0B0810) e sobre a carta (#13101B), e um valor
  /// fixo só poderia acertar uma das duas.
  static final _NeutralScale _darkNeutrals = _NeutralScale(
    background: _ink950,
    surface: _ink900,
    container: _ink800,
    containerHigh: _ink700,
    containerHighest: _ink650,
    line: _ink200.withValues(alpha: 0.14),
    lineStrong: _ink200.withValues(alpha: 0.30),
    muted: _ink400,
    text: _ink100,
    inverse: _ink100,
    onInverse: _ink950,
  );

  /// No tema claro o roxo da marca se lê sobre papel (9,3:1 sobre a carta):
  /// serve de tinta e de superfície ao mesmo tempo.
  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    neutrals: _lightNeutrals,
    ink: primary,
  );

  /// No escuro #762075 sobre #0B0810 não se lê — era por isso que indicador de
  /// progresso, `TextButton` e título de seção sumiam. A tinta da marca passa a
  /// ser o tom claro (`label`, 5,5:1 sobre a carta), o mesmo papel que ele tem
  /// no web (`lumi-label`); o roxo continua sendo superfície de marca via
  /// `primaryColor`.
  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    neutrals: _darkNeutrals,
    ink: label,
  );

  /// Aproxima uma cor de destaque da tinta da superfície até ela se ler.
  ///
  /// Usada pelos selos que carregam uma cor de identidade (tipo de conteúdo do
  /// mural): a cor crua falha contraste nas duas pontas — #C964C5 sobre papel e
  /// #762075 sobre #13101B. O empurrão é maior no escuro porque a distância a
  /// vencer também é.
  static Color readableInk(BuildContext context, Color accent) {
    final scheme = Theme.of(context).colorScheme;
    final amount = scheme.brightness == Brightness.dark ? 0.5 : 0.25;
    return Color.lerp(accent, scheme.onSurface, amount)!;
  }

  static ThemeData _build({
    required Brightness brightness,
    required _NeutralScale neutrals,
    required Color ink,
  }) {
    final isDark = brightness == Brightness.dark;

    // Os cinzas do esquema semeado puxam para o marrom, porque saem do roxo da
    // marca, e o app tem a própria família. Neutro aqui, cor só onde é marca ou
    // status — agora com cada degrau escrito por extenso em vez de interpolado
    // entre a carta e o texto: o `lerp` era prático, mas o resultado perdia
    // justamente o amarelo que faz o papel ser papel.
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: ink,
      surface: neutrals.surface,
      onSurface: neutrals.text,
      surfaceContainer: neutrals.container,
      surfaceContainerHigh: neutrals.containerHigh,
      surfaceContainerHighest: neutrals.containerHighest,
      onSurfaceVariant: neutrals.muted,
      outline: neutrals.lineStrong,
      outlineVariant: neutrals.line,
      // Faixa de aviso do sistema e toast neutro: papel escuro sobre tinta
      // clara, e o contrário no tema escuro (17,5:1 e 17,6:1).
      inverseSurface: neutrals.inverse,
      onInverseSurface: neutrals.onInverse,
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusControl),
    );
    // A ficha do web é opaca com borda de 1 px; o modal aqui é o que mais se
    // parece com ela, e no escuro a borda é o que separa a carta da barreira.
    final modalShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusModal),
      side: BorderSide(color: neutrals.line),
    );

    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: neutrals.background,
      cardColor: neutrals.surface,
      colorScheme: scheme,
      // Um só tom de texto secundário: `hintColor` e `onSurfaceVariant` eram
      // dois cinzas diferentes usados para a mesma coisa em telas vizinhas.
      hintColor: scheme.onSurfaceVariant,
      // Toda linha de separação do app é o mesmo filete de 1 px do papel.
      dividerColor: neutrals.line,
      dividerTheme: DividerThemeData(color: neutrals.line, thickness: 1),
      // Barra das telas empilhadas. Sombra ao rolar sai; entra o filete, que é
      // a mesma peça que separa bloco de bloco dentro da página.
      appBarTheme: AppBarTheme(
        backgroundColor: neutrals.background,
        foregroundColor: neutrals.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: neutrals.line)),
        titleTextStyle: TextStyle(
          color: neutrals.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onBrand,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      // Mesmo botão de marca, outro nome: sem isto o `FilledButton` usava
      // `onPrimary`, que no escuro é escuro — texto escuro sobre roxo escuro.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onBrand,
          shape: controlShape,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: isDark,
        // O campo precisa de uma superfície mais clara que a carta: com
        // `darkCard` ele desaparecia dentro do diálogo, que é da mesma cor.
        fillColor: isDark ? scheme.surfaceContainerHighest : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: ink, width: 2),
        ),
        labelStyle: TextStyle(color: ink),
      ),
      // Filete no lugar de sombra: a carta deixa de flutuar e passa a ser uma
      // ficha apoiada no papel. Sombra difusa sobre fundo escuro nunca chegou a
      // aparecer, e sobre o papel ela é justamente o borrão que o motivo evita.
      cardTheme: CardThemeData(
        color: neutrals.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: neutrals.line),
        ),
      ),
      // Diálogo e bottom sheet como a mesma família de superfície: mesma cor de
      // fundo, mesmo raio, mesma tipografia de título. Cada modal decidia isso
      // sozinho, e o do ranking nem cor de fundo tinha — herdava o tom do
      // Material 3, diferente da carta do resto do app.
      dialogTheme: DialogThemeData(
        backgroundColor: neutrals.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: modalShape,
        titleTextStyle: TextStyle(
          color: neutrals.text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: neutrals.text,
          fontSize: 15,
          height: 1.4,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: neutrals.surface,
        modalBackgroundColor: neutrals.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        modalElevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusModal),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
    );
  }

  static const List<Color> genreCardColors = [
    Color(0xFFE13300),
    Color(0xFF006450),
    Color(0xFF8400E7),
    Color(0xFF1E3264),
    Color(0xFFE8115B),
    Color(0xFF148A08),
    Color(0xFFBC5900),
    Color(0xFF7D4B32),
  ];

  /// Ouro, prata e bronze do pódio do ranking, na ordem das posições.
  static const List<Color> podiumColors = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];
}

/// Os neutros de um tema, do fundo à tinta.
///
/// Existe para os dois temas passarem pela mesma montagem dizendo cada degrau
/// por extenso. Antes as superfícies intermediárias saíam de um `lerp` entre a
/// carta e o texto: a distância entre os degraus ficava documentada, o tom
/// deles não — e como a tinta é quase neutra, o resultado desbotava o amarelo
/// do papel exatamente onde ele mais aparece, que são as faixas recuadas.
@immutable
class _NeutralScale {
  const _NeutralScale({
    required this.background,
    required this.surface,
    required this.container,
    required this.containerHigh,
    required this.containerHighest,
    required this.line,
    required this.lineStrong,
    required this.muted,
    required this.text,
    required this.inverse,
    required this.onInverse,
  });

  /// A tela.
  final Color background;

  /// A carta apoiada nela.
  final Color surface;

  final Color container;
  final Color containerHigh;

  /// Faixa recuada dentro da carta: campo preenchido, trilho de abas, pastilha
  /// de posição do ranking, botão de empréstimo indisponível.
  final Color containerHighest;

  /// Filete de 1 px.
  final Color line;

  /// Filete de 1 px onde ele precisa se impor.
  final Color lineStrong;

  /// Texto secundário.
  final Color muted;

  /// Texto.
  final Color text;

  /// Superfície que contrasta com a tela — a faixa de aviso do sistema.
  final Color inverse;
  final Color onInverse;
}

/// Paleta de status, resolvida pelo brilho do tema.
///
/// Os selos de empréstimo, o botão da ficha do livro e o toast escolhiam cada um
/// o seu verde/laranja/vermelho, e no tema escuro `Colors.green` virava tinta
/// escura sobre carta escura. Cada estado tem dois papéis aqui:
/// [success]/[warning]/[danger] são **tinta sobre a superfície** e clareiam no
/// escuro; os `...Fill` são **preenchimento sólido** — os mesmos nos dois temas,
/// porque o que muda ali é só o que fica em volta — com [onFill] por cima.
@immutable
class LumiStatusColors {
  const LumiStatusColors._({
    required this.success,
    required this.warning,
    required this.danger,
  });

  /// Empréstimo em dia, ação concluída.
  final Color success;

  /// Vence hoje, penalidade em vigor, limite atingido — restrição, não falha.
  final Color warning;

  /// Atrasado, erro.
  final Color danger;

  static LumiStatusColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;

  static final Color successFill = Colors.green.shade700;
  static final Color warningFill = Colors.orange.shade800;
  static final Color dangerFill = Colors.red.shade700;

  /// Tinta sobre qualquer um dos preenchimentos acima.
  static const Color onFill = LumiLivreTheme.onBrand;

  /// A tinta clara falhava AA sobre papel, e o selo do empréstimo é onde ela
  /// aparece em corpo de 12: `green.shade700` dava 4,1:1 e `orange.shade800`,
  /// 3,0:1 — o "Vence Hoje" era o texto menos legível do app. Os três degraus
  /// desceram até passar sobre a carta **e** sobre o próprio selo, que é a carta
  /// com 10% da cor por cima: 6,6:1 / 5,0:1 / 4,7:1 no selo.
  ///
  /// O âmbar não tem degrau que passe (nem `orange.shade900` chega a 4:1 sobre
  /// papel): ele vira ocre queimado, que é o que "atenção" parece quando a tinta
  /// é de verdade.
  static const LumiStatusColors _light = LumiStatusColors._(
    success: Color(0xFF1B5E20),
    warning: Color(0xFF9A5300),
    danger: Color(0xFFC62828),
  );

  static final LumiStatusColors _dark = LumiStatusColors._(
    success: Colors.green.shade300,
    warning: Colors.amber.shade300,
    danger: Colors.red.shade300,
  );
}
