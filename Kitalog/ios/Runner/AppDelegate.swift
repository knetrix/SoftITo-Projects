import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var translationChannel: TranslationChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // İade hatırlatmaları uygulama açıkken de gösterilsin (flutter_local_notifications).
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Okuyucudaki çeviri için uygulamanın kendi yerel köprüsü (Apple Translation).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "KitalogTranslation") {
      translationChannel = TranslationChannel(messenger: registrar.messenger())
    }
  }
}
