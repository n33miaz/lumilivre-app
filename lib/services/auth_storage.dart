import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String authTokenKey = 'authToken';
  static const String userDataKey = 'userData';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveSession({
    required String token,
    required String userData,
  }) async {
    await _secureStorage.write(key: authTokenKey, value: token);
    await _secureStorage.write(key: userDataKey, value: userData);
  }

  Future<String?> getToken() {
    return _secureStorage.read(key: authTokenKey);
  }

  Future<String?> getUserData() {
    return _secureStorage.read(key: userDataKey);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: authTokenKey);
    await _secureStorage.delete(key: userDataKey);
  }
}
