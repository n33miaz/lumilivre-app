import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre_app/providers/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            'Conta',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
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
