import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/services/api.dart';
import 'package:lumilivre_app/utils/constants.dart';
import 'package:lumilivre_app/screens/auth/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _keepConnected = true;

  // animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    // Inicia a animação
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.login(
          _userController.text,
          _passwordController.text,
        );

        print('Login com sucesso! Token: ${response.token}');

        // TODO: salvar o token e navegar para a tela Home
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SvgPicture.asset(
                          'assets/icons/logo.svg',
                          height: 200,
                          semanticsLabel: 'Logo LumiLivre',
                        ),
                        const Text(
                          'LumiLivre',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: LumiLivreTheme.text,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            labelText: 'Matrícula ou Email',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v!.isEmpty ? 'Digite seu usuário' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) =>
                              v!.isEmpty ? 'Digite sua senha' : null,
                        ),

                        SwitchListTile(
                          title: const Text(
                            'Continuar Conectado',
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: _keepConnected,
                          onChanged: (bool value) {
                            setState(() {
                              _keepConnected = value;
                            });
                          },
                          activeColor: LumiLivreTheme.primary,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  'ENTRAR',
                                ),
                        ),
                        const SizedBox(height: 16),

                        OutlinedButton(
                          onPressed: () {
                            // TODO: lógica de convidado
                            print('Entrar como convidado');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('ENTRAR COMO CONVIDADO'),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Esqueceu sua senha?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            bottom: 16,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/moon.svg',
                height: 28,
                colorFilter: const ColorFilter.mode(
                  LumiLivreTheme.text,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () {
                // TODO: lógica troca de tema
                print('Trocar tema');
              },
            ),
          ),
        ],
      ),
    );
  }
}
