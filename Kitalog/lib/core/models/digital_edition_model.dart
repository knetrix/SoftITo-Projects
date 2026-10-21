import 'package:flutter/foundation.dart';

import 'digital_format.dart';
import 'digital_source.dart';

/// Kitabın dijital metninin nerede olduğu.
@immutable
class DigitalEditionModel {
  final DigitalSource source;

  /// Gutenberg kitap numarası (ör. `2554`), Vikikaynak sayfa başlığı veya
  /// kullanıcının yüklediği dosyanın adı.
  final String sourceId;
  final String languageCode;
  final DigitalFormat format;

  const DigitalEditionModel({
    required this.source,
    required this.sourceId,
    required this.languageCode,
    this.format = DigitalFormat.text,
  });

  /// Kullanıcının kendi dosyası yeniden indirilemez; cihazdan silinirse yeniden yüklenir.
  bool get isLocalFile => source == DigitalSource.localFile;

  DigitalEditionModel copyWith({
    DigitalSource? source,
    String? sourceId,
    String? languageCode,
    DigitalFormat? format,
  }) {
    return DigitalEditionModel(
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      languageCode: languageCode ?? this.languageCode,
      format: format ?? this.format,
    );
  }

  /// Kaynak bilinmiyorsa veya kimlik boşsa `null` döner.
  static DigitalEditionModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final source = DigitalSource.fromName(json['source'] as String?);
    final id = json['sourceId'] as String? ?? '';
    if (source == null || id.isEmpty) return null;
    return DigitalEditionModel(
      source: source,
      sourceId: id,
      languageCode: json['languageCode'] as String? ?? 'en',
      format: DigitalFormat.fromName(json['format'] as String?),
    );
  }

  factory DigitalEditionModel.fromJson(Map<String, dynamic> json) {
    return tryFromJson(json) ??
        const DigitalEditionModel(
          source: DigitalSource.gutenberg,
          sourceId: '',
          languageCode: 'en',
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.name,
      'sourceId': sourceId,
      'languageCode': languageCode,
      'format': format.name,
    };
  }
}
