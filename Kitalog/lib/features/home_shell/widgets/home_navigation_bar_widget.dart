import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class HomeNavigationBarWidget extends StatelessWidget {
  const HomeNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.overdueLoanCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// İade günü geçmiş ödünç sayısı; sıfırdan büyükse Ödünç sekmesinde rozet çıkar.
  final int overdueLoanCount;

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
          icon: _LoanIcon(icon: Icons.handshake_outlined, overdue: overdueLoanCount),
          selectedIcon: _LoanIcon(icon: Icons.handshake, overdue: overdueLoanCount),
          label: l10n.navLoans,
          tooltip: overdueLoanCount > 0 ? l10n.navLoansOverdue(overdueLoanCount) : null,
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

class _LoanIcon extends StatelessWidget {
  const _LoanIcon({required this.icon, required this.overdue});

  final IconData icon;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: overdue,
      isLabelVisible: overdue > 0,
      backgroundColor: context.colors.error,
      textColor: context.colors.onError,
      child: Icon(icon),
    );
  }
}
