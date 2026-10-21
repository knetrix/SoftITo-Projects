import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/models/book_search_result.dart';
import '../models/add_book_model.dart';
import 'add_book_mode_selector_widget.dart';
import 'manual_book_form_widget.dart';
import 'search_section_widget.dart';

/// Mod seçici + (arama | manuel form) gövdesi.
class AddBookBodyWidget extends StatelessWidget {
  const AddBookBodyWidget({
    super.key,
    required this.state,
    required this.onModeChanged,
    required this.onSearch,
    required this.onRetry,
    required this.onSelect,
    required this.onSave,
  });

  final AddBookModel state;
  final ValueChanged<AddBookMode> onModeChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onRetry;
  final ValueChanged<BookSearchResult> onSelect;
  final ValueChanged<BookDraft> onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spaceS),
        AddBookModeSelectorWidget(mode: state.mode, onChanged: onModeChanged),
        Expanded(
          child: state.mode == AddBookMode.search
              ? SearchSectionWidget(
                  state: state,
                  onSearch: onSearch,
                  onRetry: onRetry,
                  onSelect: onSelect,
                  onManual: () => onModeChanged(AddBookMode.manual),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: AppSizes.spaceL),
                  child: ManualBookFormWidget(
                    key: ValueKey(state.prefillVersion),
                    initial: state.prefill,
                    onSubmit: onSave,
                  ),
                ),
        ),
      ],
    );
  }
}
