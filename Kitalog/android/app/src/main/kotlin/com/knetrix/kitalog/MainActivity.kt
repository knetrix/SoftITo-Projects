package com.knetrix.kitalog

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var translation: TranslationChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Okuyucudaki çeviri için uygulamanın kendi yerel köprüsü (Google ML Kit).
        translation = TranslationChannel(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        translation?.dispose()
        translation = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
