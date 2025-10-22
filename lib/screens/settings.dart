import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre_app/providers/auth.dart';
import 'package:lumilivre_app/providers/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricsEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadBiometricsPreference();
  }

  Future<void> _loadBiometricsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBiometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;
    });
  }

  Future<void> _saveBiometricsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricsEnabled', value);
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      try {
        final bool canAuthenticate =
            await _localAuth.canCheckBiometrics ||
            await _localAuth.isDeviceSupported();
        if (canAuthenticate) {
          setState(() {
            _isBiometricsEnabled = true;
          });
          await _saveBiometricsPreference(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometria não disponível neste dispositivo.'),
            ),
          );
        }
      } catch (e) {
        print(e);
      }
    } else {
      setState(() {
        _isBiometricsEnabled = false;
      });
      await _saveBiometricsPreference(false);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Aparência',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildThemeSelector(context),
          const SizedBox(height: 24),

          Text(
            'Segurança',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Acesso com Biometria'),
              subtitle: const Text('Entrar com digital ou rosto.'),
              value: _isBiometricsEnabled,
              onChanged: _toggleBiometrics,
              secondary: const Icon(Icons.fingerprint),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Conta',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: redirecionar direto para tela de mudança de senha com o token salvo na sessão
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Mudar Senha'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _launchURL(
                  'https://lumilivre-web.onrender.com/esqueci-a-senha', // URL vai mudar
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                'Sair da Conta',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              // TODO: adicionar o botão 'Automático'
              'Tema',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    if (isDarkMode) themeProvider.toggleTheme();
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: !isDarkMode
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Claro',
                        style: TextStyle(
                          color: !isDarkMode
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (!isDarkMode) themeProvider.toggleTheme();
                  },
                  child: Column(
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: isDarkMode
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Escuro',
                        style: TextStyle(
                          color: isDarkMode
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
