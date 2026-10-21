import 'package:flutter/material.dart';

import '../../features/add_book/views/add_book_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/book_detail/views/book_detail_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home_shell/views/home_shell_view.dart';
import '../../features/library/views/library_view.dart';
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
  static const String home = '/home';
  static const String settings = '/settings';
  static const String bookDetail = '/book';
  static const String addBook = '/add-book';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final Widget page = switch (routeSettings.name) {
      register => const RegisterView(),
      login => const LoginView(),
      home => const HomeShellView(
        pages: [LibraryView(), ReadingStatusView(), ReadingGoalView()],
      ),
      bookDetail => BookDetailView(bookId: routeSettings.arguments as String),
      addBook => const AddBookView(),
      settings => const SettingsView(),
      _ => const SplashView(),
    };
    return MaterialPageRoute<void>(settings: routeSettings, builder: (_) => page);
  }
}
