import 'package:flutter/foundation.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../core/models/view_status.dart';
import '../models/auth_form_model.dart';

class RegisterController {
  RegisterController({required this._auth});

  final AuthController _auth;
  final ValueNotifier<AuthFormModel> state = ValueNotifier<AuthFormModel>(
    const AuthFormModel(),
  );

  Future<void> submit({
    required String email,
    required String phone,
    required String password,
  }) async {
    if (state.value.isLoading) return;
    state.value = const AuthFormModel(status: ViewStatus.loading);
    await _auth.register(email: email, phone: phone, password: password);
    state.value = const AuthFormModel(status: ViewStatus.success);
  }

  void dispose() {
    state.dispose();
  }
}
