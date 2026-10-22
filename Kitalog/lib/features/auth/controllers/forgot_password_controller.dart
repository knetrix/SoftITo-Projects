import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/view_status.dart';
import '../models/forgot_password_model.dart';

/// Şifremi unuttum akışı: kayıtlı e-posta + telefon doğrulanır, ardından yeni
/// şifre kaydedilir. Doğrulamanın nasıl yapıldığı `AuthController`'dadır.
class ForgotPasswordController {
  ForgotPasswordController({required this._auth});

  final AuthController _auth;
  final ValueNotifier<ForgotPasswordModel> state = ValueNotifier<ForgotPasswordModel>(
    const ForgotPasswordModel(),
  );

  Future<void> verify({required String email, required String phone}) async {
    if (state.value.isLoading) return;
    state.value = state.value.copyWith(status: ViewStatus.loading, clearError: true);
    final error = await _auth.verifyRecovery(email: email, phone: phone);
    state.value = error == null
        ? ForgotPasswordModel(step: ForgotPasswordStep.newPassword, email: email, phone: phone)
        : state.value.copyWith(status: ViewStatus.failure, error: error);
  }

  Future<void> resetPassword(String newPassword) async {
    final current = state.value;
    if (current.isLoading || current.step != ForgotPasswordStep.newPassword) return;
    state.value = current.copyWith(status: ViewStatus.loading, clearError: true);
    final error = await _auth.resetPassword(email: current.email, phone: current.phone, newPassword: newPassword);
    state.value = error == null
        ? current.copyWith(status: ViewStatus.success, clearError: true)
        : current.copyWith(status: ViewStatus.failure, error: error);
  }

  /// Yeni şifre adımından doğrulama adımına döner (bilgiler temizlenir).
  void backToVerify() {
    state.value = const ForgotPasswordModel();
  }

  void dispose() {
    state.dispose();
  }
}
