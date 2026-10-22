import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/view_status.dart';

/// Şifremi unuttum adımları: önce kimlik doğrulama, sonra yeni şifre.
enum ForgotPasswordStep {
  verify,
  newPassword;

  static ForgotPasswordStep fromName(String? name) =>
      values.firstWhere((e) => e.name == name, orElse: () => ForgotPasswordStep.verify);
}

/// Şifremi unuttum ekranının durumu. Doğrulanan e-posta / telefon yeni şifre
/// kaydedilirken yeniden doğrulamak için tutulur (yalnızca ekran açıkken).
@immutable
class ForgotPasswordModel {
  final ForgotPasswordStep step;
  final ViewStatus status;
  final AuthError? error;
  final String email;
  final String phone;

  const ForgotPasswordModel({
    this.step = ForgotPasswordStep.verify,
    this.status = ViewStatus.initial,
    this.error,
    this.email = '',
    this.phone = '',
  });

  bool get isLoading => status == ViewStatus.loading;

  /// Yeni şifre kaydedildi; ekran kapanıp girişe dönülür.
  bool get isDone => status == ViewStatus.success;

  ForgotPasswordModel copyWith({
    ForgotPasswordStep? step,
    ViewStatus? status,
    AuthError? error,
    bool clearError = false,
    String? email,
    String? phone,
  }) {
    return ForgotPasswordModel(
      step: step ?? this.step,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      step: ForgotPasswordStep.fromName(json['step'] as String?),
      email: json['email'] as String? ?? '',
    );
  }

  /// Telefon kimlik doğrulamada kullanıldığı için dışarı yazılmaz.
  Map<String, dynamic> toJson() {
    return {'step': step.name, 'email': email};
  }
}
