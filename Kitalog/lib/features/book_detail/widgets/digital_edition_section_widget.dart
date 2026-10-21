import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../models/digital_edition_actions.dart';
import '../models/digital_edition_state.dart';
import 'digital_available_widget.dart';
import 'digital_import_widget.dart';
import 'section_card_widget.dart';

/// "Dijital Sürüm" bölümü: kitabın sürümü varsa indir/oku; yoksa (veya kullanıcının
/// dosyası cihazda kaybolmuşsa) kendi PDF / EPUB dosyasını yükleme.
class DigitalEditionSectionWidget extends StatelessWidget {
  const DigitalEditionSectionWidget({
    super.key,
    required this.book,
    required this.state,
    required this.actions,
    required this.onRead,
  });

  final BookModel book;
  final ValueListenable<DigitalEditionState> state;
  final DigitalEditionActions actions;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final edition = book.digitalEdition;
    return SectionCardWidget(
      title: context.l10n.digitalSectionTitle,
      child: ValueListenableBuilder<DigitalEditionState>(
        valueListenable: state,
        builder: (context, value, _) =>
            edition == null || (edition.isLocalFile && !value.isDownloaded && !value.isBusy)
            ? DigitalImportWidget(state: value, actions: actions)
            : DigitalAvailableWidget(
                edition: edition,
                state: value,
                actions: actions,
                onRead: onRead,
              ),
      ),
    );
  }
}
