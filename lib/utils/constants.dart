import 'package:flutter/material.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://lumilivre-api.onrender.com',
);

class LumiLivreTheme {
  static const Color primary = Color(0xFF762075);
  static const Color label = Color(0xFFC964C5);
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightCard = Colors.white;

  static const Color darkBackground = Color(0xFF111827);
  static const Color darkText = Colors.white;
  static const Color darkCard = Color(0xFF1F2937);

  /// Tinta sobre o roxo da marca — AppBar do mural, cabeçalho do perfil, barra
  /// inferior e botão preenchido, que são #762075 nos dois temas.
  ///
  /// Não é `colorScheme.onPrimary` de propósito: no tema escuro `primary` passa
  /// a ser o tom claro da marca (ver [darkTheme]) e o par dele é escuro. Aqui a
  /// superfície é sempre o roxo, então a tinta é sempre branca.
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
  static const double radiusControl = 12.0;
  static const double radiusCard = 14.0;
  static const double radiusModal = 20.0;

  /// No tema claro o roxo da marca se lê sobre branco: serve de tinta e de
  /// superfície ao mesmo tempo.
  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    background: lightBackground,
    card: lightCard,
    text: lightText,
    ink: primary,
  );

  /// No escuro #762075 sobre #111827 não se lê — era por isso que indicador de
  /// progresso, `TextButton` e título de seção sumiam. A tinta da marca passa a
  /// ser o tom claro (`label`), o mesmo papel que ele tem no web (`lumi-label`);
  /// o roxo continua sendo superfície de marca via `primaryColor`.
  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    background: darkBackground,
    card: darkCard,
    text: darkText,
    ink: label,
  );

  /// Aproxima uma cor de destaque da tinta da superfície até ela se ler.
  ///
  /// Usada pelos selos que carregam uma cor de identidade (tipo de conteúdo do
  /// mural): a cor crua falha contraste nas duas pontas — #C964C5 sobre branco e
  /// #762075 sobre #1F2937. O empurrão é maior no escuro porque a distância a
  /// vencer também é.
  static Color readableInk(BuildContext context, Color accent) {
    final scheme = Theme.of(context).colorScheme;
    final amount = scheme.brightness == Brightness.dark ? 0.5 : 0.25;
    return Color.lerp(accent, scheme.onSurface, amount)!;
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color text,
    required Color ink,
  }) {
    final isDark = brightness == Brightness.dark;

    // Um degrau entre a carta e a tinta dela: é assim que nascem as superfícies
    // intermediárias e as bordas.
    Color step(double amount) => Color.lerp(card, text, amount)!;

    // Os cinzas do esquema semeado puxam para o marrom, porque saem do roxo da
    // marca. O app tem a própria família (#F3F4F6 claro / #1F2937 escuro), e a
    // mistura das duas era o que dava ao tema escuro um ar encardido — campo de
    // texto e borda marrons dentro de uma carta cinza-azulada. Neutro aqui, cor
    // só onde é marca ou status.
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: ink,
      surface: card,
      onSurface: text,
      surfaceContainer: step(0.04),
      surfaceContainerHigh: step(0.07),
      surfaceContainerHighest: step(0.10),
      onSurfaceVariant: step(0.62),
      outline: step(0.42),
      outlineVariant: step(0.20),
    );
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusControl),
    );
    final modalShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusModal),
    );

    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: card,
      colorScheme: scheme,
      // Um só tom de texto secundário: `hintColor` e `onSurfaceVariant` eram
      // dois cinzas diferentes usados para a mesma coisa em telas vizinhas.
      hintColor: scheme.onSurfaceVariant,
      // Barra das telas empilhadas. As de marca (mural, perfil) pintam o roxo
      // por cima; antes cada tela empilhada escolhia a sua cor e elevação.
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: text,
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
      cardTheme: CardThemeData(
        color: card,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
      // Diálogo e bottom sheet como a mesma família de superfície: mesma cor de
      // fundo, mesmo raio, mesma tipografia de título. Cada modal decidia isso
      // sozinho, e o do ranking nem cor de fundo tinha — herdava o tom do
      // Material 3, diferente da carta do resto do app.
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: modalShape,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: text, fontSize: 15, height: 1.4),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        modalBackgroundColor: card,
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

  static final LumiStatusColors _light = LumiStatusColors._(
    success: Colors.green.shade700,
    warning: Colors.orange.shade800,
    danger: Colors.red.shade700,
  );

  static final LumiStatusColors _dark = LumiStatusColors._(
    success: Colors.green.shade300,
    warning: Colors.amber.shade300,
    danger: Colors.red.shade300,
  );
}
