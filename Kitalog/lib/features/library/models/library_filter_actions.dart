import 'package:flutter/foundation.dart';

import '../../../core/models/genre_choice.dart';
import 'library_shelf_model.dart';

/// Filtre çubuğu ve panelinin controller'a doğrudan bağımlı olmadan çağırdığı eylemler.
class LibraryFilterActions {
  const LibraryFilterActions({
    required this.toggleFormat,
    required this.toggleGenre,
    required this.clear,
  });

  final void Function(BookFormatFilter format) toggleFormat;
  final void Function(GenreChoice genre) toggleGenre;
  final VoidCallback clear;
}
