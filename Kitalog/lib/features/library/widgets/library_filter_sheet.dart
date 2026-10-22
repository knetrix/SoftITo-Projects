import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/library_filter_actions.dart';
import '../models/library_shelf_model.dart';
import 'library_filter_options.dart';

/// Alttan açılan filtre paneli. Seçimler anında uygulanır (panel kapanmadan
/// sonuç sayısı güncellenir); her bölümde birden fazla seçenek seçilebilir.
class LibraryFilterSheet extends StatelessWidget {
  const LibraryFilterSheet({super.key, required this.state, required this.actions});

  final ValueListenable<LibraryShelfModel> state;
  final LibraryFilterActions actions;

  static Future<void> show(
    BuildContext context, {
    required ValueListenable<LibraryShelfModel> state,
    required LibraryFilterActions actions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => LibraryFilterSheet(state: state, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: ValueListenableBuilder<LibraryShelfModel>(
        valueListenable: state,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHeader(activeCount: value.activeFilterCount, onClear: actions.clear),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL),
                children: [
                  for (final group in libraryFilterGroups(context, value, actions)) _FilterSection(group: group),
                ],
              ),
            ),
            _ShowResultsButton(count: value.books.length),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.activeCount, required this.onClear});

  final int activeCount;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, 0, AppSizes.spaceS, AppSizes.spaceS),
      child: Row(
        children: [
          Expanded(child: Text(l10n.libraryFilters, style: context.textTheme.titleLarge)),
          TextButton(onPressed: activeCount > 0 ? onClear : null, child: Text(l10n.libraryFilterClear)),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.group});

  final LibraryFilterGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSizes.spaceS,
        children: [
          Text(group.title, style: context.textTheme.titleSmall),
          Wrap(
            spacing: AppSizes.spaceS,
            runSpacing: AppSizes.spaceS,
            children: [
              for (final option in group.options)
                FilterChip(
                  avatar: option.selected ? null : LibraryFilterLeading(option: option),
                  label: Text(option.label),
                  selected: option.selected,
                  onSelected: (_) => option.onToggle(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShowResultsButton extends StatelessWidget {
  const _ShowResultsButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceL),
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.libraryShowResults(count)),
      ),
    );
  }
}
