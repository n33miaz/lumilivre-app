import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tela de Perfil do Aluno', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
