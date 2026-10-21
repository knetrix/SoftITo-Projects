import 'package:flutter/widgets.dart';

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

/// Uygulama geneli paylaşılan controller ve repository'ler.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.authController,
    required this.libraryController,
    required this.settingsController,
    required this.authRepository,
    required this.bookRepository,
    required this.bookSearchRepository,
    required this.quoteRepository,
    required this.noteRepository,
    required this.goalRepository,
    required this.settingsRepository,
    required super.child,
  });

  final AuthController authController;
  final LibraryController libraryController;
  final SettingsController settingsController;
  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final BookSearchRepository bookSearchRepository;
  final QuoteRepository quoteRepository;
  final NoteRepository noteRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ağaçta bulunamadı.');
    return scope!;
  }

  // Controller referansları sabit; değişiklikler ValueNotifier ile yayılır.
  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
