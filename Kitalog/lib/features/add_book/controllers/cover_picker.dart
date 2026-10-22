import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum CoverSource { gallery, camera }

/// Kitap kapağı resmi seçimi. Testte sahte bir uygulama verilebilir.
abstract class CoverPicker {
  /// Seçilen (küçültülmüş) resmin baytları; vazgeçilirse `null`.
  Future<Uint8List?> pick(CoverSource source);

  /// Kamera yalnızca mobil platformlarda sunulur.
  bool get cameraAvailable;
}

class ImagePickerCoverPicker implements CoverPicker {
  ImagePickerCoverPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Kapak 2:3 oranlıdır; raf ve detay görünümü için bu boyut yeterlidir ve
  /// base64 saklanan resmi küçük tutar.
  static const double maxWidth = 600;
  static const double maxHeight = 900;
  static const int quality = 80;

  final ImagePicker _picker;

  @override
  bool get cameraAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<Uint8List?> pick(CoverSource source) async {
    final file = await _picker.pickImage(
      source: source == CoverSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: quality,
    );
    return file?.readAsBytes();
  }
}
