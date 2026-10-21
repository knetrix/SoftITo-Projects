import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../controllers/auth_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_search_repository.dart';
import '../repositories/digital_book_repository.dart';
import '../repositories/digital_sources/gutenberg_source.dart';
import '../repositories/digital_sources/source_http.dart';
import '../repositories/digital_sources/wikisource_source.dart';
import '../repositories/goal_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/quote_repository.dart';
import '../repositories/settings_repository.dart';
import '../storage/digital_file_storage.dart';
import '../storage/local_storage_service.dart';
import '../storage/platform_digital_file_storage.dart';
import 'app_scope.dart';

/// Repository ve paylaşılan controller'ları tek yerde oluşturur.
class AppDependencies {
  /// Testlerde sahte HTTP istemcisi ve bellek içi dosya depolaması verilebilir.
  AppDependencies(
    LocalStorageService storage, {
    http.Client? httpClient,
    DigitalFileStorage? digitalFiles,
    Duration sourceMinInterval = const Duration(milliseconds: 350),
    bool animateDecorations = true,
  }) : this._(
         storage,
         httpClient ?? http.Client(),
         digitalFiles ?? createPlatformDigitalFileStorage(),
         sourceMinInterval,
         animateDecorations,
       );

  AppDependencies._(
    LocalStorageService storage,
    http.Client client,
    DigitalFileStorage digitalFiles,
    Duration sourceMinInterval,
    this.animateDecorations,
  ) : bookSearchRepository = BookSearchRepository(client: client),
      digitalBookRepository = _digitalRepository(
        storage,
        client,
        digitalFiles,
        sourceMinInterval,
      ),
      authRepository = AuthRepository(storage),
      bookRepository = BookRepository(storage),
      quoteRepository = QuoteRepository(storage),
      noteRepository = NoteRepository(storage),
      goalRepository = GoalRepository(storage),
      settingsRepository = SettingsRepository(storage) {
    authController = AuthController(repository: authRepository);
    settingsController = SettingsController(repository: settingsRepository);
    libraryController = LibraryController(
      bookRepository: bookRepository,
      quoteRepository: quoteRepository,
      noteRepository: noteRepository,
      goalRepository: goalRepository,
    );
  }

  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final BookSearchRepository bookSearchRepository;
  final DigitalBookRepository digitalBookRepository;
  final QuoteRepository quoteRepository;
  final NoteRepository noteRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;

  /// Süs animasyonları açık mı (testlerde `pumpAndSettle` bitebilsin diye kapalı).
  final bool animateDecorations;
  late final AuthController authController;
  late final SettingsController settingsController;
  late final LibraryController libraryController;

  static DigitalBookRepository _digitalRepository(
    LocalStorageService storage,
    http.Client client,
    DigitalFileStorage files,
    Duration minInterval,
  ) {
    final sourceHttp = SourceHttp(client: client, minInterval: minInterval);
    return DigitalBookRepository(
      storage: storage,
      files: files,
      gutenberg: GutenbergSource(sourceHttp),
      wikisource: WikisourceSource(sourceHttp),
      loadAsset: rootBundle.loadString,
    );
  }

  Widget scope({required Widget child}) {
    return AppScope(
      authController: authController,
      libraryController: libraryController,
      settingsController: settingsController,
      authRepository: authRepository,
      bookRepository: bookRepository,
      bookSearchRepository: bookSearchRepository,
      digitalBookRepository: digitalBookRepository,
      quoteRepository: quoteRepository,
      noteRepository: noteRepository,
      goalRepository: goalRepository,
      settingsRepository: settingsRepository,
      animateDecorations: animateDecorations,
      child: child,
    );
  }
}
