import 'dart:convert';

import 'package:lumilivre/utils/parsers.dart';

/// Item do mural (feed de conteúdos) devolvido por `GET /api/contents/feed`.
///
/// [contentType] assume os valores `ANNOUNCEMENT`, `ATTACHMENT` ou `WORK`.
class AppContent {
  final String id;
  final String contentType;
  final String title;
  final String? body;
  final String? authors;
  final String? advisors;
  final String? completionYear;
  final String? completionSemester;
  final String? coverUrl;
  final String? fileUrl;
  final String? externalUrl;
  final bool pinned;
  final DateTime createdAt;

  const AppContent({
    required this.id,
    required this.contentType,
    required this.title,
    this.body,
    this.authors,
    this.advisors,
    this.completionYear,
    this.completionSemester,
    this.coverUrl,
    this.fileUrl,
    this.externalUrl,
    this.pinned = false,
    required this.createdAt,
  });

  bool get isAnnouncement => contentType == 'ANNOUNCEMENT';
  bool get isAttachment => contentType == 'ATTACHMENT';
  bool get isWork => contentType == 'WORK';

  factory AppContent.fromMap(Map<String, dynamic> map) {
    return AppContent(
      id: (map['id'] ?? '').toString(),
      contentType: (map['contentType'] ?? '').toString().trim().toUpperCase(),
      title: (map['title'] ?? '').toString(),
      body: _stringOrNull(map['body']),
      authors: _stringOrNull(map['authors']),
      advisors: _stringOrNull(map['advisors']),
      completionYear: _stringOrNull(map['completionYear']),
      completionSemester: _stringOrNull(map['completionSemester']),
      coverUrl: _normalizeUrl(_stringOrNull(map['coverUrl'])),
      fileUrl: _normalizeUrl(_stringOrNull(map['fileUrl'])),
      externalUrl: _normalizeUrl(_stringOrNull(map['externalUrl'])),
      pinned: map['pinned'] == true,
      createdAt: parseDate(map['createdAt'], fallback: DateTime.now),
    );
  }

  factory AppContent.fromJson(String source) =>
      AppContent.fromMap(json.decode(source) as Map<String, dynamic>);

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String? _normalizeUrl(String? rawUrl) {
    if (rawUrl == null) {
      return null;
    }
    return rawUrl.startsWith('http://')
        ? rawUrl.replaceFirst('http://', 'https://')
        : rawUrl;
  }
}
