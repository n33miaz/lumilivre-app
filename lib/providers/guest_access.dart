import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/library_settings.dart';
import 'auth.dart';
import 'settings.dart';

/// Ponto único que responde o que o modo convidado pode fazer.
///
/// Antes cada tela decidia sozinha com um `if (auth.isGuest)`, e cada uma
/// decidia diferente: o convidado ganhava a aba do mural que nunca carrega, via
/// o botão de curtir que não persiste e perdia o acesso a Configurações. Aqui a
/// regra fica num lugar só, combinada com a configuração da biblioteca — assim o
/// dia em que a biblioteca desligar o convidado, ninguém precisa caçar `if`s.
@immutable
class GuestAccess {
  const GuestAccess({
    required this.isGuest,
    required this.isAuthenticated,
    required LibrarySettings settings,
  }) : _settings = settings;

  final bool isGuest;
  final bool isAuthenticated;
  final LibrarySettings _settings;

  /// Lê os dois providers de que a política depende, e faz quem chamar
  /// reconstruir quando qualquer um dos dois mudar.
  static GuestAccess of(BuildContext context) => GuestAccess.resolve(
    auth: Provider.of<AuthProvider>(context),
    settings: Provider.of<SettingsProvider>(context),
  );

  factory GuestAccess.resolve({
    required AuthProvider auth,
    required SettingsProvider settings,
  }) => GuestAccess(
    isGuest: auth.isGuest,
    isAuthenticated: auth.isAuthenticated,
    settings: settings.settings,
  );

  /// A biblioteca oferece entrada sem conta (botão "entrar como convidado").
  ///
  /// Enquanto `GET /api/settings` não expuser o campo — e ele só é legível por
  /// quem já tem sessão —, isto vale `true`. Ver relatório da tarefa.
  bool get guestModeOffered => _settings.guestAccessEnabled;

  /// Sessão de convidado ainda válida. Falso quando a biblioteca desligou o
  /// acesso sem conta com alguém já navegando assim.
  bool get canBrowseAsGuest => isGuest && _settings.guestAccessEnabled;

  /// O catálogo é vitrine: `/api/books/catalog`, `/public/search` e
  /// `/genres/**` são públicos na API.
  bool get canBrowseCatalog => true;

  /// Empréstimo, curtida, histórico e ranking são do leitor identificado.
  bool get canRequestLoan => isAuthenticated;
  bool get canLikeBooks => isAuthenticated;
  bool get canSeeOwnLoans => isAuthenticated;

  /// Aba visível (a biblioteca habilitou) x conteúdo legível (tem sessão).
  /// O convidado continua vendo a aba, com convite ao login no lugar da lista —
  /// esconder a aba mudaria a contagem de abas no meio da sessão.
  bool get rankingTabVisible => _settings.features.ranking;
  bool get canReadRanking => isAuthenticated && rankingTabVisible;

  /// Mesma divisão do ranking, sem a palavra "aba": o mural virou botão do
  /// cabeçalho. O convidado continua vendo o botão, com convite ao login no
  /// lugar da lista.
  bool get contentsVisible => _settings.features.contents;
  bool get canReadContents => isAuthenticated && contentsVisible;

  /// Trocar senha, sair da conta e biometria só existem com conta.
  bool get canManageAccount => isAuthenticated;

  bool get canEditAvatar => isAuthenticated && _settings.readerCanEditAvatar;
}
