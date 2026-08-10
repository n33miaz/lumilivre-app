import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/screens/search_results.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/mural.dart';

class CustomHeader extends StatelessWidget {
  final String title;

  const CustomHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final showMural = GuestAccess.of(context).contentsVisible;

    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: LumiLivreTheme.label,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // A busca é pintada ANTES dos botões de propósito, e continua no mesmo
          // lugar: num `Stack` quem pinta por último fica por cima e recebe o
          // toque primeiro. Com ela por último, em aparelho de barra de status
          // alta a busca encostava nos botões do topo e engolia o toque deles.
          Positioned(top: 90, left: 20, right: 20, child: _SearchField()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // botão tema
                  Material(
                    color: LumiLivreTheme.onBrand.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        final newTheme = themeProvider.isDarkMode
                            ? ThemeOption.light
                            : ThemeOption.dark;
                        themeProvider.setTheme(newTheme);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          themeProvider.isDarkMode
                              ? 'assets/icons/sun.svg'
                              : 'assets/icons/moon.svg',
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            LumiLivreTheme.onBrand,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // título
                  //
                  // Com os dois botões do mesmo tamanho nas pontas, o `Expanded`
                  // no meio põe o centro do texto no centro da tela — o
                  // `spaceBetween` de antes centralizava entre um botão de 36 e
                  // um vão de 48, e o recuo de 10 empurrava mais um pouco. Uma
                  // linha só: o título traduzido não pode empurrar os botões
                  // nem crescer o cabeçalho, que tem altura fixa.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.5),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: LumiLivreTheme.onBrand,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // botão mural
                  //
                  // Sem a feature o botão não existe, mas o vão continua: é o
                  // contrapeso que mantém o título centralizado.
                  if (showMural)
                    const MuralButton()
                  else
                    const SizedBox(width: MuralButton.diameter),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    _focusNode.unfocus();
    final texto = _controller.text.trim();

    if (texto.isNotEmpty) {
      Navigator.of(context).push(
        AppPageRoute<void>(
          context: context,
          builder: (_) => SearchResultsScreen(query: texto),
        ),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double borderRadiusValue = LumiLivreTheme.radiusControl;
    const double buttonWidth = 56;

    return AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.quick),
      curve: AppMotion.enter,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadiusValue),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Anel de foco é tinta sobre a superfície do campo, não superfície de
        // marca: com o roxo cravado ele não aparecia no tema escuro.
        border: Border.all(
          color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadiusValue - 1.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: theme.cardColor),

            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // campo de texto
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        hintText: AppLocalizations.of(context)!.searchHint,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: theme.hintColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _onSearch(),
                    ),
                  ),
                ),

                // botão de busca
                SizedBox(
                  width: buttonWidth,
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) {
                      setState(() => _isPressed = false);
                      _onSearch();
                    },
                    onTapCancel: () => setState(() => _isPressed = false),
                    child: AnimatedContainer(
                      duration: AppMotion.of(context, AppMotion.quick),
                      curve: AppMotion.enter,
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? LumiLivreTheme.primary.withValues(alpha: 0.85)
                            : LumiLivreTheme.primary,
                        boxShadow: _isPressed
                            ? [
                                BoxShadow(
                                  color: LumiLivreTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: AnimatedScale(
                        scale: _isPressed ? 0.92 : 1.0,
                        duration: AppMotion.of(context, AppMotion.quick),
                        curve: AppMotion.enter,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: AppMotion.of(context, AppMotion.quick),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              key: ValueKey(_isPressed),
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                _isPressed
                                    ? LumiLivreTheme.onBrand.withValues(
                                        alpha: 0.5,
                                      )
                                    : LumiLivreTheme.onBrand,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
