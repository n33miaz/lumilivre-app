import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumilivre/providers/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeOption enum', () {
    test('deve ter 3 valores', () {
      expect(ThemeOption.values, hasLength(3));
    });

    test('índices devem ser consistentes para persistência', () {
      expect(ThemeOption.system.index, 0);
      expect(ThemeOption.light.index, 1);
      expect(ThemeOption.dark.index, 2);
    });
  });

  group('ThemeProvider', () {
    late ThemeProvider themeProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
    });

    tearDown(() {
      themeProvider.dispose();
    });

    group('estado inicial', () {
      test('deve iniciar com tema light', () {
        expect(themeProvider.themeOption, ThemeOption.light);
      });

      test('currentTheme deve retornar ThemeMode.light', () {
        expect(themeProvider.currentTheme, ThemeMode.light);
      });

      test('isDarkMode deve ser false', () {
        expect(themeProvider.isDarkMode, isFalse);
      });
    });

    group('setTheme', () {
      test('deve alterar para dark', () {
        themeProvider.setTheme(ThemeOption.dark);
        expect(themeProvider.themeOption, ThemeOption.dark);
        expect(themeProvider.currentTheme, ThemeMode.dark);
        expect(themeProvider.isDarkMode, isTrue);
      });

      test('deve alterar para light', () {
        themeProvider.setTheme(ThemeOption.dark);
        themeProvider.setTheme(ThemeOption.light);
        expect(themeProvider.themeOption, ThemeOption.light);
        expect(themeProvider.isDarkMode, isFalse);
      });

      test('deve alterar para system', () {
        themeProvider.setTheme(ThemeOption.system);
        expect(themeProvider.themeOption, ThemeOption.system);
      });

      test('não deve notificar se o tema não mudou', () {
        themeProvider.setTheme(ThemeOption.dark);
        int notifyCount = 0;
        themeProvider.addListener(() => notifyCount++);
        themeProvider.setTheme(ThemeOption.dark);
        expect(notifyCount, 0);
      });

      test('deve notificar quando o tema muda', () {
        int notifyCount = 0;
        themeProvider.addListener(() => notifyCount++);
        themeProvider.setTheme(ThemeOption.dark);
        expect(notifyCount, 1);
      });
    });

    group('transições', () {
      test('light -> dark -> light deve retornar ao original', () {
        themeProvider.setTheme(ThemeOption.dark);
        expect(themeProvider.currentTheme, ThemeMode.dark);
        themeProvider.setTheme(ThemeOption.light);
        expect(themeProvider.currentTheme, ThemeMode.light);
      });

      test('múltiplas mudanças devem notificar proporcionalmente', () {
        int notifyCount = 0;
        themeProvider.addListener(() => notifyCount++);
        themeProvider.setTheme(ThemeOption.dark);
        themeProvider.setTheme(ThemeOption.system);
        themeProvider.setTheme(ThemeOption.light);
        expect(notifyCount, 3);
      });
    });
  });
}
