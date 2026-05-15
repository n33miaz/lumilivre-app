import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/locale.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/utils/constants.dart';

import '../widgets/change_password_dialog.dart';
import 'auth/login.dart';

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
    if (!mounted) return;
    setState(
      () => _isBiometricsEnabled = prefs.getBool('biometricsEnabled') ?? false,
    );
  }

  Future<void> _saveBiometricsPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricsEnabled', value);
  }

  Future<void> _toggleBiometrics(bool value) async {
    final l10n = AppLocalizations.of(context)!;
    if (value) {
      try {
        final canAuthenticate =
            await _localAuth.canCheckBiometrics ||
            await _localAuth.isDeviceSupported();
        if (canAuthenticate) {
          setState(() => _isBiometricsEnabled = true);
          await _saveBiometricsPreference(true);
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.biometricUnavailable)));
        }
      } catch (e) {
        debugPrint('$e');
      }
    } else {
      setState(() => _isBiometricsEnabled = false);
      await _saveBiometricsPreference(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localeTag = localeProvider.locale.toLanguageTag();
    final isGuest = auth.isGuest;
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(l10n.appearanceSection),
          _buildThemeSelector(context, l10n),
          const SizedBox(height: 24),
          _SectionTitle(l10n.languageSection),
          Card(
            shape: roundedShape,
            clipBehavior: Clip.antiAlias,
            child: RadioGroup<String>(
              groupValue: localeTag,
              onChanged: (value) {
                if (value == 'pt-BR') {
                  localeProvider.setLocale(const Locale('pt', 'BR'));
                } else if (value == 'en-US') {
                  localeProvider.setLocale(const Locale('en', 'US'));
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'pt-BR',
                    title: Text(l10n.languagePortuguese),
                    selected: localeTag == 'pt-BR',
                  ),
                  RadioListTile<String>(
                    value: 'en-US',
                    title: Text(l10n.languageEnglish),
                    selected: localeTag == 'en-US',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (!isGuest) ..._buildAccountOptions(roundedShape, l10n),
          if (isGuest) _buildGuestLoginPrompt(context, roundedShape, l10n),
        ],
      ),
    );
  }

  List<Widget> _buildAccountOptions(
    RoundedRectangleBorder roundedShape,
    AppLocalizations l10n,
  ) {
    return [
      _SectionTitle(l10n.securitySection),
      if (!kIsWeb) ...[
        Card(
          shape: roundedShape,
          clipBehavior: Clip.antiAlias,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(l10n.biometricAccess),
            subtitle: Text(l10n.biometricSubtitle),
            value: _isBiometricsEnabled,
            onChanged: _toggleBiometrics,
            secondary: SizedBox(
              width: 40,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/biometric.svg',
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
      _SectionTitle(l10n.accountSection),
      Card(
        shape: roundedShape,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: roundedShape,
          leading: const Icon(Icons.lock_outline),
          title: Text(l10n.changePassword),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const ChangePasswordDialog(),
          ),
        ),
      ),
      Card(
        shape: roundedShape,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: roundedShape,
          leading: Icon(Icons.logout, color: Colors.red.shade400),
          title: Text(
            l10n.logout,
            style: TextStyle(color: Colors.red.shade400),
          ),
          onTap: () {
            Navigator.of(context).pop();
            Provider.of<AuthProvider>(context, listen: false).logout();
          },
        ),
      ),
    ];
  }

  Widget _buildThemeSelector(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.themeLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ThemeOptionButton(
                    label: l10n.themeLight,
                    iconPath: 'assets/icons/sun.svg',
                    option: ThemeOption.light,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeOptionButton(
                    label: l10n.themeSystem,
                    materialIcon: Icons.brightness_auto_outlined,
                    option: ThemeOption.system,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ThemeOptionButton(
                    label: l10n.themeDark,
                    iconPath: 'assets/icons/moon.svg',
                    option: ThemeOption.dark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestLoginPrompt(
    BuildContext context,
    RoundedRectangleBorder roundedShape,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.accountSection),
        Card(
          shape: roundedShape,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.guestSettingsPrompt,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login, size: 18),
                    label: Text(l10n.loginAction),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
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
    final isSelected = themeProvider.themeOption == option;
    final color = isSelected
        ? LumiLivreTheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => themeProvider.setTheme(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? LumiLivreTheme.primary.withValues(alpha: 0.1)
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
