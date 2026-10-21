import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../controllers/auth_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_search_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/quote_repository.dart';
import '../repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';
import 'app_scope.dart';

/// Repository ve paylaşılan controller'ları tek yerde oluşturur.
class AppDependencies {
  AppDependencies(LocalStorageService storage, {http.Client? httpClient})
    : bookSearchRepository = BookSearchRepository(client: httpClient),
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
  final QuoteRepository quoteRepository;
  final NoteRepository noteRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;
  late final AuthController authController;
  late final SettingsController settingsController;
  late final LibraryController libraryController;

  Widget scope({required Widget child}) {
    return AppScope(
      authController: authController,
      libraryController: libraryController,
      settingsController: settingsController,
      authRepository: authRepository,
      bookRepository: bookRepository,
      bookSearchRepository: bookSearchRepository,
      quoteRepository: quoteRepository,
      noteRepository: noteRepository,
      goalRepository: goalRepository,
      settingsRepository: settingsRepository,
      child: child,
    );
  }
}
