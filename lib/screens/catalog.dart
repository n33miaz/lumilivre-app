import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/providers/theme.dart';
import 'package:lumilivre_app/utils/constants.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 220),
            children: const [
              // TODO: carrosséis de livros
              SizedBox(height: 20),
              Center(child: Text("Carrosséis de Livros Virão Aqui")),
              SizedBox(height: 100), // Espaço extra no final
            ],
          ),

          _buildHeader(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: LumiLivreTheme.label,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50),
                          onTap: () => themeProvider.toggleTheme(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              themeProvider.isDarkMode
                                  ? 'assets/icons/sun.svg'
                                  : 'assets/icons/moon.svg',
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Título
                      const Text(
                        'LumiLivre',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Digite algum livro ou autor',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
