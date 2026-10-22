import 'package:flutter/widgets.dart';

import '../controllers/auth_controller.dart';
import '../controllers/library_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/settings_controller.dart';
import '../repositories/auth_repository.dart';
import '../repositories/book_repository.dart';
import '../repositories/book_search_repository.dart';
import '../repositories/digital_book_repository.dart';
import '../repositories/goal_repository.dart';
import '../repositories/note_repository.dart';
import '../repositories/quote_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/translation_repository.dart';

/// Uygulama geneli paylaşılan controller ve repository'ler.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.authController,
    required this.libraryController,
    required this.settingsController,
    required this.notificationController,
    required this.authRepository,
    required this.bookRepository,
    required this.bookSearchRepository,
    required this.digitalBookRepository,
    required this.translationRepository,
    required this.quoteRepository,
    required this.noteRepository,
    required this.goalRepository,
    required this.settingsRepository,
    this.animateDecorations = true,
    required super.child,
  });

  final AuthController authController;
  final LibraryController libraryController;
  final SettingsController settingsController;

  /// Bildirim motoru, dokunulan bildirim ve iade / okuma hatırlatmalarının planlayıcıları.
  final NotificationController notificationController;
  final AuthRepository authRepository;
  final BookRepository bookRepository;
  final BookSearchRepository bookSearchRepository;
  final DigitalBookRepository digitalBookRepository;
  final TranslationRepository translationRepository;
  final QuoteRepository quoteRepository;
  final NoteRepository noteRepository;
  final GoalRepository goalRepository;
  final SettingsRepository settingsRepository;

  /// Süs animasyonları (ör. giriş arka planı); testlerde kapatılır.
  final bool animateDecorations;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ağaçta bulunamadı.');
    return scope!;
  }

  // Controller referansları sabit; değişiklikler ValueNotifier ile yayılır.
  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
