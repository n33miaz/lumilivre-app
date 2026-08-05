import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/library_settings.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/providers/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

LibrarySettings _settings({
  bool guestAccessEnabled = true,
  bool ranking = true,
  bool contents = true,
  bool avatar = true,
}) {
  return LibrarySettings(
    libraryType: LibraryType.school,
    readerCanEditAvatar: avatar,
    guestAccessEnabled: guestAccessEnabled,
    features: SettingsFeatures(
      academicFields: true,
      ranking: ranking,
      contents: contents,
    ),
  );
}

GuestAccess _guest({LibrarySettings? settings}) => GuestAccess(
  isGuest: true,
  isAuthenticated: false,
  settings: settings ?? _settings(),
);

GuestAccess _reader({LibrarySettings? settings}) => GuestAccess(
  isGuest: false,
  isAuthenticated: true,
  settings: settings ?? _settings(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('LibrarySettings.guestAccessEnabled', () {
    test('deve assumir true quando a API ainda nao manda o campo', () {
      final settings = LibrarySettings.fromJson({'libraryType': 'SCHOOL'});
      expect(settings.guestAccessEnabled, isTrue);
    });

    test('deve respeitar false quando a API mandar o campo', () {
      final settings = LibrarySettings.fromJson({
        'libraryType': 'SCHOOL',
        'guestAccessEnabled': false,
      });
      expect(settings.guestAccessEnabled, isFalse);
    });

    test('padrao da biblioteca escolar deve permitir convidado', () {
      expect(LibrarySettings.school().guestAccessEnabled, isTrue);
    });
  });

  group('GuestAccess do convidado', () {
    final access = _guest();

    test('deve navegar o catalogo', () {
      expect(access.canBrowseAsGuest, isTrue);
      expect(access.canBrowseCatalog, isTrue);
    });

    test('nao deve solicitar, curtir nem ver dados de leitor', () {
      expect(access.canRequestLoan, isFalse);
      expect(access.canLikeBooks, isFalse);
      expect(access.canSeeOwnLoans, isFalse);
      expect(access.canReadRanking, isFalse);
      expect(access.canReadContents, isFalse);
      expect(access.canManageAccount, isFalse);
      expect(access.canEditAvatar, isFalse);
    });

    test('deve manter as abas visiveis para receber o convite de login', () {
      expect(access.rankingTabVisible, isTrue);
      expect(access.contentsTabVisible, isTrue);
    });
  });

  group('GuestAccess do leitor autenticado', () {
    test('deve liberar emprestimo, curtida, historico e conta', () {
      final access = _reader();

      expect(access.canRequestLoan, isTrue);
      expect(access.canLikeBooks, isTrue);
      expect(access.canSeeOwnLoans, isTrue);
      expect(access.canReadRanking, isTrue);
      expect(access.canReadContents, isTrue);
      expect(access.canManageAccount, isTrue);
      expect(access.canEditAvatar, isTrue);
    });

    test('deve respeitar as features desligadas da biblioteca', () {
      final access = _reader(
        settings: _settings(ranking: false, contents: false, avatar: false),
      );

      expect(access.rankingTabVisible, isFalse);
      expect(access.canReadRanking, isFalse);
      expect(access.contentsTabVisible, isFalse);
      expect(access.canReadContents, isFalse);
      expect(access.canEditAvatar, isFalse);
    });
  });

  group('GuestAccess com convidado desligado pela biblioteca', () {
    test('sessao de convidado deixa de valer', () {
      final access = _guest(settings: _settings(guestAccessEnabled: false));

      expect(access.guestModeOffered, isFalse);
      expect(access.canBrowseAsGuest, isFalse);
    });
  });

  group('GuestAccess.resolve', () {
    test('deve ler o estado do AuthProvider e do SettingsProvider', () async {
      final settingsProvider = SettingsProvider(
        loadSettings: (_) async => _settings(guestAccessEnabled: false),
      );
      await settingsProvider.load('token-de-teste');

      final auth = AuthProvider()..loginAsGuest();
      final access = GuestAccess.resolve(
        auth: auth,
        settings: settingsProvider,
      );

      expect(access.isGuest, isTrue);
      expect(access.isAuthenticated, isFalse);
      expect(access.guestModeOffered, isFalse);
    });

    test('sem sessao e sem modo convidado nao libera nada de leitor', () {
      final access = GuestAccess.resolve(
        auth: AuthProvider(),
        settings: SettingsProvider(),
      );

      expect(access.isGuest, isFalse);
      expect(access.canBrowseAsGuest, isFalse);
      expect(access.canRequestLoan, isFalse);
      // Sem settings carregados vale o padrao: convidado continua oferecido.
      expect(access.guestModeOffered, isTrue);
    });
  });
}
