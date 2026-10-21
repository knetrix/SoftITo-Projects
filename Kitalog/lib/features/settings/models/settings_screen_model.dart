import 'package:flutter/foundation.dart';

import '../../../core/models/view_status.dart';

/// Kullanıcıya gösterilecek tek seferlik bilgi mesajları (anahtar olarak).
enum SettingsMessage {
  emailSaved,
  phoneSaved,
  passwordSaved,
  avatarSaved,
  avatarFailed,
}

@immutable
class SettingsScreenModel {
  final ViewStatus status;
  final bool currentPasswordWrong;
  final SettingsMessage? message;

  const SettingsScreenModel({
    this.status = ViewStatus.initial,
    this.currentPasswordWrong = false,
    this.message,
  });

  bool get isBusy => status == ViewStatus.loading;

  SettingsScreenModel copyWith({
    ViewStatus? status,
    bool? currentPasswordWrong,
    SettingsMessage? message,
    bool clearMessage = false,
  }) {
    return SettingsScreenModel(
      status: status ?? this.status,
      currentPasswordWrong: currentPasswordWrong ?? this.currentPasswordWrong,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  factory SettingsScreenModel.fromJson(Map<String, dynamic> json) {
    return SettingsScreenModel(
      currentPasswordWrong: json['currentPasswordWrong'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'currentPasswordWrong': currentPasswordWrong};
  }
}
