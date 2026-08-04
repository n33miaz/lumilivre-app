import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';

/// Exibe o tour guiado de boas-vindas (WS-10).
///
/// Retorna quando o usuário conclui ou pula. Em ambos os casos o tour é
/// marcado como concluído (backend + sessão local) para nunca reaparecer.
Future<void> showGuidedTour(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _GuidedTourDialog(),
  );
}

class _TourStep {
  final IconData icon;
  final String title;
  final String body;

  const _TourStep({required this.icon, required this.title, required this.body});
}

class _GuidedTourDialog extends StatefulWidget {
  const _GuidedTourDialog();

  @override
  State<_GuidedTourDialog> createState() => _GuidedTourDialogState();
}

class _GuidedTourDialogState extends State<_GuidedTourDialog> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  int _index = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_TourStep> _steps(AppLocalizations l10n) => [
    _TourStep(
      icon: Icons.waving_hand,
      title: l10n.tourStep1Title,
      body: l10n.tourStep1Body,
    ),
    _TourStep(
      icon: Icons.menu_book,
      title: l10n.tourStep2Title,
      body: l10n.tourStep2Body,
    ),
    _TourStep(
      icon: Icons.search,
      title: l10n.tourStep3Title,
      body: l10n.tourStep3Body,
    ),
    _TourStep(
      icon: Icons.person,
      title: l10n.tourStep4Title,
      body: l10n.tourStep4Body,
    ),
  ];

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.user?.token;

    // Melhor esforço: se a chamada falhar, ainda marcamos localmente para
    // não reexibir o tour nesta sessão.
    if (token != null && token.isNotEmpty) {
      await _apiService.completeTour(token);
    }
    await auth.completeTour();

    if (mounted) Navigator.of(context).pop();
  }

  void _next(int total) {
    if (_index >= total - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = _steps(l10n);
    final isLast = _index == steps.length - 1;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: steps.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _buildStep(steps[i]),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? LumiLivreTheme.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  TextButton(
                    onPressed: _finishing ? null : _finish,
                    child: Text(
                      l10n.tourSkip,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _finishing ? null : () => _next(steps.length),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LumiLivreTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: _finishing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(isLast ? l10n.tourFinish : l10n.tourNext),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(_TourStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: LumiLivreTheme.primary.withValues(alpha: 0.1),
            child: Icon(step.icon, size: 40, color: LumiLivreTheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
