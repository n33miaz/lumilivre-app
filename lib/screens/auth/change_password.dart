import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/utils/constants.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? token;

  const ChangePasswordScreen({super.key, this.token});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: validar o token (widget.token)
    if (widget.token == null) {
      print('Token não fornecido!');
    } else {
      print('Token recebido: ${widget.token}');
    }
  }

  void _handleChangePassword() {
    // TODO: implementar chamada a API
    if (_formKey.currentState?.validate() ?? false) {
      print('Nova Senha: ${_newPasswordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: LumiLivreTheme.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SvgPicture.asset('assets/icons/logo.svg', height: 120),
                  const SizedBox(height: 24),
                  const Text(
                    'Redefinir Senha',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: LumiLivreTheme.text,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nova Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Nova Senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SALVAR NOVA SENHA'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
