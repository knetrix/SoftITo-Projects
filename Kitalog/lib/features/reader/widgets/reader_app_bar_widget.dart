import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../models/reader_translation_model.dart';
import 'reader_translate_menu_widget.dart';

/// Okuyucunun üst çubuğu: kitap adı, çeviri menüsü ve yazı boyutu. PDF kendi
/// sayfa düzeniyle (yakınlaştırarak) okunur; yazı boyutu ve sayfa çevirisi
/// yalnızca metinde (PDF'te seçilen metin çevrilir).
class ReaderAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const ReaderAppBarWidget({
    super.key,
    required this.title,
    required this.isPdf,
    required this.translation,
    required this.onTranslationView,
    required this.onTextSize,
  });

  final String title;
  final bool isPdf;
  final ValueListenable<ReaderTranslationModel> translation;
  final ValueChanged<TranslationView> onTranslationView;
  final VoidCallback onTextSize;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (!isPdf) ReaderTranslateMenuWidget(translation: translation, onSelected: onTranslationView),
        if (!isPdf)
          IconButton(
            tooltip: context.l10n.readerTextSize,
            icon: const Icon(Icons.format_size),
            onPressed: onTextSize,
          ),
      ],
    );
  }
}
