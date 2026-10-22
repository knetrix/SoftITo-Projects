import 'package:flutter/material.dart';

import '../../features/add_book/views/add_book_view.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/book_detail/views/book_detail_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home_shell/views/home_shell_view.dart';
import '../../features/library/views/library_view.dart';
import '../../features/loans/views/loans_view.dart';
import '../../features/reader/views/reader_view.dart';
import '../../features/reading_goal/views/reading_goal_view.dart';
import '../../features/reading_status/views/reading_status_view.dart';
import '../../features/settings/views/settings_view.dart';
import '../../features/splash/views/splash_view.dart';

/// Rota isimleri ve `onGenerateRoute`. Feature'lar birbirini import etmez;
/// sekme sayfaları ve geçişler yalnızca bu katmanda bağlanır.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String bookDetail = '/book';
  static const String addBook = '/add-book';
  static const String reader = '/reader';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    // Şifremi unuttum, tamamlanınca e-postayı girişe döndürür; rota bu yüzden
    // `String` sonuç taşıyacak türde üretilir (diğerleri sonuç döndürmez).
    if (routeSettings.name == forgotPassword) {
      return MaterialPageRoute<String>(settings: routeSettings, builder: (_) => const ForgotPasswordView());
    }
    final Widget page = switch (routeSettings.name) {
      register => const RegisterView(),
      login => const LoginView(),
      home => const HomeShellView(
        pages: [LibraryView(), ReadingStatusView(), LoansView(), ReadingGoalView()],
      ),
      bookDetail => BookDetailView(bookId: routeSettings.arguments as String),
      addBook => const AddBookView(),
      reader => ReaderView(bookId: routeSettings.arguments as String),
      settings => const SettingsView(),
      _ => const SplashView(),
    };
    return MaterialPageRoute<void>(settings: routeSettings, builder: (_) => page);
  }
}
