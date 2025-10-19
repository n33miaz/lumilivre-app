import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre_app/utils/constants.dart';
import 'package:lumilivre_app/screens/auth/forgot_password.dart';
import 'package:lumilivre_app/providers/auth.dart';
import 'package:lumilivre_app/providers/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
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
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).login(_userController.text, _passwordController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
                          ),
                        ),
                        const SizedBox(height: 25),
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

                        Theme(
                          data: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: SwitchListTile(
                            title: const Text(
                              'Continuar Conectado',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
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
                        ),

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
                        const SizedBox(height: 12),

                        OutlinedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).loginAsGuest();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('ENTRAR COMO CONVIDADO'),
                        ),
                        const SizedBox(height: 4),
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

          Consumer<ThemeProvider>(
            // TODO: deixar icone fixo
            builder: (context, themeProvider, child) {
              final buttonBackgroundColor = themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300;

              return Positioned(
                left: 16,
                bottom: 16,
                child: Material(
                  color: buttonBackgroundColor,
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: SvgPicture.asset(
                          themeProvider.isDarkMode
                              ? 'assets/icons/sun.svg'
                              : 'assets/icons/moon.svg',
                          key: ValueKey(themeProvider.isDarkMode),
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
