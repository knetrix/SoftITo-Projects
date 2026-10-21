import 'package:flutter/foundation.dart';

import '../models/home_shell_model.dart';

class HomeShellController {
  HomeShellController({this.tabCount = 3, int initialIndex = 0})
    : state = ValueNotifier<HomeShellModel>(
        HomeShellModel(selectedIndex: initialIndex.clamp(0, tabCount - 1)),
      );

  final int tabCount;
  final ValueNotifier<HomeShellModel> state;

  void selectTab(int index) {
    if (index < 0 || index >= tabCount) return;
    state.value = state.value.copyWith(selectedIndex: index);
  }

  void dispose() {
    state.dispose();
  }
}
