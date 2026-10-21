import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class HomeNavigationBarWidget extends StatelessWidget {
  const HomeNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.collections_bookmark_outlined),
          selectedIcon: const Icon(Icons.collections_bookmark),
          label: l10n.navLibrary,
        ),
        NavigationDestination(
          icon: const Icon(Icons.auto_stories_outlined),
          selectedIcon: const Icon(Icons.auto_stories),
          label: l10n.navReadingStatus,
        ),
        NavigationDestination(
          icon: const Icon(Icons.flag_outlined),
          selectedIcon: const Icon(Icons.flag),
          label: l10n.navGoal,
        ),
      ],
    );
  }
}
