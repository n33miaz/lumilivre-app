import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre_app/providers/auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa o AuthProvider para pegar os dados
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LumiLivre Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          authProvider.isGuest
              ? 'Bem-vindo, Convidado!'
              : 'Bem-vindo, ${authProvider.user?.email ?? 'Usuário'}!',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
