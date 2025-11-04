import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/utils/constants.dart';

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

  // popup de mudar senha, caso seja o primeiro login
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
                _launchURL(
                  'https://lumilivre-web.onrender.com/mudar-senha',
                ); // URL vai mudar
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

  Widget _buildIcon(String name, int index) {
    final isActive = _selectedIndex == index;
    final iconPath = isActive
        ? 'assets/icons/$name-active.svg'
        : 'assets/icons/$name.svg';

    final color = isActive ? Colors.white : Colors.grey.shade400;

    return SvgPicture.asset(
      iconPath,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.transparent,
      ),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildIcon('search', 0),
              label: 'Pesquisa',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon('home', 1),
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
        ),
      ),
    );
  }
}
