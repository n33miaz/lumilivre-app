import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_toast.dart';

class MandatoryPasswordDialog extends StatefulWidget {
  const MandatoryPasswordDialog({super.key});

  @override
  State<MandatoryPasswordDialog> createState() =>
      _MandatoryPasswordDialogState();
}

class _MandatoryPasswordDialogState extends State<MandatoryPasswordDialog> {
  /// Mesmo motivo do diálogo de troca comum: o número é regra, não texto.
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
        auth.user!.readerRegistrationNumber!,
        _currentPasswordController.text,
        _newPasswordController.text,
        auth.user!.token,
      );

      if (mounted) {
        toast.success(l10n.passwordChangedMessage);

        // Além de baixar a flag de senha inicial, adota o token que a API emitiu
        // na troca: o anterior acabou de ser revogado no servidor.
        await auth.completePasswordChange(newToken: newToken);

        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
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
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.mandatoryPasswordTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mandatoryPasswordMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
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
          ),
        ],
      ),
    );
  }
}
