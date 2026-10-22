import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/validation_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/book_cover_image.dart';
import '../controllers/cover_picker.dart';

/// Kapak: önizleme + kapak URL'i veya cihazdan (galeri / kamera) seçilen resim.
/// Cihazdan resim seçiliyken URL alanı yerine bilgi satırı gösterilir.
class BookCoverFieldsWidget extends StatelessWidget {
  const BookCoverFieldsWidget({
    super.key,
    required this.cover,
    required this.title,
    required this.genre,
    this.custom,
    required this.deviceCover,
    required this.cameraAvailable,
    required this.onPick,
    required this.onRemove,
  });

  final TextEditingController cover;
  final TextEditingController title;
  final BookGenre genre;

  /// Seçili kullanıcı kategorisi; önizleme yer tutucusu onun renginde.
  final CustomGenreModel? custom;

  /// Cihazdan seçilen kapak (`data:` URI); yoksa `null`.
  final String? deviceCover;
  final bool cameraAvailable;
  final ValueChanged<CoverSource> onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSizes.spaceL,
      children: [
        _CoverPreview(cover: cover, title: title, genre: genre, custom: custom, deviceCover: deviceCover),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSizes.spaceS,
            children: [
              if (deviceCover == null) _CoverUrlField(cover: cover) else const _DeviceCoverNote(),
              _CoverButtons(
                hasDeviceCover: deviceCover != null,
                cameraAvailable: cameraAvailable,
                onPick: onPick,
                onRemove: onRemove,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverPreview extends StatelessWidget {
  const _CoverPreview({
    required this.cover,
    required this.title,
    required this.genre,
    required this.custom,
    required this.deviceCover,
  });

  final TextEditingController cover;
  final TextEditingController title;
  final BookGenre genre;
  final CustomGenreModel? custom;
  final String? deviceCover;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.shelfCoverWidth,
      child: AspectRatio(
        aspectRatio: AppSizes.coverAspectRatio,
        child: ListenableBuilder(
          listenable: Listenable.merge([cover, title]),
          builder: (context, _) => BookCoverImage(
            title: title.text.trim().isEmpty ? context.l10n.fieldBookCover : title.text.trim(),
            genre: genre,
            custom: custom,
            coverUrl: deviceCover ?? (Validators.optionalUrl(cover.text) == null ? cover.text.trim() : null),
          ),
        ),
      ),
    );
  }
}

class _CoverUrlField extends StatelessWidget {
  const _CoverUrlField({required this.cover});

  final TextEditingController cover;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextFormField(
      controller: cover,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(labelText: l10n.fieldBookCoverUrl),
      validator: (v) => Validators.optionalUrl(v)?.message(l10n),
    );
  }
}

class _DeviceCoverNote extends StatelessWidget {
  const _DeviceCoverNote();

  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.coverFromDeviceSelected, style: context.textTheme.bodyMedium);
  }
}

class _CoverButtons extends StatelessWidget {
  const _CoverButtons({
    required this.hasDeviceCover,
    required this.cameraAvailable,
    required this.onPick,
    required this.onRemove,
  });

  final bool hasDeviceCover;
  final bool cameraAvailable;
  final ValueChanged<CoverSource> onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSizes.spaceS,
      runSpacing: AppSizes.spaceXs,
      children: [
        OutlinedButton.icon(
          onPressed: () => onPick(CoverSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(l10n.coverFromGallery),
        ),
        if (cameraAvailable)
          OutlinedButton.icon(
            onPressed: () => onPick(CoverSource.camera),
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(l10n.coverFromCamera),
          ),
        if (hasDeviceCover)
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.coverRemove),
          ),
      ],
    );
  }
}
