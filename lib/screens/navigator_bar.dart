import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/guided_tour.dart';
import 'package:lumilivre/widgets/header.dart';
import 'package:lumilivre/widgets/mandatory_password_dialog.dart';
import 'package:lumilivre/widgets/offline_banner.dart';

import 'catalog.dart';
import 'contents.dart';
import 'search.dart';
import 'profile.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 1;
  late PageController _pageController;
  String? _onboardedToken;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dispara o onboarding a cada NOVA sessão autenticada — inclusive quando o
    // login acontece com o MainNavigator já montado (fluxo guest → login), que
    // o initState não cobre.
    final auth = Provider.of<AuthProvider>(context);
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
      await showDialog(
        context: context,
        barrierDismissible: false,
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildIcon(String name, int index, {bool isLogo = false}) {
    final isActive = _selectedIndex == index;

    final color = isLogo
        ? (isActive ? LumiLivreTheme.label : Colors.grey.shade400)
        : (isActive ? Colors.white : Colors.grey.shade400);

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

  Widget _buildMuralIcon(int index) {
    final isActive = _selectedIndex == index;
    return Icon(
      isActive ? Icons.campaign : Icons.campaign_outlined,
      size: 24,
      color: isActive ? Colors.white : Colors.grey.shade400,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final showContents = Provider.of<SettingsProvider>(context).showContents;

    if (auth.isInitialPassword) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/logo.svg',
                height: 100,
                colorFilter: const ColorFilter.mode(
                  LumiLivreTheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Aguardando alteração de senha..."),
            ],
          ),
        ),
      );
    }

    String headerTitle = 'LumiLivre';
    bool showHeader = _selectedIndex == 0 || _selectedIndex == 1;

    // A aba "Mural" (índice 2) só existe quando a feature de conteúdos está
    // habilitada. O landing padrão continua sendo o Catálogo (índice 1) em
    // ambos os cenários.
    final profileIndex = showContents ? 3 : 2;

    final screens = <Widget>[
      const SearchScreen(),
      const CatalogScreen(),
      if (showContents) const ContentsScreen(),
      const ProfileScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: _buildIcon('search-category', 0),
        label: 'Categorias',
      ),
      BottomNavigationBarItem(
        icon: _buildIcon('logo', 1, isLogo: true),
        label: 'Catálogo',
      ),
      if (showContents)
        BottomNavigationBarItem(
          icon: _buildMuralIcon(2),
          label: AppLocalizations.of(context)!.muralTitle,
        ),
      BottomNavigationBarItem(
        icon: _buildIcon('profile', profileIndex),
        label: 'Perfil',
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
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
        ),

        child: OfflineBanner(
          child: Scaffold(
            body: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: screens,
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: showHeader ? 0 : -160,
                  left: 0,
                  right: 0,
                  child: CustomHeader(title: headerTitle),
                ),
              ],
            ),

            bottomNavigationBar: BottomNavigationBar(
              items: navItems,
              currentIndex: _selectedIndex.clamp(0, screens.length - 1),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey.shade400,
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
