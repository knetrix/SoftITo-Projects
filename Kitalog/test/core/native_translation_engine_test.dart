import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/repositories/translation/native_translation_engine.dart';
import 'package:kitalog/core/repositories/translation/translation_engine.dart';

/// Yerel köprü (`kitalog/translation`) sahte bir kanal işleyicisiyle test edilir.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('kitalog/translation');
  final calls = <MethodCall>[];

  void handle(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          calls.add(call);
          return handler(call);
        });
  }

  setUp(calls.clear);

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('create', () {
    test('yerel taraf destekliyorsa motor ve onay biçimi oradan gelir', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      handle((_) async => {'supported': true, 'systemConfirmsDownload': true});
      final engine = await NativeTranslationEngine.create();
      expect(engine, isA<NativeTranslationEngine>());
      expect(engine.isSupported, isTrue);
      expect(engine.systemConfirmsDownload, isTrue);
    });

    test('iOS simülatörü gibi desteklenmiyorsa çeviri gizlenir', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      handle((_) async => {'supported': false, 'systemConfirmsDownload': true});
      final engine = await NativeTranslationEngine.create();
      expect(engine.isSupported, isFalse);
    });

    test('yerel köprü yoksa çeviri gizlenir', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final engine = await NativeTranslationEngine.create();
      expect(engine.isSupported, isFalse);
    });

    test('masaüstünde yerel tarafa hiç sorulmaz', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      handle((_) async => {'supported': true});
      final engine = await NativeTranslationEngine.create();
      expect(engine.isSupported, isFalse);
      expect(calls, isEmpty);
    });
  });

  test('dil tanıma ve paket durumu yerel tarafa doğru argümanlarla sorulur', () async {
    handle(
      (call) async => switch (call.method) {
        'identifyLanguage' => 'tr',
        'areModelsDownloaded' => true,
        _ => null,
      },
    );
    final engine = NativeTranslationEngine(systemConfirmsDownload: false);
    expect(await engine.identifyLanguage('Merhaba dünya'), 'tr');
    expect(await engine.identifyLanguage('   '), '');
    expect(await engine.areModelsDownloaded(from: 'en', to: 'tr'), isTrue);
    expect(calls.map((c) => c.method), ['identifyLanguage', 'areModelsDownloaded']);
    expect(calls.last.arguments, {'from': 'en', 'to': 'tr'});
  });

  test('çeviri sonucu döner', () async {
    handle((call) async => '[${call.arguments['to']}] ${call.arguments['text']}');
    final engine = NativeTranslationEngine(systemConfirmsDownload: false);
    expect(await engine.translate('Hello', from: 'en', to: 'tr'), '[tr] Hello');
  });

  test('yerel hata kodları çeviri hatalarına eşlenir', () async {
    var code = 'downloadDeclined';
    handle((_) async => throw PlatformException(code: code));
    final engine = NativeTranslationEngine(systemConfirmsDownload: true);

    Future<TranslationFailure?> failureOf(Future<Object?> Function() action) async {
      try {
        await action();
      } on TranslationException catch (e) {
        return e.failure;
      }
      return null;
    }

    Future<Object?> download() => engine.downloadModels(from: 'en', to: 'tr');
    Future<Object?> translate() => engine.translate('Hi', from: 'en', to: 'tr');

    expect(await failureOf(download), TranslationFailure.downloadDeclined);
    code = 'modelDownload';
    expect(await failureOf(download), TranslationFailure.modelDownload);
    expect(await failureOf(translate), TranslationFailure.modelDownload);
    code = 'translate';
    expect(await failureOf(translate), TranslationFailure.translate);

    // Hata durumunda dil tanıma ve paket durumu sessizce "bilinmiyor" döner.
    expect(await engine.identifyLanguage('Hello'), '');
    expect(await engine.areModelsDownloaded(from: 'en', to: 'tr'), isFalse);
  });
}
