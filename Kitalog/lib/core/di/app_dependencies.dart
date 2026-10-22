import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../controllers/auth_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/loan_reminder_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/reading_reminder_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_search_repository.dart';
import '../repositories/digital_book_repository.dart';
import '../repositories/digital_sources/gutenberg_source.dart';
import '../repositories/digital_sources/source_http.dart';
import '../repositories/digital_sources/wikisource_source.dart';
import '../repositories/genre_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/loan_history_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/quote_repository.dart';
import '../repositories/reading_log_repository.dart';
import '../repositories/reminders/local_notifications_reminder_engine.dart';
import '../repositories/reminders/reminder_engine.dart';
import '../repositories/settings_repository.dart';
import '../repositories/translation/translation_engine.dart';
import '../repositories/translation_repository.dart';
import '../storage/digital_file_storage.dart';
import '../storage/local_storage_service.dart';
import '../storage/platform_digital_file_storage.dart';
import '../utils/pdf_page_counter.dart';
import '../utils/pdf_text_sampler.dart';
import 'app_scope.dart';

/// Repository ve paylaşılan controller'ları tek yerde oluşturur.
class AppDependencies {
  /// Testlerde sahte HTTP istemcisi, bellek içi dosya depolaması ve sahte
  /// çeviri motoru verilebilir. Çeviri motoru verilmezse çeviri gizlenir;
  /// uygulama yerel motoru `main.dart`'ta `NativeTranslationEngine.create` ile verir.
  AppDependencies(
    LocalStorageService storage, {
    http.Client? httpClient,
    DigitalFileStorage? digitalFiles,
    Duration sourceMinInterval = const Duration(milliseconds: 350),
    bool animateDecorations = true,
    Future<int> Function(Uint8List bytes) countPdfPages = PdfPageCounter.count,
    Future<String> Function(Uint8List bytes) samplePdfText = PdfTextSampler.sample,
    TranslationEngine? translationEngine,
    ReminderEngine? reminderEngine,
  }) : this._(
         storage,
         httpClient ?? http.Client(),
         digitalFiles ?? createPlatformDigitalFileStorage(),
         sourceMinInterval,
         animateDecorations,
         countPdfPages,
         samplePdfText,
         translationEngine ?? const UnsupportedTranslationEngine(),
         reminderEngine ?? _platformReminderEngine(),
       );

  AppDependencies._(
    LocalStorageService storage,
    http.Client client,
    DigitalFileStorage digitalFiles,
    Duration sourceMinInterval,
    this.animateDecorations,
    Future<int> Function(Uint8List bytes) countPdfPages,
    Future<String> Function(Uint8List bytes) samplePdfText,
    TranslationEngine translationEngine,
    ReminderEngine reminderEngine,
  ) : bookSearchRepository = BookSearchRepository(client: client),
      digitalBookRepository = _digitalRepository(
        storage,
        client,
        digitalFiles,
        sourceMinInterval,
        countPdfPages,
        samplePdfText,
      ),
      translationRepository = TranslationRepository(
        engine: translationEngine,
        files: digitalFiles,
      ),
      authRepository = AuthRepository(storage),
      bookRepository = BookRepository(storage),
      quoteRepository = QuoteRepository(storage),
      noteRepository = NoteRepository(storage),
      goalRepository = GoalRepository(storage),
      genreRepository = GenreRepository(storage),
      loanHistoryRepository = LoanHistoryRepository(storage),
      readingLogRepository = ReadingLogRepository(storage),
      settingsRepository = SettingsRepository(storage) {
    authController = AuthController(repository: authRepository);
    settingsController = SettingsController(repository: settingsRepository);
    libraryController = LibraryController(
      bookRepository: bookRepository,
      quoteRepository: quoteRepository,
      noteRepository: noteRepository,
      goalRepository: goalRepository,
      genreRepository: genreRepository,
      loanHistoryRepository: loanHistoryRepository,
      readingLogRepository: readingLogRepository,
    );
    loanReminderController = LoanReminderController(
      library: libraryController,
      settings: settingsController,
      engine: reminderEngine,
    );
    readingReminderController = ReadingReminderController(
      library: libraryController,
      settings: settingsController,
      engine: reminderEngine,
    );
    notificationController = NotificationController(
      engine: reminderEngine,
      loanReminders: loanReminderController,
      readingReminders: readingReminderController,
    );
  }

  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final BookSearchRepository bookSearchRepository;
  final DigitalBookRepository digitalBookRepository;
  final TranslationRepository translationRepository;
  final QuoteRepository quoteRepository;
  final NoteRepository noteRepository;
  final GoalRepository goalRepository;
  final GenreRepository genreRepository;
  final LoanHistoryRepository loanHistoryRepository;
  final ReadingLogRepository readingLogRepository;
  final SettingsRepository settingsRepository;

  /// Süs animasyonları açık mı (testlerde `pumpAndSettle` bitebilsin diye kapalı).
  final bool animateDecorations;
  late final AuthController authController;
  late final SettingsController settingsController;
  late final LibraryController libraryController;

  /// İade hatırlatmaları; [notificationController] başlatır.
  late final LoanReminderController loanReminderController;

  /// Günlük okuma ve yarım kalan kitap hatırlatmaları; [notificationController] başlatır.
  late final ReadingReminderController readingReminderController;

  /// Bildirim motoru ve dokunulan bildirim; `main.dart` başlatır (testlerde yalnızca gerektiğinde).
  late final NotificationController notificationController;

  static DigitalBookRepository _digitalRepository(
    LocalStorageService storage,
    http.Client client,
    DigitalFileStorage files,
    Duration minInterval,
    Future<int> Function(Uint8List bytes) countPdfPages,
    Future<String> Function(Uint8List bytes) samplePdfText,
  ) {
    final sourceHttp = SourceHttp(client: client, minInterval: minInterval);
    return DigitalBookRepository(
      storage: storage,
      files: files,
      gutenberg: GutenbergSource(sourceHttp),
      wikisource: WikisourceSource(sourceHttp),
      loadAsset: rootBundle.loadString,
      countPdfPages: countPdfPages,
      samplePdfText: samplePdfText,
    );
  }

  /// Yerel bildirim yalnızca Android / iOS'ta zamanlanır; diğer platformlarda hatırlatma yok.
  static ReminderEngine _platformReminderEngine() => LocalNotificationsReminderEngine.platformSupported
      ? LocalNotificationsReminderEngine()
      : const UnsupportedReminderEngine();

  Widget scope({required Widget child}) {
    return AppScope(
      authController: authController,
      libraryController: libraryController,
      settingsController: settingsController,
      notificationController: notificationController,
      authRepository: authRepository,
      bookRepository: bookRepository,
      bookSearchRepository: bookSearchRepository,
      digitalBookRepository: digitalBookRepository,
      translationRepository: translationRepository,
      quoteRepository: quoteRepository,
      noteRepository: noteRepository,
      goalRepository: goalRepository,
      settingsRepository: settingsRepository,
      animateDecorations: animateDecorations,
      child: child,
    );
  }
}
