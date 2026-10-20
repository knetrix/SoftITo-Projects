import 'package:flutter/foundation.dart';

import '../../../core/utils/password_hasher.dart';
import '../../../core/utils/validators.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/profile_model.dart';

/// E-posta, telefon ve şifre değişiklikleri. Metotlar hata anahtarı döner
/// (`null` = başarılı).
class ProfileController {
  ProfileController(this._auth)
      : profile = ValueNotifier<ProfileModel>(
          ProfileModel.fromUser(_auth.user.value),
        ) {
    _auth.user.addListener(_sync);
  }

  final AuthController _auth;
  final ValueNotifier<ProfileModel> profile;

  void _sync() => profile.value = ProfileModel.fromUser(_auth.user.value);

  Future<String?> changeEmail(String newEmail) async {
    final error = Validators.email(newEmail);
    if (error != null) return error;
    final current = _auth.user.value;
    if (current == null) return 'err_login_failed';
    await _auth.updateUser(
      current.copyWith(email: newEmail.trim().toLowerCase()),
    );
    return null;
  }

  Future<String?> changePhone(String newPhone) async {
    final error = Validators.phone(newPhone);
    if (error != null) return error;
    final current = _auth.user.value;
    if (current == null) return 'err_login_failed';
    await _auth.updateUser(
      current.copyWith(phone: Validators.normalizePhone(newPhone)),
    );
    return null;
  }

  /// Eski şifre doğrulaması şarttır.
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final current = _auth.user.value;
    if (current == null) return 'err_login_failed';
    if (oldPassword.isEmpty) return 'err_password_required';
    if (!PasswordHasher.verify(oldPassword, current.salt, current.passwordHash)) {
      return 'err_old_password_wrong';
    }
    final error = Validators.password(newPassword) ??
        Validators.passwordConfirm(newPasswordConfirm, newPassword);
    if (error != null) return error;

    final salt = PasswordHasher.generateSalt();
    await _auth.updateUser(
      current.copyWith(
        salt: salt,
        passwordHash: PasswordHasher.hash(newPassword, salt),
      ),
    );
    return null;
  }

  void dispose() {
    _auth.user.removeListener(_sync);
    profile.dispose();
  }
}
