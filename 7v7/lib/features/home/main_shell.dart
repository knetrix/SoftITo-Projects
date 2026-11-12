import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_tab_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../services/draft_service.dart';

/// 4 sekmeli alt menü kabuğu (Takım Kur, Randevularım, Profil, Sohbet).
/// Sekme durumları `StatefulShellRoute.indexedStack` ile korunur.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  Widget build(BuildContext context) {
    // Taslak denetleyicisini (ve kabul edilen davetleri taslağa işleyen
    // dinleyiciyi) oturum boyunca canlı tut.
    ref.watch(draftProvider);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.c.bg,
      body: widget.shell,
      bottomNavigationBar: AppTabBar(
        index: widget.shell.currentIndex,
        items: [
          TabItem(PhosphorIconsFill.usersThree, l.tabTeam),
          TabItem(PhosphorIconsFill.calendarCheck, l.tabAppts),
          TabItem(PhosphorIconsFill.userCircle, l.tabProfile),
          TabItem(PhosphorIconsFill.chatsCircle, l.tabSocial),
        ],
        onTap: (i) => widget.shell.goBranch(
          i,
          initialLocation: i == widget.shell.currentIndex,
        ),
      ),
    );
  }
}
