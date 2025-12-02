import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/header.dart';

import 'catalog.dart';
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

  final List<Widget> _screens = [
    const SearchScreen(),
    const CatalogScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.isInitialPassword) {
        _showChangePasswordDialog(context);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir $url';
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alterar Senha'),
          content: const Text(
            'Percebemos que você está usando uma senha inicial. Para sua segurança, recomendamos alterá-la agora.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('DEIXAR PARA DEPOIS'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('ALTERAR AGORA'),
              onPressed: () {
                _launchURL('https://lumilivre.com.br/mudar-senha');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      size = 20;
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
    String headerTitle = 'LumiLivre';
    if (_selectedIndex == 0) headerTitle = 'Categorias';

    bool showHeader = _selectedIndex == 0 || _selectedIndex == 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: LumiLivreTheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.transparent,
        ),
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
                children: _screens,
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
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildIcon('search-category', 0),
                label: 'Categorias',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('logo', 1, isLogo: true),
                label: 'Catálogo',
              ),
              BottomNavigationBarItem(
                icon: _buildIcon('profile', 2),
                label: 'Perfil',
              ),
            ],
            currentIndex: _selectedIndex,
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
    );
  }
}
