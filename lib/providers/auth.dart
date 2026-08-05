import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/api.dart';
import '../services/biometric_auth.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({BiometricAuth? biometrics})
    : _biometrics = biometrics ?? BiometricAuth();

  final ApiService _apiService = ApiService();
  final AuthStorage _authStorage = AuthStorage();
  final BiometricAuth _biometrics;

  LoginResponse? _user;
  bool _isGuest = false;
  bool _authAttempted = false;
  bool _isInitialPassword = false;
  bool _guidedTourCompleted = true;
  bool _biometricLocked = false;

  LoginResponse? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get authAttempted => _authAttempted;
  bool get isInitialPassword => _isInitialPassword;
  bool get guidedTourCompleted => _guidedTourCompleted;

  /// Existe sessão salva, mas a biometria não foi confirmada nesta abertura.
  ///
  /// A sessão continua no armazenamento seguro (o usuário pode reabrir o app e
  /// tentar de novo), só não é exposta.
  bool get biometricLocked => _biometricLocked;

  /// Único token que pode sair em `Authorization`.
  ///
  /// `null` sempre que não há sessão *para este app agora*: convidado, sessão
  /// travada pela biometria, ou nenhuma sessão. Existe para os serviços não
  /// buscarem o token no `flutter_secure_storage` por conta própria — lá o token
  /// continua gravado justamente nos casos em que ele **não** deve ser usado, e é
  /// assim que o modo convidado passou a mandar credencial de leitor.
  String? get sessionToken => _user?.token;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    _user = response;
    _isGuest = false;
    _isInitialPassword = response.isInitialPassword;
    _guidedTourCompleted = response.guidedTourCompleted;
    _biometricLocked = false;

    await _authStorage.saveSession(
      token: response.token,
      userData: jsonEncode(response),
    );

    notifyListeners();
  }

  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    _isInitialPassword = false;
    _guidedTourCompleted = true;
    _biometricLocked = false;

    notifyListeners();
  }

  /// Fecha o ciclo da troca de senha: baixa a flag de senha inicial e adota o
  /// token novo emitido pela API.
  ///
  /// O token novo não é detalhe: `PUT /api/auth/change-password` revoga no
  /// servidor tudo que foi emitido antes da troca, o token em uso incluído. Sem
  /// adotar o da resposta, a requisição seguinte sai com credencial revogada e a
  /// sessão cai logo depois de a senha ter sido trocada com sucesso. [newToken]
  /// aceita `null` porque a API antiga respondia 204, sem token.
  Future<void> completePasswordChange({String? newToken}) async {
    _isInitialPassword = false;
    if (_user != null) {
      _user = LoginResponse(
        id: _user!.id,
        email: _user!.email,
        role: _user!.role,
        readerRegistrationNumber: _user!.readerRegistrationNumber,
        token: (newToken != null && newToken.isNotEmpty)
            ? newToken
            : _user!.token,
        isInitialPassword: false,
        guidedTourCompleted: _user!.guidedTourCompleted,
      );
      await _authStorage.saveSession(
        token: _user!.token,
        userData: jsonEncode(_user),
      );
    }
    notifyListeners();
  }

  /// Marca o tour guiado como concluído localmente e regrava a sessão.
  Future<void> completeTour() async {
    _guidedTourCompleted = true;
    if (_user != null) {
      _user = LoginResponse(
        id: _user!.id,
        email: _user!.email,
        role: _user!.role,
        readerRegistrationNumber: _user!.readerRegistrationNumber,
        token: _user!.token,
        isInitialPassword: _user!.isInitialPassword,
        guidedTourCompleted: true,
      );
      await _authStorage.saveSession(
        token: _user!.token,
        userData: jsonEncode(_user),
      );
    }
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    await _authStorage.migrateLegacySession();

    try {
      final token = await _authStorage.getToken();
      final userDataString = await _authStorage.getUserData();

      if (token == null || userDataString == null) {
        _authAttempted = true;
        notifyListeners();
        return;
      }

      // Gate biométrico antes de expor a sessão: com a preferência ligada, sem
      // biometria confirmada não há sessão restaurada — cai na tela de login,
      // onde a senha continua funcionando. Falhar aberto aqui tornaria o toggle
      // decorativo de novo.
      if (await _biometrics.isEnabled() &&
          !await _biometrics.confirmToUnlock()) {
        _biometricLocked = true;
        _user = null;
        _authAttempted = true;
        notifyListeners();
        return;
      }

      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      _user = LoginResponse.fromJson({...userData, 'token': token});
      _isInitialPassword = _user?.isInitialPassword ?? false;
      _guidedTourCompleted = _user?.guidedTourCompleted ?? true;
    } catch (_) {
      await _authStorage.clearSession();
      _user = null;
      _isInitialPassword = false;
      _guidedTourCompleted = true;
    }

    _authAttempted = true;
    notifyListeners();
  }

  /// Sai da conta aqui e no servidor.
  ///
  /// A sessão local sai primeiro e a revogação no servidor vem depois, em melhor
  /// esforço: sair da conta no próprio aparelho não pode depender de conexão, e
  /// se o app morrer no meio do caminho o pior cenário é um token que expira
  /// sozinho — não uma sessão que volta no próximo abrir.
  Future<void> logout() async {
    final token = _user?.token;

    _user = null;
    _isGuest = false;
    _isInitialPassword = false;
    _guidedTourCompleted = true;
    _biometricLocked = false;
    await _authStorage.clearSession();

    notifyListeners();

    if (token != null && token.isNotEmpty) {
      await _apiService.logout(token);
    }
  }
}
