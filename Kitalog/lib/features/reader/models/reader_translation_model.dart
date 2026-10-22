import 'package:flutter/foundation.dart';

import '../../../core/repositories/translation/translation_engine.dart';
import '../../../core/repositories/translation_repository.dart';

/// Metin sayfasının nasıl gösterileceği.
enum TranslationView { original, translation, both }

enum TranslationStatus { idle, downloadingModel, translating, failure }

/// Okuyucuda seçilen metnin çevirisi (alttan açılan pencere bunu dinler).
@immutable
class SelectionTranslation {
  final String text;

  /// Seçimin (1'den başlayan) sayfası; "Alıntı olarak kaydet" için.
  final int pageNumber;

  /// PDF seçimi; alıntı kaydedilirken satırlar birleştirilir.
  final bool reflow;
  final String? translated;
  final bool isLoading;
  final TranslationFailure? failure;

  const SelectionTranslation({
    required this.text,
    required this.pageNumber,
    this.reflow = false,
    this.translated,
    this.isLoading = true,
    this.failure,
  });

  SelectionTranslation copyWith({
    String? translated,
    bool? isLoading,
    TranslationFailure? failure,
  }) {
    return SelectionTranslation(
      text: text,
      pageNumber: pageNumber,
      reflow: reflow,
      translated: translated ?? this.translated,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
    );
  }

  factory SelectionTranslation.fromJson(Map<String, dynamic> json) {
    return SelectionTranslation(
      text: json['text'] as String? ?? '',
      pageNumber: json['pageNumber'] as int? ?? 1,
      reflow: json['reflow'] as bool? ?? false,
      translated: json['translated'] as String?,
      isLoading: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'pageNumber': pageNumber,
      'reflow': reflow,
      'translated': translated,
    };
  }
}

@immutable
class ReaderTranslationModel {
  /// Kitabın dil kodu; bilinmiyorsa boş.
  final String sourceLanguage;

  /// Platform çeviriyi destekliyor mu (yalnızca Android ve gerçek iPhone).
  final bool isSupported;
  final TranslationView view;
  final TranslationStatus status;
  final TranslationFailure? failure;

  /// Sayfa sırası → sayfanın satırlarının çevirisi (satır sayısı sayfa metniyle aynı).
  final Map<int, List<String>> pages;

  /// Dil paketi eksik; view "indirilsin mi?" onayını gösterir.
  final bool modelPromptPending;
  final SelectionTranslation? selection;

  const ReaderTranslationModel({
    this.sourceLanguage = '',
    this.isSupported = false,
    this.view = TranslationView.original,
    this.status = TranslationStatus.idle,
    this.failure,
    this.pages = const {},
    this.modelPromptPending = false,
    this.selection,
  });

  String? get targetLanguage => TranslationRepository.targetFor(sourceLanguage);

  /// Çeviri yalnızca desteklenen platformda ve İngilizce / Türkçe kitapta sunulur.
  bool get isAvailable => isSupported && targetLanguage != null;

  bool get showsTranslation => view != TranslationView.original;

  ReaderTranslationModel copyWith({
    String? sourceLanguage,
    bool? isSupported,
    TranslationView? view,
    TranslationStatus? status,
    TranslationFailure? failure,
    bool clearFailure = false,
    Map<int, List<String>>? pages,
    bool? modelPromptPending,
    SelectionTranslation? selection,
    bool clearSelection = false,
  }) {
    return ReaderTranslationModel(
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      isSupported: isSupported ?? this.isSupported,
      view: view ?? this.view,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      pages: pages ?? this.pages,
      modelPromptPending: modelPromptPending ?? this.modelPromptPending,
      selection: clearSelection ? null : (selection ?? this.selection),
    );
  }

  factory ReaderTranslationModel.fromJson(Map<String, dynamic> json) {
    return ReaderTranslationModel(
      sourceLanguage: json['sourceLanguage'] as String? ?? '',
      view:
          TranslationView.values.asNameMap()[json['view']] ??
          TranslationView.original,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sourceLanguage': sourceLanguage, 'view': view.name};
  }
}
