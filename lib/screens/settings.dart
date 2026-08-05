import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/providers/locale.dart';
import 'package:lumilivre/providers/theme.dart';
import 'package:lumilivre/services/biometric_auth.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_toast.dart';

import '../widgets/change_password_dialog.dart';
import 'auth/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BiometricAuth _biometrics = BiometricAuth();

  bool _isBiometricsEnabled = false;
  bool _isBiometricsSupported = false;
  bool _isBiometricsBusy = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricsState();
  }

  Future<void> _loadBiometricsState() async {
    final enabled = await _biometrics.isEnabled();
    final supported = await _biometrics.isSupported();
    if (!mounted) return;
    setState(() {
      _isBiometricsEnabled = enabled;
      _isBiometricsSupported = supported;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    final toast = AppToast.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Ligar exige autenticar de verdade primeiro: gravar a preferência sem
    // passar pelo sensor é o que fazia o toggle prometer proteção que não
    // existia. Desligar não exige, para o usuário não ficar preso ao gate se o
    // sensor parar de funcionar.
    if (value) {
      setState(() => _isBiometricsBusy = true);
      final confirmed = await _biometrics.confirmToEnable();
      if (!mounted) return;
      setState(() => _isBiometricsBusy = false);

      if (!confirmed) {
        toast.error(l10n.biometricEnableFailed);
        return;
      }
      await _biometrics.setEnabled(true);
      if (!mounted) return;
      setState(() => _isBiometricsEnabled = true);
      toast.success(l10n.biometricEnabledConfirmation);
      return;
    }

    await _biometrics.setEnabled(false);
    if (!mounted) return;
    setState(() => _isBiometricsEnabled = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Aparência e idioma valem para todo mundo; conta e segurança só existem
    // com sessão — quem decide isso é a política única.
    final access = GuestAccess.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final localeTag = localeProvider.locale.toLanguageTag();
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
          if (access.canManageAccount)
            ..._buildAccountOptions(roundedShape, l10n)
          else
            _buildGuestLoginPrompt(context, roundedShape, l10n),
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
            // Aparelho sem sensor ou sem biometria cadastrada: o toggle fica
            // desabilitado e diz o motivo, em vez de aceitar e falhar depois.
            subtitle: Text(
              _isBiometricsSupported
                  ? l10n.biometricSubtitle
                  : l10n.biometricUnavailable,
            ),
            value: _isBiometricsEnabled,
            // Quem já tinha a preferência ligada (ou perdeu o cadastro de
            // digital depois) precisa poder desligar: o gate falha fechado, e
            // sem esta saída o auto-login ficaria travado para sempre.
            onChanged:
                _isBiometricsBusy ||
                    (!_isBiometricsSupported && !_isBiometricsEnabled)
                ? null
                : _toggleBiometrics,
            secondary: SizedBox(
              width: 40,
              child: Center(
                child: _isBiometricsBusy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : SvgPicture.asset(
                        'assets/icons/biometric.svg',
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: _isBiometricsSupported ? 1.0 : 0.4,
                          ),
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
            // Provider lido antes do pop: depois dele este `context` já saiu da
            // árvore, e o logout agora também revoga a sessão no servidor.
            final auth = Provider.of<AuthProvider>(context, listen: false);
            Navigator.of(context).pop();
            auth.logout();
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
