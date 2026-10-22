import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/view_status.dart';
import '../models/auth_form_model.dart';

class LoginController {
  LoginController({required this._auth});

  final AuthController _auth;
  final ValueNotifier<AuthFormModel> state = ValueNotifier<AuthFormModel>(
    const AuthFormModel(),
  );

  Future<void> submit({required String email, required String password}) async {
    if (state.value.isLoading) return;
    state.value = AuthFormModel(status: ViewStatus.loading, prefillEmail: state.value.prefillEmail);
    final error = await _auth.login(email: email, password: password);
    state.value = error == null
        ? const AuthFormModel(status: ViewStatus.success)
        : AuthFormModel(status: ViewStatus.failure, error: error, prefillEmail: state.value.prefillEmail);
  }

  /// Şifre sıfırlandıktan sonra girişe dönüldü: önceki hata temizlenir,
  /// e-posta alanı doldurulur.
  void passwordWasReset(String email) {
    state.value = AuthFormModel(prefillEmail: email);
  }

  void dispose() {
    state.dispose();
  }
}
