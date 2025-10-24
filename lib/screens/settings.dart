import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/utils/constants.dart';

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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometria não disponível neste dispositivo.'),
              ),
            );
          }
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
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

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
            shape: roundedShape,
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              title: const Text('Acesso com Biometria'),
              subtitle: const Text('Entrar com digital ou rosto.'),
              value: _isBiometricsEnabled,
              onChanged: _toggleBiometrics,
              secondary: SvgPicture.asset(
                'assets/icons/biometric.svg',
                height: 28,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
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
          Card(
            shape: roundedShape,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              shape: roundedShape,
              leading: const Icon(Icons.lock_outline),
              title: const Text('Mudar Senha'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _launchURL(
                  'https://lumilivre-web.onrender.com/esqueci-a-senha', // TODO: direto para /mudar-senha
                );
              },
            ),
          ),
          Card(
            shape: roundedShape,
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              shape: roundedShape,
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text(
                'Sair da Conta',
                style: TextStyle(color: Colors.red.shade400),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tema',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ThemeOptionButton(
                  label: 'Claro',
                  iconPath: 'assets/icons/sun.svg',
                  option: ThemeOption.light,
                ),
                _ThemeOptionButton(
                  label: 'Escuro',
                  iconPath: 'assets/icons/moon.svg',
                  option: ThemeOption.dark,
                ),
                _ThemeOptionButton(
                  label: 'Sistema',
                  materialIcon: Icons.brightness_auto_outlined,
                  option: ThemeOption.system,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOptionButton extends StatelessWidget {
  final String label;
  final String? iconPath;
  final IconData? materialIcon;
  final ThemeOption option;

  const _ThemeOptionButton({
    required this.label,
    this.iconPath,
    this.materialIcon,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isSelected = themeProvider.themeOption == option;

    final color = isSelected
        ? LumiLivreTheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return GestureDetector(
      onTap: () => themeProvider.setTheme(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? LumiLivreTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? LumiLivreTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (iconPath != null)
              SvgPicture.asset(
                iconPath!,
                height: 28,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            else if (materialIcon != null)
              Icon(materialIcon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
