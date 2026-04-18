import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> migrateLegacySession() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(authTokenKey);
    final legacyUserData = prefs.getString(userDataKey);

    if (legacyToken != null && legacyUserData != null) {
      final currentToken = await getToken();
      final currentUserData = await getUserData();

      if (currentToken == null || currentUserData == null) {
        await saveSession(token: legacyToken, userData: legacyUserData);
      }
    }

    if (legacyToken != null) {
      await prefs.remove(authTokenKey);
    }
    if (legacyUserData != null) {
      await prefs.remove(userDataKey);
    }
  }
}
