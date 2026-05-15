import 'package:shared_preferences/shared_preferences.dart';

class RequestContext {
  static const _localeKey = 'app_locale';

  static Future<String> currentLocaleTag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'pt-BR';
  }

  static Future<Map<String, String>> headers({String? token}) async {
    final headers = <String, String>{
      'Accept-Language': await currentLocaleTag(),
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> jsonHeaders({String? token}) async {
    final requestHeaders = await headers(token: token);
    requestHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    return requestHeaders;
  }
}
