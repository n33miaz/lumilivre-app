import '../utils/parsers.dart';

/// Informações de versão do app devolvidas por `GET /api/app-version` (WS-08).
///
/// Endpoint público (sem autenticação) usado para o gate de atualização
/// obrigatória. Os builds ([latestBuild] / [minSupportedBuild]) são comparados
/// por número inteiro contra o `buildNumber` de runtime.
class AppVersionInfo {
  final String platform;
  final String latestVersion;
  final int latestBuild;
  final String minSupportedVersion;
  final int minSupportedBuild;
  final bool forceUpdate;
  final String? updateMessage;
  final String? storeUrl;
  final String? updatedAt;
  final String? updatedBy;

  const AppVersionInfo({
    required this.platform,
    required this.latestVersion,
    required this.latestBuild,
    required this.minSupportedVersion,
    required this.minSupportedBuild,
    required this.forceUpdate,
    this.updateMessage,
    this.storeUrl,
    this.updatedAt,
    this.updatedBy,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      platform: (json['platform'] ?? '').toString(),
      latestVersion: (json['latestVersion'] ?? '').toString(),
      latestBuild: safeParseInt(json['latestBuild']),
      minSupportedVersion: (json['minSupportedVersion'] ?? '').toString(),
      minSupportedBuild: safeParseInt(json['minSupportedBuild']),
      forceUpdate: json['forceUpdate'] == true,
      updateMessage: _stringOrNull(json['updateMessage']),
      storeUrl: _stringOrNull(json['storeUrl']),
      updatedAt: _stringOrNull(json['updatedAt']),
      updatedBy: _stringOrNull(json['updatedBy']),
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
