import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/utils/constants.dart';

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

  final List<Widget> _screens = [
    const SearchScreen(),
    const CatalogScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    return Scaffold(
      body: _screens[_selectedIndex],

      // TODO: ajustar animação de click
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
    );
  }
}
