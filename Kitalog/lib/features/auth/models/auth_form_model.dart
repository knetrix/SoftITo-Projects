import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/view_status.dart';

@immutable
class AuthFormModel {
  final ViewStatus status;
  final AuthError? error;

  /// Giriş formunda önceden doldurulacak e-posta (ör. şifre sıfırlandıktan sonra).
  final String? prefillEmail;

  const AuthFormModel({this.status = ViewStatus.initial, this.error, this.prefillEmail});

  bool get isLoading => status == ViewStatus.loading;
  bool get isSuccess => status == ViewStatus.success;

  AuthFormModel copyWith({
    ViewStatus? status,
    AuthError? error,
    bool clearError = false,
    String? prefillEmail,
  }) {
    return AuthFormModel(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      prefillEmail: prefillEmail ?? this.prefillEmail,
    );
  }

  factory AuthFormModel.fromJson(Map<String, dynamic> json) {
    return AuthFormModel(
      status: ViewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ViewStatus.initial,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status.name};
  }
}
