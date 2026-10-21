import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// ISBN veya başlık/yazar arama kutusu (metin denetleyicisinin sahibi).
class BookSearchBarWidget extends StatefulWidget {
  const BookSearchBarWidget({
    super.key,
    required this.isLoading,
    required this.onSearch,
  });

  final bool isLoading;
  final ValueChanged<String> onSearch;

  @override
  State<BookSearchBarWidget> createState() => _BookSearchBarWidgetState();
}

class _BookSearchBarWidgetState extends State<BookSearchBarWidget> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TextField(
      controller: _query,
      enabled: !widget.isLoading,
      textInputAction: TextInputAction.search,
      onSubmitted: widget.onSearch,
      decoration: InputDecoration(
        labelText: l10n.addBookSearchLabel,
        hintText: l10n.addBookSearchHint,
        prefixIcon: const Icon(Icons.travel_explore),
        suffixIcon: IconButton(
          tooltip: l10n.addBookSearchButton,
          icon: const Icon(Icons.search),
          onPressed: widget.isLoading ? null : () => widget.onSearch(_query.text),
        ),
      ),
    );
  }
}
