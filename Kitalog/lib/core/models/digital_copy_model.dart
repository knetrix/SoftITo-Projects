import 'package:flutter/foundation.dart';

import 'digital_format.dart';

/// Cihazdaki dijital kopyanın bilgisi; metnin / PDF'in kendisi dosyada tutulur.
@immutable
class DigitalCopyModel {
  final String bookId;
  final String fileName;

  /// Uzunluk birimi: metinde karakter sayısı, PDF'te sayfa sayısı
  /// (PDF ilk açılana kadar 0 olabilir).
  final int charCount;
  final DateTime downloadedAt;

  /// Kalınan yer: metinde karakter konumu, PDF'te 0'dan başlayan sayfa sırası.
  final int lastOffset;
  final DigitalFormat format;

  /// Dosyanın cihazdaki boyutu (bayt).
  final int byteSize;

  /// Metnin temizlendiği `ReadingTextCleaner.version`; eski kopyalar (0)
  /// açılırken güncel kurallarla yeniden temizlenir.
  final int textVersion;

  const DigitalCopyModel({
    required this.bookId,
    required this.fileName,
    required this.charCount,
    required this.downloadedAt,
    this.lastOffset = 0,
    this.format = DigitalFormat.text,
    this.byteSize = 0,
    this.textVersion = 0,
  });

  /// 0.0 - 1.0 arası okuma ilerlemesi (saklanmaz, hesaplanır).
  double get progress =>
      charCount > 0 ? (lastOffset / charCount).clamp(0.0, 1.0) : 0.0;

  DigitalCopyModel copyWith({
    String? bookId,
    String? fileName,
    int? charCount,
    DateTime? downloadedAt,
    int? lastOffset,
    DigitalFormat? format,
    int? byteSize,
    int? textVersion,
  }) {
    return DigitalCopyModel(
      bookId: bookId ?? this.bookId,
      fileName: fileName ?? this.fileName,
      charCount: charCount ?? this.charCount,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      lastOffset: lastOffset ?? this.lastOffset,
      format: format ?? this.format,
      byteSize: byteSize ?? this.byteSize,
      textVersion: textVersion ?? this.textVersion,
    );
  }

  factory DigitalCopyModel.fromJson(Map<String, dynamic> json) {
    return DigitalCopyModel(
      bookId: json['bookId'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
      charCount: json['charCount'] as int? ?? 0,
      downloadedAt:
          DateTime.tryParse(json['downloadedAt'] as String? ?? '') ??
          DateTime.now(),
      lastOffset: json['lastOffset'] as int? ?? 0,
      format: DigitalFormat.fromName(json['format'] as String?),
      byteSize: json['byteSize'] as int? ?? 0,
      textVersion: json['textVersion'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'fileName': fileName,
      'charCount': charCount,
      'downloadedAt': downloadedAt.toIso8601String(),
      'lastOffset': lastOffset,
      'format': format.name,
      'byteSize': byteSize,
      'textVersion': textVersion,
    };
  }
}
