import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_toast.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  /// Tamanho mínimo aceito localmente. A regra que vale é a da API (que responde
  /// com a própria frase quando recusa); esta só evita a ida à rede — por isso o
  /// número vem daqui e não do texto, senão traduzir a frase mudaria a validação.
  static const int _minPasswordLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final toast = AppToast.of(context);

    try {
      final newToken = await _apiService.changePassword(
        auth.user!.readerRegistrationNumber ?? '',
        _currentPasswordController.text,
        _newPasswordController.text,
        auth.user!.token,
      );

      // A troca revoga o token que fez esta requisição: sem adotar o novo, o
      // usuário sairia da conta no request seguinte, sem entender por quê.
      await auth.completePasswordChange(newToken: newToken);

      if (mounted) {
        toast.success(l10n.passwordChangedMessage);
        // Devolve `true` para quem abriu poder retomar o que a senha pendente
        // barrou — é o caso do coração da ficha, que a API recusa até a troca.
        // Cancelar e fechar pela barreira continuam devolvendo `null`.
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        // Senha atual errada e senha nova fraca chegam da API com frase própria e
        // traduzida — é ela que aparece.
        final failure = ApiException.fromError(e);
        toast.error(
          failure.apiMessage ??
              (failure.failure == ApiFailure.network
                  ? l10n.connectionErrorMessage
                  : l10n.passwordChangeFailedMessage),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cor, raio, elevação e tipografia do título vêm do `dialogTheme`: os dois
    // diálogos de senha repetiam essas decisões e chegavam a resultados
    // diferentes entre si e do resto do app.
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.changePasswordTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: l10n.currentPasswordLabel,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.currentPasswordRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: l10n.newPasswordLabel),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.newPasswordRequired;
                  }
                  if (value.length < _minPasswordLength) {
                    return l10n.passwordMinLength(_minPasswordLength);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: l10n.confirmNewPasswordLabel,
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return l10n.passwordsDoNotMatch;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          child: Text(l10n.cancelAction),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: LumiLivreTheme.onBrand,
                    strokeWidth: 2,
                  ),
                )
              : Text(l10n.saveAction),
        ),
      ],
    );
  }
}
