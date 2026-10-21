import 'dart:typed_data';

import 'package:kitalog/features/settings/controllers/avatar_picker.dart';

/// Galeri/kamera yerine sabit baytlar döndüren (veya hata fırlatan) sahte seçici.
class FakeAvatarPicker implements AvatarPicker {
  FakeAvatarPicker({this.bytes, this.shouldThrow = false, this.camera = true});

  final Uint8List? bytes;
  final bool shouldThrow;
  final bool camera;
  AvatarSource? lastSource;

  @override
  bool get cameraAvailable => camera;

  @override
  Future<Uint8List?> pick(AvatarSource source) async {
    lastSource = source;
    if (shouldThrow) throw Exception('picker failed');
    return bytes;
  }
}
