import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'translation_engine.dart';

/// Uygulamanın kendi yerel köprüsüyle (`kitalog/translation`) cihaz üstü çeviri
/// ve dil tanıma. Android'de Google ML Kit (`MainActivity` → `TranslationChannel.kt`),
/// iOS'ta Apple Translation + NaturalLanguage (`TranslationChannel.swift`) çalışır.
/// Dil paketi bir kez indirildikten sonra çeviri internetsiz çalışır.
class NativeTranslationEngine implements TranslationEngine {
  @visibleForTesting
  NativeTranslationEngine({required this.systemConfirmsDownload});

  static const MethodChannel _channel = MethodChannel('kitalog/translation');

  /// Yerel taraf çeviriyi destekliyorsa motoru, desteklemiyorsa (web, masaüstü,
  /// Apple'ın çeviriyi kapattığı iOS simülatörü) çeviriyi gizleyen motoru verir.
  static Future<TranslationEngine> create() async {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!mobile) return const UnsupportedTranslationEngine();
    try {
      final info = await _channel.invokeMapMethod<String, Object?>('info');
      if (info?['supported'] != true) return const UnsupportedTranslationEngine();
      return NativeTranslationEngine(
        systemConfirmsDownload: info?['systemConfirmsDownload'] == true,
      );
    } on PlatformException {
      return const UnsupportedTranslationEngine();
    } on MissingPluginException {
      return const UnsupportedTranslationEngine();
    }
  }

  @override
  bool get isSupported => true;

  @override
  final bool systemConfirmsDownload;

  @override
  Future<String> identifyLanguage(String text) async {
    if (text.trim().isEmpty) return '';
    try {
      return await _channel.invokeMethod<String>('identifyLanguage', {
            'text': text,
          }) ??
          '';
    } on PlatformException {
      return '';
    }
  }

  @override
  Future<bool> areModelsDownloaded({
    required String from,
    required String to,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('areModelsDownloaded', {
            'from': from,
            'to': to,
          }) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> downloadModels({required String from, required String to}) async {
    try {
      await _channel.invokeMethod<void>('downloadModels', {
        'from': from,
        'to': to,
      });
    } on PlatformException catch (e) {
      throw TranslationException(
        e.code == 'downloadDeclined'
            ? TranslationFailure.downloadDeclined
            : TranslationFailure.modelDownload,
      );
    }
  }

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('translate', {
        'text': text,
        'from': from,
        'to': to,
      });
      if (result == null) {
        throw const TranslationException(TranslationFailure.translate);
      }
      return result;
    } on PlatformException catch (e) {
      // Dil paketi sonradan silinmişse "Tekrar dene" paketi yeniden indirir.
      throw TranslationException(
        e.code == 'modelDownload'
            ? TranslationFailure.modelDownload
            : TranslationFailure.translate,
      );
    }
  }

  @override
  Future<void> close() async {
    try {
      await _channel.invokeMethod<void>('close');
    } on PlatformException {
      // Kapatılamayan çevirmen uygulama kapanınca zaten bırakılır.
    }
  }
}
