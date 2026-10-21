import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/controllers/library_controller.dart';
import '../../../core/models/view_status.dart';
import '../../../core/routing/app_routes.dart';
import '../models/splash_model.dart';

/// Açılışta örnek veriyi (ilk çalıştırmada) ve oturumu yükler, hedef rotayı belirler.
class SplashController {
  SplashController({
    required this._auth,
    required this._library,
    this.minDuration = const Duration(milliseconds: 700),
  });

  final AuthController _auth;
  final LibraryController _library;
  final Duration minDuration;

  final ValueNotifier<SplashModel> state = ValueNotifier<SplashModel>(
    const SplashModel(),
  );

  Future<void> start() async {
    state.value = const SplashModel(status: ViewStatus.loading);
    try {
      final results = await Future.wait<Object?>([
        _library.load(),
        _auth.restoreSession(),
        Future<void>.delayed(minDuration),
      ]);
      final loggedIn = results[1] as bool;
      state.value = SplashModel(
        status: ViewStatus.success,
        destination: loggedIn ? AppRoutes.home : AppRoutes.register,
      );
    } catch (_) {
      state.value = const SplashModel(status: ViewStatus.failure);
    }
  }

  void dispose() {
    state.dispose();
  }
}
