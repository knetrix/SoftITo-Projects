import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class TabItem {
  const TabItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Alt menü (§2.9): `card` zemin, üstte 1 px `line`; 4 sekme (ikon + 12 px etiket);
/// seçili: 56×30 vurgu hapı + `ink` 800 etiket. İç boşluk 6/8/alt güvenli alan.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<TabItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        border: Border(top: BorderSide(color: c.line, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(8, 6, 8, bottom),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _tab(c, i)),
          ],
        ],
      ),
    );
  }

  Widget _tab(AppColors c, int i) {
    final sel = i == index;
    return Semantics(
      button: true,
      selected: sel,
      label: items[i].label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(i),
        child: ExcludeSemantics(
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 56,
                  height: 30,
                  decoration: BoxDecoration(
                    color: sel ? c.accent : c.accent.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(items[i].icon,
                      size: 22, color: sel ? c.onAccent : c.ink2),
                ),
                const SizedBox(height: 4),
                Text(
                  items[i].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.s(12, sel ? 800 : 600,
                      height: 1.3, color: sel ? c.ink : c.ink2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
