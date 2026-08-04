class LibrarySettings {
  final LibraryType libraryType;
  final SettingsFeatures features;

  const LibrarySettings({required this.libraryType, required this.features});

  factory LibrarySettings.school() {
    return const LibrarySettings(
      libraryType: LibraryType.school,
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
