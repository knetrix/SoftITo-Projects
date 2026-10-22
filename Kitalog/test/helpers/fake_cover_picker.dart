import 'dart:convert';
import 'dart:typed_data';

import 'package:kitalog/features/add_book/controllers/cover_picker.dart';

/// 1×1 piksellik gerçek PNG (Image.memory çözebilsin diye).
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFBQIAX8jx0gAAAABJRU5ErkJggg==',
);

/// Galeri / kamera yerine sabit resim döndüren sahte kapak seçici.
class FakeCoverPicker implements CoverPicker {
  FakeCoverPicker({this.bytes, this.shouldThrow = false, this.camera = true});

  final Uint8List? bytes;
  bool shouldThrow;
  final bool camera;
  CoverSource? lastSource;

  @override
  bool get cameraAvailable => camera;

  @override
  Future<Uint8List?> pick(CoverSource source) async {
    lastSource = source;
    if (shouldThrow) throw Exception('picker failed');
    return bytes;
  }
}
