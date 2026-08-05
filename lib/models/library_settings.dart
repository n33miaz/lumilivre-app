class LibrarySettings {
  final LibraryType libraryType;
  final bool readerCanEditAvatar;

  /// A biblioteca aceita visitante sem conta.
  ///
  /// O campo ainda não existe em `GET /api/settings`; até existir, ausência vale
  /// como `true` para o app continuar oferecendo o modo convidado como hoje.
  final bool guestAccessEnabled;

  final SettingsFeatures features;

  const LibrarySettings({
    required this.libraryType,
    required this.readerCanEditAvatar,
    required this.guestAccessEnabled,
    required this.features,
  });

  factory LibrarySettings.school() {
    return const LibrarySettings(
      libraryType: LibraryType.school,
      readerCanEditAvatar: true,
      guestAccessEnabled: true,
      features: SettingsFeatures(
        academicFields: true,
        ranking: true,
        contents: true,
      ),
    );
  }

  factory LibrarySettings.fromJson(Map<String, dynamic> json) {
    return LibrarySettings(
      libraryType: LibraryType.fromJson(json['libraryType']),
      readerCanEditAvatar: json['readerCanEditAvatar'] != false,
      guestAccessEnabled: json['guestAccessEnabled'] != false,
      features: SettingsFeatures.fromJson(
        json['features'] is Map<String, dynamic>
            ? json['features'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  bool get isStandard => libraryType == LibraryType.standard;
  bool get isSchool => libraryType == LibraryType.school;
}

enum LibraryType {
  school,
  standard;

  factory LibraryType.fromJson(dynamic value) {
    final normalized = value?.toString().toUpperCase();
    return normalized == 'STANDARD' ? LibraryType.standard : LibraryType.school;
  }
}

class SettingsFeatures {
  final bool academicFields;
  final bool ranking;
  final bool contents;

  const SettingsFeatures({
    required this.academicFields,
    required this.ranking,
    required this.contents,
  });

  factory SettingsFeatures.fromJson(Map<String, dynamic> json) {
    return SettingsFeatures(
      academicFields: json['academicFields'] != false,
      ranking: json['ranking'] != false,
      contents: json['contents'] != false,
    );
  }
}
