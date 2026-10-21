import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../constants/storage_keys.dart';
import '../models/user_model.dart';
import '../storage/local_storage_service.dart';

class AuthRepository {
  const AuthRepository(this._storage);

  final LocalStorageService _storage;

  /// Şifre düz metin saklanmaz; SHA-256 özeti (hex) saklanır.
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<UserModel?> getUser() async {
    final json = _storage.readJsonMap(StorageKeys.user);
    return json == null ? null : UserModel.fromJson(json);
  }

  Future<void> saveUser(UserModel user) {
    return _storage.writeJsonMap(StorageKeys.user, user.toJson());
  }

  Future<bool> isSessionActive() async {
    return _storage.readBool(StorageKeys.session);
  }

  Future<void> setSessionActive(bool active) {
    return _storage.writeBool(StorageKeys.session, active);
  }
}
