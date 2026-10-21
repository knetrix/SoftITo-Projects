import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/home_shell_controller.dart';
import '../models/home_shell_model.dart';
import '../widgets/home_navigation_bar_widget.dart';

/// NavigationBar + sağ üst Ayarlar butonu. Sekme sayfaları rota katmanından
/// (`AppRoutes`) verilir; böylece feature'lar birbirinin view'ını import etmez.
class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key, required this.pages, this.initialIndex = 0});

  final List<Widget> pages;
  final int initialIndex;

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  late final HomeShellController _controller = HomeShellController(
    tabCount: widget.pages.length,
    initialIndex: widget.initialIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _title(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.libraryTitle,
      1 => l10n.readingStatusTitle,
      _ => l10n.readingGoalTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeShellModel>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_title(context, state.selectedIndex)),
            actions: [
              IconButton(
                tooltip: context.l10n.settingsTitle,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
            ],
          ),
          body: IndexedStack(
            index: state.selectedIndex,
            children: widget.pages,
          ),
          bottomNavigationBar: HomeNavigationBarWidget(
            selectedIndex: state.selectedIndex,
            onSelected: _controller.selectTab,
          ),
        );
      },
    );
  }
}
