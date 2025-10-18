import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Tela de Pesquisa de Livros',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
