import 'package:flutter/foundation.dart';

import '../../../core/models/digital_format.dart';

import '../../../core/repositories/digital_sources/source_http.dart';
import '../../../core/utils/text_paginator.dart';

enum ReaderStatus { loading, notDownloaded, downloading, ready, failure }

/// Okuyucuda seçilen metnin alıntı olarak kaydedilme sonucu (view SnackBar gösterir).
enum QuoteSaveResult { saved, duplicate }

@immutable
class ReaderModel {
  final ReaderStatus status;
  final double downloadProgress;
  final List<TextPage> pages;
  final int pageIndex;

  /// Hata metin olarak değil anahtar olarak tutulur; view ARB'den çevirir.
  final DigitalBookFailure? error;

  /// Son sayfaya gelindiğinde "Bitti olarak işaretle" önerisini tetikler.
  final bool finishSuggested;

  /// Son alıntı kaydının sonucu; view gösterdikten sonra temizlenir.
  final QuoteSaveResult? quoteResult;

  /// `pdf` ise metin sayfaları yerine PDF görüntüleyici kullanılır.
  final DigitalFormat format;
  final Uint8List? pdfBytes;

  /// PDF'in sayfa sayısı (görüntüleyici belgeyi açınca öğrenilir).
  final int pdfPageCount;

  const ReaderModel({
    this.status = ReaderStatus.loading,
    this.downloadProgress = 0,
    this.pages = const [],
    this.pageIndex = 0,
    this.error,
    this.finishSuggested = false,
    this.quoteResult,
    this.format = DigitalFormat.text,
    this.pdfBytes,
    this.pdfPageCount = 0,
  });

  bool get isPdf => format == DigitalFormat.pdf;
  int get pageCount => isPdf ? pdfPageCount : pages.length;
  bool get isFirstPage => pageIndex <= 0;
  bool get isLastPage => pageIndex >= pages.length - 1;

  ReaderModel copyWith({
    ReaderStatus? status,
    double? downloadProgress,
    List<TextPage>? pages,
    int? pageIndex,
    DigitalBookFailure? error,
    bool clearError = false,
    bool? finishSuggested,
    QuoteSaveResult? quoteResult,
    bool clearQuoteResult = false,
    DigitalFormat? format,
    Uint8List? pdfBytes,
    int? pdfPageCount,
  }) {
    return ReaderModel(
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      pages: pages ?? this.pages,
      pageIndex: pageIndex ?? this.pageIndex,
      error: clearError ? null : (error ?? this.error),
      finishSuggested: finishSuggested ?? this.finishSuggested,
      quoteResult: clearQuoteResult ? null : (quoteResult ?? this.quoteResult),
      format: format ?? this.format,
      pdfBytes: pdfBytes ?? this.pdfBytes,
      pdfPageCount: pdfPageCount ?? this.pdfPageCount,
    );
  }

  factory ReaderModel.fromJson(Map<String, dynamic> json) {
    return ReaderModel(
      pageIndex: json['pageIndex'] as int? ?? 0,
      downloadProgress: (json['downloadProgress'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'pageIndex': pageIndex, 'downloadProgress': downloadProgress};
  }
}
