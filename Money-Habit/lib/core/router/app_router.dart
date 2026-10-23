import 'package:flutter/material.dart';

import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/views/home_shell_view.dart';
import '../../features/settings/controllers/settings_controller.dart';
import '../../features/settings/views/settings_view.dart';
import '../services/local_storage_service.dart';

abstract final class AppRoutes {
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = '/settings';
}

class AppRouter {
  final LocalStorageService storage;
  final SettingsController settingsController;

  const AppRouter({
    required this.storage,
    required this.settingsController,
  });

  Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final Widget page = switch (routeSettings.name) {
      AppRoutes.register => RegisterView(storage: storage),
      AppRoutes.login => LoginView(storage: storage),
      AppRoutes.home => HomeShellView(
          storage: storage,
          settingsController: settingsController,
        ),
      AppRoutes.settings => SettingsView(
          storage: storage,
          settingsController: settingsController,
        ),
      _ => RegisterView(storage: storage),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: routeSettings);
  }
}
