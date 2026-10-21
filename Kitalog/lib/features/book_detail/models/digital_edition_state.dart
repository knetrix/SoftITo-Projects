import 'package:flutter/foundation.dart';

import '../../../core/models/digital_copy_model.dart';
import '../../../core/repositories/digital_sources/source_http.dart';

/// Kitap Detay'daki dijital sürüm bölümünün durumu.
@immutable
class DigitalEditionState {
  /// Cihazdaki kopya; `null` ise kitap henüz indirilmedi / yüklenmedi.
  final DigitalCopyModel? copy;
  final bool isDownloading;
  final double progress;

  /// Kullanıcının seçtiği PDF / EPUB hazırlanıyor.
  final bool isImporting;
  final DigitalBookFailure? error;

  const DigitalEditionState({
    this.copy,
    this.isDownloading = false,
    this.progress = 0,
    this.isImporting = false,
    this.error,
  });

  bool get isDownloaded => copy != null;
  bool get isBusy => isDownloading || isImporting;

  DigitalEditionState copyWith({
    DigitalCopyModel? copy,
    bool clearCopy = false,
    bool? isDownloading,
    double? progress,
    bool? isImporting,
    DigitalBookFailure? error,
    bool clearError = false,
  }) {
    return DigitalEditionState(
      copy: clearCopy ? null : (copy ?? this.copy),
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      isImporting: isImporting ?? this.isImporting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory DigitalEditionState.fromJson(Map<String, dynamic> json) {
    final copy = json['copy'];
    return DigitalEditionState(
      copy: copy is Map<String, dynamic> ? DigitalCopyModel.fromJson(copy) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'copy': copy?.toJson()};
  }
}
