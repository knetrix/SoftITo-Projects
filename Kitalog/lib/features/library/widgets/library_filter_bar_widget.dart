import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../models/library_filter_actions.dart';
import '../models/library_shelf_model.dart';
import 'library_filter_options.dart';
import 'library_filter_sheet.dart';

/// Arama kutusu + sağında filtre düğmesi (seçili filtre sayısı rozetiyle).
/// Filtre seçiliyse altında tek dokunuşla kaldırılabilen çipler gösterilir.
class LibraryFilterBarWidget extends StatefulWidget {
  const LibraryFilterBarWidget({
    super.key,
    required this.state,
    required this.onQueryChanged,
    required this.actions,
  });

  final ValueListenable<LibraryShelfModel> state;
  final ValueChanged<String> onQueryChanged;
  final LibraryFilterActions actions;

  @override
  State<LibraryFilterBarWidget> createState() => _LibraryFilterBarWidgetState();
}

class _LibraryFilterBarWidgetState extends State<LibraryFilterBarWidget> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state.value;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.spaceL, AppSizes.spaceS, AppSizes.spaceL, AppSizes.spaceS),
          child: Row(
            spacing: AppSizes.spaceS,
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: widget.onQueryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: context.l10n.librarySearchHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              _FilterButton(
                activeCount: state.activeFilterCount,
                onPressed: () => LibraryFilterSheet.show(context, state: widget.state, actions: widget.actions),
              ),
            ],
          ),
        ),
        if (state.activeFilterCount > 0) _ActiveFilters(state: state, actions: widget.actions),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Varsayılan kırmızı rozet hata gibi algılanır; uygulamanın vurgu rengi kullanılır.
    return Badge.count(
      count: activeCount,
      isLabelVisible: activeCount > 0,
      backgroundColor: context.colors.primary,
      textColor: context.colors.onPrimary,
      child: IconButton.filledTonal(
        tooltip: activeCount > 0 ? l10n.libraryFiltersActive(activeCount) : l10n.libraryFilters,
        onPressed: onPressed,
        // Arama kutusuyla aynı yükseklik ve köşe yarıçapı.
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSizes.searchFieldHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusM)),
        ),
        icon: const Icon(Icons.tune),
      ),
    );
  }
}

/// Seçili filtreler: her biri silme düğmesiyle kaldırılır, sonda "Temizle".
class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.state, required this.actions});

  final LibraryShelfModel state;
  final LibraryFilterActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = [
      for (final group in libraryFilterGroups(context, state, actions))
        ...group.options.where((o) => o.selected),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL),
        children: [
          for (final option in selected)
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spaceS),
              child: Center(
                child: InputChip(
                  avatar: LibraryFilterLeading(option: option),
                  label: Text(option.label),
                  onDeleted: option.onToggle,
                  deleteButtonTooltipMessage: l10n.libraryFilterRemove,
                ),
              ),
            ),
          Center(child: TextButton(onPressed: actions.clear, child: Text(l10n.libraryFilterClear))),
        ],
      ),
    );
  }
}
