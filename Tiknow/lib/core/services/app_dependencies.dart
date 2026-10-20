import '../../features/active_rentals/controllers/active_rentals_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'settings_controller.dart';
import 'storage_service.dart';

/// Uygulama geneli tekil controller'lar. `main.dart` oluşturur ve sahibidir;
/// constructor ile aşağı verilir (InheritedWidget/Provider yok).
class AppDependencies {
  AppDependencies._({
    required this.storage,
    required this.settings,
    required this.auth,
    required this.activeRentals,
  });

  factory AppDependencies.create(StorageService storage) {
    return AppDependencies._(
      storage: storage,
      settings: SettingsController(storage),
      auth: AuthController(storage),
      activeRentals: ActiveRentalsController(storage),
    );
  }

  final StorageService storage;
  final SettingsController settings;
  final AuthController auth;
  final ActiveRentalsController activeRentals;

  void dispose() {
    settings.dispose();
    auth.dispose();
    activeRentals.dispose();
  }
}
