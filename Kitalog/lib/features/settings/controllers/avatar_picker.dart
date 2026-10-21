import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum AvatarSource { gallery, camera }

/// Profil resmi seçimi. Testte sahte bir uygulama verilebilir.
abstract class AvatarPicker {
  /// Seçilen (küçültülmüş) resmin baytları; vazgeçilirse `null`.
  Future<Uint8List?> pick(AvatarSource source);

  /// Kamera yalnızca mobil platformlarda sunulur.
  bool get cameraAvailable;
}

class ImagePickerAvatarPicker implements AvatarPicker {
  ImagePickerAvatarPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const double maxSide = 512;
  static const int quality = 85;

  final ImagePicker _picker;

  @override
  bool get cameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<Uint8List?> pick(AvatarSource source) async {
    final file = await _picker.pickImage(
      source: source == AvatarSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
    );
    return file?.readAsBytes();
  }
}
