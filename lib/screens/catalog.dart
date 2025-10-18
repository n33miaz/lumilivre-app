import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre_app/providers/auth.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Livros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Conteúdo do Catálogo (Carrosséis de Livros)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
