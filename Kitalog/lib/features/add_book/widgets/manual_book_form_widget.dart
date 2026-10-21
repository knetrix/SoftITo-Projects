import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_genre.dart';
import '../../../core/models/book_search_result.dart';
import '../../../core/models/reading_status.dart';
import '../../../core/utils/isbn_utils.dart';
import '../models/add_book_model.dart';
import 'book_classification_fields_widget.dart';
import 'book_identity_fields_widget.dart';
import 'book_optional_fields_widget.dart';

/// Manuel kitap formu (başlık, yazar, sayfa sayısı, tür, kapak URL, durum).
/// Alan denetleyicileri ve seçili tür/durum yerel UI durumudur.
class ManualBookFormWidget extends StatefulWidget {
  const ManualBookFormWidget({
    super.key,
    required this.onSubmit,
    this.initial,
  });

  final BookSearchResult? initial;
  final ValueChanged<BookDraft> onSubmit;

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
  late BookGenre _genre;
  ReadingStatus _status = ReadingStatus.toRead;
  bool _isOwned = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _authors = TextEditingController(text: initial?.authors.join(', ') ?? '');
    _pages = TextEditingController(text: initial?.pageCount?.toString() ?? '');
    _isbn = TextEditingController(text: initial?.isbn ?? '');
    _cover = TextEditingController(text: initial?.coverUrl ?? '');
    _genre = initial?.genre ?? BookGenre.other;
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
        coverUrl: _cover.text.trim(),
        genre: _genre,
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
            status: _status,
            onGenreChanged: (value) => setState(() => _genre = value),
            onStatusChanged: (value) => setState(() => _status = value),
          ),
          const SizedBox(height: AppSizes.spaceL),
          BookOptionalFieldsWidget(
            isbn: _isbn,
            cover: _cover,
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
