import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_modal.dart';
import 'package:lumilivre/widgets/guided_tour.dart';
import 'package:lumilivre/widgets/header.dart';
import 'package:lumilivre/widgets/mandatory_password_dialog.dart';
import 'package:lumilivre/widgets/offline_banner.dart';

import 'catalog.dart';
import 'search.dart';
import 'profile.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with SingleTickerProviderStateMixin {
  /// Item inativo da barra inferior: a tinta da marca a 60%.
  static final Color _inactiveBrandInk = LumiLivreTheme.onBrand.withValues(
    alpha: 0.6,
  );

  /// As três abas, em ordem. Enquanto o mural era aba, o índice do Perfil era
  /// uma conta condicional (3 com a feature ligada, 2 sem ela) e a barra
  /// precisava de `clamp` para não estourar quando a biblioteca desligasse a
  /// feature no meio da sessão. Com o mural no cabeçalho os índices são fixos —
  /// e nomeados, porque `== 1` no meio de um `build` não diz que ali é o
  /// Catálogo.
  static const int _categoriesIndex = 0;
  static const int _catalogIndex = 1;
  static const int _profileIndex = 2;

  int _selectedIndex = _catalogIndex;
  late PageController _pageController;

  /// Opacidade da troca de aba não vizinha (ver [_onItemTapped]). Parada em 1,
  /// não pinta camada nenhuma.
  late AnimationController _jumpFade;

  String? _onboardedToken;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _jumpFade = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
      value: 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _jumpFade.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = Provider.of<AuthProvider>(context);

    // Biblioteca desligou o acesso de convidado com alguém já navegando assim:
    // encerra a sessão sem conta, e o `home` do app volta para o login. Quem
    // decide é a política única, não esta tela.
    final access = GuestAccess.of(context);
    if (access.isGuest && !access.canBrowseAsGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) auth.logout();
      });
      return;
    }

    // Dispara o onboarding a cada NOVA sessão autenticada — inclusive quando o
    // login acontece com o MainNavigator já montado (fluxo guest → login), que
    // o initState não cobre.
    final token = auth.user?.token;
    if (auth.isAuthenticated &&
        token != null &&
        token.isNotEmpty &&
        token != _onboardedToken) {
      _onboardedToken = token;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _runOnboardingFlow();
      });
    }
  }

  /// Encadeia os passos de onboarding pós-login: primeiro a troca de senha
  /// obrigatória e, só depois de concluída, o tour guiado.
  Future<void> _runOnboardingFlow() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.isAuthenticated && auth.isInitialPassword) {
      await showAppDialog(
        context: context,
        dismissible: false,
        builder: (_) => const MandatoryPasswordDialog(),
      );
    }

    if (!mounted) return;

    final refreshed = Provider.of<AuthProvider>(context, listen: false);
    if (refreshed.isAuthenticated &&
        !refreshed.isInitialPassword &&
        !refreshed.guidedTourCompleted) {
      await showGuidedTour(context);
    }
  }

  /// Troca de aba pelo toque na barra.
  ///
  /// `animateToPage` rola o `PageView` por **todas** as páginas do caminho,
  /// construindo e mostrando cada uma: do Perfil para Categorias o app piscava
  /// o Catálogo antes de chegar, e o cabeçalho subia e descia no meio do
  /// trajeto porque cada página intermediária disparava um `onPageChanged`.
  ///
  /// Então cada distância ganha o seu movimento: aba vizinha desliza (é o
  /// deslize que diz de que lado veio a tela nova) e aba distante salta direto e
  /// desvanece por cima do salto — nada de intermediário aparece nos dois casos.
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    final isNeighbour = (index - _selectedIndex).abs() == 1;

    setState(() {
      _selectedIndex = index;
    });

    if (isNeighbour) {
      _pageController.animateToPage(
        index,
        duration: AppMotion.of(context, AppMotion.page),
        curve: AppMotion.inOut,
      );
      return;
    }

    _pageController.jumpToPage(index);

    if (AppMotion.reduced(context)) return;
    _jumpFade
      ..value = 0
      ..animateTo(1, duration: AppMotion.normal, curve: AppMotion.enter);
  }

  Widget _buildIcon(String name, int index, {bool isLogo = false}) {
    final isActive = _selectedIndex == index;

    // A barra é sempre roxa, nos dois temas: o item inativo é a mesma tinta com
    // menos opacidade, e não um cinza que ninguém escolheu para cima de roxo.
    final color = isLogo
        ? (isActive ? LumiLivreTheme.label : _inactiveBrandInk)
        : (isActive ? LumiLivreTheme.onBrand : _inactiveBrandInk);

    final iconPath = isLogo
        ? 'assets/icons/logo.svg'
        : (isActive
              ? 'assets/icons/$name-active.svg'
              : 'assets/icons/$name.svg');

    double size;
    if (isLogo) {
      size = 32;
    } else if (name == 'search-category') {
      size = 22;
    } else {
      size = 24;
    }

    return SvgPicture.asset(
      iconPath,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    if (auth.isInitialPassword) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 100,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.awaitingPasswordChange),
            ],
          ),
        ),
      );
    }

    // O Perfil tem tela própria, sem busca nem título de marca no topo.
    final showHeader = _selectedIndex != _profileIndex;

    final screens = <Widget>[
      const SearchScreen(),
      const CatalogScreen(),
      const ProfileScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: _buildIcon('search-category', _categoriesIndex),
        label: l10n.navCategories,
      ),
      BottomNavigationBarItem(
        icon: _buildIcon('logo', _catalogIndex, isLogo: true),
        label: l10n.navCatalog,
      ),
      BottomNavigationBarItem(
        icon: _buildIcon('profile', _profileIndex),
        label: l10n.navProfile,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: LumiLivreTheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: LumiLivreTheme.onBrand.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),

        child: OfflineBanner(
          child: Scaffold(
            body: Stack(
              children: [
                // O arrastar entre páginas continua valendo: é a mesma troca de
                // aba feita com o dedo, e a barra de baixo acompanha por aqui.
                FadeTransition(
                  opacity: _jumpFade,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      // O toque na barra já acertou o índice antes de mandar a
                      // página trocar; sem esta guarda, o `setState` redundante
                      // reconstruía o cabeçalho no meio da transição.
                      if (index == _selectedIndex) return;
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: screens,
                  ),
                ),

                AnimatedPositioned(
                  duration: AppMotion.of(context, AppMotion.page),
                  curve: AppMotion.inOut,
                  top: showHeader ? 0 : -160,
                  left: 0,
                  right: 0,
                  child: CustomHeader(title: l10n.appTitle),
                ),
              ],
            ),

            bottomNavigationBar: BottomNavigationBar(
              items: navItems,
              currentIndex: _selectedIndex,
              selectedItemColor: LumiLivreTheme.onBrand,
              unselectedItemColor: _inactiveBrandInk,
              onTap: _onItemTapped,
              backgroundColor: LumiLivreTheme.primary,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              showUnselectedLabels: false,
            ),
          ),
        ),
      ),
    );
  }
}
