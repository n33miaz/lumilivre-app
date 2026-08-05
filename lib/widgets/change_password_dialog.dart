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
        Navigator.of(context).pop(); // Fecha o dialog
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
    return AlertDialog(
      title: const Text('Alterar Senha'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Senha Atual'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha atual';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a nova senha';
                  }
                  if (value.length < 6) return 'Mínimo de 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'As senhas não conferem';
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
          child: const Text('CANCELAR'),
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
              : const Text('SALVAR'),
        ),
      ],
    );
  }
}
