import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/genre_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/models/custom_genre_model.dart';
import '../../../core/models/genre_choice.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/utils/cover_image_data.dart';
import '../../../core/utils/isbn_utils.dart';
import '../controllers/cover_picker.dart';
import '../models/add_book_model.dart';
import 'book_classification_fields_widget.dart';
import 'book_cover_fields_widget.dart';
import 'book_identity_fields_widget.dart';
import 'book_optional_fields_widget.dart';
import 'new_genre_dialog.dart';

/// Manuel kitap formu (başlık, yazar, sayfa sayısı, tür, kapak, durum). Kapak
/// URL ile ya da cihazdan (galeri / kamera) eklenir. Listede olmayan tür
/// "Yeni kategori ekle" ile hızlıca eklenip seçilir. Alan denetleyicileri,
/// seçili tür/durum ve seçilen kapak yerel UI durumudur.
class ManualBookFormWidget extends StatefulWidget {
  const ManualBookFormWidget({
    super.key,
    required this.onSubmit,
    required this.coverPicker,
    required this.customGenres,
    required this.onCreateGenre,
    this.initial,
  });

  final BookSearchResult? initial;
  final ValueChanged<BookDraft> onSubmit;
  final CoverPicker coverPicker;

  /// Kullanıcının eklediği kategoriler (paylaşılan liste).
  final ValueListenable<List<CustomGenreModel>> customGenres;
  final Future<CustomGenreModel> Function(NewGenreInput input) onCreateGenre;

  @override
  State<ManualBookFormWidget> createState() => _ManualBookFormWidgetState();
}

class _ManualBookFormWidgetState extends State<ManualBookFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _authors;
  late final TextEditingController _pages;
  late final TextEditingController _isbn;
  late final TextEditingController _cover;
  late GenreChoice _genre;
  ReadingStatus _status = ReadingStatus.toRead;
  bool _isOwned = true;

  /// Cihazdan seçilen kapak (`data:` URI); seçiliyken URL'in yerine geçer.
  String? _deviceCover;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _authors = TextEditingController(text: initial?.authors.join(', ') ?? '');
    _pages = TextEditingController(text: initial?.pageCount?.toString() ?? '');
    _isbn = TextEditingController(text: initial?.isbn ?? '');
    _cover = TextEditingController(text: initial?.coverUrl ?? '');
    _genre = (genre: initial?.genre ?? BookGenre.other, customGenreId: null);
  }

  @override
  void dispose() {
    _title.dispose();
    _authors.dispose();
    _pages.dispose();
    _isbn.dispose();
    _cover.dispose();
    super.dispose();
  }

  Future<void> _pickCover(CoverSource source) async {
    try {
      final bytes = await widget.coverPicker.pick(source);
      if (bytes == null || !mounted) return;
      setState(() => _deviceCover = CoverImageData.encode(bytes));
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.coverPickFailed)),
      );
    }
  }

  Future<void> _addGenre() async {
    final l10n = context.l10n;
    final customs = widget.customGenres.value;
    final input = await NewGenreDialog.show(
      context,
      takenNames: [for (final g in BookGenre.values) g.label(l10n), for (final c in customs) c.name],
      initialColor: CustomGenreModel.nextColorIndex(customs),
    );
    if (input == null) return;
    final created = await widget.onCreateGenre(input);
    if (!mounted) return;
    setState(() => _genre = (genre: BookGenre.other, customGenreId: created.id));
  }

  CustomGenreModel? get _selectedCustom {
    for (final c in widget.customGenres.value) {
      if (c.id == _genre.customGenreId) return c;
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isbn = IsbnUtils.normalize(_isbn.text);
    widget.onSubmit(
      BookDraft(
        title: _title.text.trim(),
        authors: _authors.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        pageCount: int.parse(_pages.text.trim()),
        isbn: isbn,
        coverUrl: _deviceCover ?? _cover.text.trim(),
        genre: _genre.genre,
        customGenreId: _genre.customGenreId,
        status: _status,
        isOwned: _isOwned,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceXl),
        children: [
          BookIdentityFieldsWidget(title: _title, authors: _authors, pages: _pages),
          const SizedBox(height: AppSizes.spaceL),
          BookClassificationFieldsWidget(
            genre: _genre,
            customGenres: widget.customGenres,
            status: _status,
            onGenreChanged: (value) => setState(() => _genre = value),
            onAddGenre: _addGenre,
            onStatusChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: AppSizes.spaceL),
          BookCoverFieldsWidget(
            cover: _cover,
            title: _title,
            genre: _genre.genre,
            custom: _selectedCustom,
            deviceCover: _deviceCover,
            cameraAvailable: widget.coverPicker.cameraAvailable,
            onPick: _pickCover,
            onRemove: () => setState(() => _deviceCover = null),
          ),
          const SizedBox(height: AppSizes.spaceL),
          BookOptionalFieldsWidget(
            isbn: _isbn,
            isOwned: _isOwned,
            onOwnedChanged: (value) => setState(() => _isOwned = value),
          ),
          const SizedBox(height: AppSizes.spaceM),
          FilledButton(onPressed: _submit, child: Text(context.l10n.addBookSave)),
        ],
      ),
    );
  }
}
