import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/widgets/app_toast.dart';

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

  // animação
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Eram 800 ms para o formulário aparecer — quase um segundo antes de a tela
    // ficar utilizável. O `AnimationController` já encurta sozinho para 5% da
    // duração quando o sistema pede menos animação, então aqui não há consulta
    // ao `MediaQuery` (que em `initState` ainda não está disponível).
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.page,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppMotion.enter,
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

  /// Fecha a tela quando ela é uma rota empilhada sobre o app.
  ///
  /// Esta tela tem dois papéis: é a raiz quando não há sessão (`main.dart`) e é
  /// uma rota empilhada quando o convidado toca em "Entrar" dentro do app. No
  /// segundo caso ela precisa sair de cena depois de resolver a entrada, senão
  /// o usuário fica olhando o formulário de login já autenticado.
  ///
  /// O gatilho antes era `didChangeDependencies` disparando `pop()` só por o
  /// usuário ser convidado: como o convidado já é convidado quando a rota abre,
  /// ela se fechava no primeiro frame e todo botão "Entrar" do modo convidado
  /// ficava inerte. Agora quem fecha é a ação concluída, não o estado.
  void _dismissIfPushed() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final l10n = AppLocalizations.of(context)!;
      final toast = AppToast.of(context);

      // Fecha o teclado antes de enviar. Esta tela usa
      // `resizeToAvoidBottomInset: false`, então o Scaffold não encolhe com o
      // teclado aberto e o aviso nasce embaixo dele — invisível justamente no
      // momento em que o usuário mais precisa dele, que é o erro de login.
      FocusScope.of(context).unfocus();

      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).login(_userController.text, _passwordController.text);
        if (mounted) {
          _dismissIfPushed();
        }
      } catch (e) {
        if (!mounted) {
          return;
        }
        toast.error(_loginErrorMessage(e, l10n));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// A frase da recusa é a da API, não a nossa.
  ///
  /// O servidor já distingue senha incorreta, conta desativada, conta bloqueada
  /// e excesso de tentativas, e responde na língua que o app pediu. A copy local
  /// só entra quando não há resposta nenhuma para mostrar — falha de rede — ou
  /// quando a resposta veio sem mensagem.
  String _loginErrorMessage(Object error, AppLocalizations l10n) {
    final failure = ApiException.fromError(error);
    final apiMessage = failure.apiMessage;
    if (apiMessage != null) {
      return apiMessage;
    }
    if (failure.failure == ApiFailure.network) {
      return l10n.connectionErrorMessage;
    }
    return l10n.loginFailedMessage;
  }

  /// Aviso em toast, porque antes não havia aviso nenhum.
  ///
  /// Aqui morava um `throw` de String crua dentro de um callback assíncrono: ela
  /// subia até o handler global de zona, virava um log em debug e nada em
  /// release. Quem tocava em "Esqueceu sua senha?" sem navegador para abrir o
  /// link ficava olhando a tela parada.
  Future<void> _launchURL(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final toast = AppToast.of(context);
    final Uri uri = Uri.parse(url);

    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      toast.error(l10n.linkOpenError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestAccess = GuestAccess.of(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Tinta sobre a tela, não superfície de marca: o roxo
                        // cravado quase desaparecia no tema escuro.
                        SvgPicture.asset(
                          'assets/icons/logo.svg',
                          height: 200,
                          semanticsLabel: l10n.logoSemanticLabel,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),
                        TextFormField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: l10n.loginUserFieldLabel,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              v!.isEmpty ? l10n.loginUserFieldRequired : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: l10n.passwordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (v) =>
                              v!.isEmpty ? l10n.loginPasswordRequired : null,
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: LumiLivreTheme.onBrand,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  l10n.loginSubmit,
                                ),
                        ),
                        const SizedBox(height: 12),

                        // O modo convidado é opção da biblioteca: quem decide é
                        // a política única (`GuestAccess`), não esta tela.
                        if (guestAccess.guestModeOffered)
                          OutlinedButton(
                            onPressed: () {
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).loginAsGuest();
                              _dismissIfPushed();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface,
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  LumiLivreTheme.radiusControl,
                                ),
                              ),
                            ),
                            child: Text(l10n.loginAsGuest),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              l10n.guestAccessDisabled,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.hintColor),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              _launchURL(
                                'https://lumilivre.com.br/esqueci-a-senha',
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.hintColor,
                            ),
                            child: Text(l10n.forgotPassword),
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
            builder: (context, themeProvider, child) {
              // O `isDarkMode ? shade800 : shade300` escrito à mão era o próprio
              // papel de "superfície um degrau acima da tela", que o esquema já
              // resolve nos dois temas.
              final buttonBackgroundColor =
                  theme.colorScheme.surfaceContainerHighest;

              return Positioned(
                left: 20,
                bottom: 20,
                child: SafeArea(
                  child: Material(
                    color: buttonBackgroundColor,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        final newTheme = themeProvider.isDarkMode
                            ? ThemeOption.light
                            : ThemeOption.dark;
                        themeProvider.setTheme(newTheme);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: AnimatedSwitcher(
                          duration: AppMotion.of(context, AppMotion.normal),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
