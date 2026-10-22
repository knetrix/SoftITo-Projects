import Flutter
import NaturalLanguage
import SwiftUI
import Translation
import UIKit

/// Okuyucudaki çevirinin iOS tarafı (`kitalog/translation`): Apple Translation ile
/// cihaz üstü çeviri, NaturalLanguage ile dil tanıma. Dil paketinin indirilmesini
/// sistem kendi penceresinde sorar ve yönetir; sonra çeviri internetsiz çalışır.
/// Apple çeviriyi simülatörde kapattığı için simülatörde çeviri gizlenir.
@MainActor
final class TranslationChannel {
  private static let languageConfidence = 0.5

  private let channel: FlutterMethodChannel
  private let host = TranslationSessionHost()

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "kitalog/translation", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      Task { @MainActor in await self?.handle(call, result: result) }
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) async {
    let args = call.arguments as? [String: Any] ?? [:]
    let from = Locale.Language(identifier: args["from"] as? String ?? "")
    let to = Locale.Language(identifier: args["to"] as? String ?? "")
    switch call.method {
    case "info":
      #if targetEnvironment(simulator)
        let supported = false
      #else
        let supported = true
      #endif
      result(["supported": supported, "systemConfirmsDownload": true])
    case "identifyLanguage":
      result(identifyLanguage(args["text"] as? String ?? ""))
    case "areModelsDownloaded":
      result(await LanguageAvailability().status(from: from, to: to) == .installed)
    case "downloadModels":
      await downloadModels(from: from, to: to, result: result)
    case "translate":
      await translate(args["text"] as? String ?? "", from: from, to: to, result: result)
    case "close":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Dil kodu; belirlenemezse (güven %50'nin altında) boş metin.
  private func identifyLanguage(_ text: String) -> String {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    guard let (language, confidence) = recognizer.languageHypotheses(withMaximum: 1).first,
      confidence >= Self.languageConfidence
    else { return "" }
    return language.rawValue
  }

  /// Sistem dil paketi penceresini açar. Kullanıcı vazgeçerse `downloadDeclined` döner.
  private func downloadModels(
    from: Locale.Language, to: Locale.Language, result: @escaping FlutterResult
  ) async {
    let availability = LanguageAvailability()
    if await availability.status(from: from, to: to) == .installed { return result(nil) }
    do {
      try await host.run(from: from, to: to) { session in try await session.prepareTranslation() }
    } catch is CancellationError {
      // Pencere kapatıldı; aşağıda paketin inip inmediğine bakılır.
    } catch {
      return result(FlutterError(code: "modelDownload", message: "\(error)", details: nil))
    }
    if await availability.status(from: from, to: to) == .installed { return result(nil) }
    // Pencere kapandı ama paket inmedi: kullanıcı vazgeçti.
    result(FlutterError(code: "downloadDeclined", message: nil, details: nil))
  }

  /// Paket yoksa sistem penceresi açılmaz; `modelDownload` ile "Tekrar dene" indirir.
  private func translate(
    _ text: String, from: Locale.Language, to: Locale.Language, result: @escaping FlutterResult
  ) async {
    guard await LanguageAvailability().status(from: from, to: to) == .installed else {
      return result(FlutterError(code: "modelDownload", message: nil, details: nil))
    }
    do {
      let response = try await host.run(from: from, to: to) { session in
        try await session.translate(text)
      }
      result(response.targetText)
    } catch {
      result(FlutterError(code: "translate", message: "\(error)", details: nil))
    }
  }
}

/// `TranslationSession` yalnızca SwiftUI `translationTask` içinde alınabildiği için
/// Flutter penceresine 1×1 boyutunda görünmez bir SwiftUI görünümü eklenir. İşler
/// sıraya girer ve oturum açıkken sırayla çalıştırılır; satır satır gelen çeviriler
/// için oturum kısa bir süre açık tutulur.
@MainActor
private final class TranslationSessionHost: ObservableObject {
  private struct Job {
    let source: Locale.Language
    let target: Locale.Language
    let work: (TranslationSession) async -> Void
    let fail: (Error) -> Void
  }

  /// Sıra boşaldıktan sonra yeni iş için oturumun açık bekleyeceği süre.
  private static let linger: Duration = .milliseconds(300)

  @Published var configuration: TranslationSession.Configuration?
  private var jobs: [Job] = []
  private var running = false
  private var hostController: UIViewController?

  func run<T>(
    from source: Locale.Language, to target: Locale.Language,
    _ body: @escaping (TranslationSession) async throws -> T
  ) async throws -> T {
    try await withCheckedThrowingContinuation { continuation in
      jobs.append(
        Job(
          source: source, target: target,
          work: { session in
            do {
              continuation.resume(returning: try await body(session))
            } catch {
              continuation.resume(throwing: error)
            }
          },
          fail: { continuation.resume(throwing: $0) }))
      startIfNeeded()
    }
  }

  /// `translationTask` oturumu verdiğinde aynı dil çiftindeki işleri çalıştırır.
  func process(_ session: TranslationSession) async {
    guard let pair = configuration else { return }
    var idleSince = ContinuousClock.now
    while true {
      if let index = jobs.firstIndex(where: { $0.source == pair.source && $0.target == pair.target }) {
        let job = jobs.remove(at: index)
        await job.work(session)
        idleSince = .now
      } else if jobs.isEmpty, ContinuousClock.now - idleSince < Self.linger {
        try? await Task.sleep(for: .milliseconds(20))
      } else {
        break
      }
    }
    running = false
    startIfNeeded()
  }

  private func startIfNeeded() {
    guard !running, let next = jobs.first else { return }
    guard attach() else {
      // Pencere yoksa (uygulama arka planda açılıyor) işler hata ile döner.
      let pending = jobs
      jobs.removeAll()
      for job in pending { job.fail(TranslationHostError.noWindow) }
      return
    }
    running = true
    if configuration?.source == next.source && configuration?.target == next.target {
      configuration?.invalidate()
    } else {
      configuration = TranslationSession.Configuration(source: next.source, target: next.target)
    }
  }

  private func attach() -> Bool {
    if hostController != nil { return true }
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }
    guard let root = window?.rootViewController else { return false }
    let controller = UIHostingController(rootView: TranslationHostView(host: self))
    controller.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    controller.view.backgroundColor = .clear
    controller.view.isUserInteractionEnabled = false
    controller.view.accessibilityElementsHidden = true
    root.addChild(controller)
    root.view.addSubview(controller.view)
    controller.didMove(toParent: root)
    hostController = controller
    return true
  }
}

private enum TranslationHostError: Error { case noWindow }

private struct TranslationHostView: View {
  @ObservedObject var host: TranslationSessionHost

  var body: some View {
    Color.clear.translationTask(host.configuration) { session in
      await host.process(session)
    }
  }
}
