import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'bib.dart';

/// Logo: 34×38 yelek + "7v7" (20/900/wdth 125, çevrilmez).
/// [pill]: Karşılama ekranındaki koyu yeşil hap içinde beyaz yelek.
class Brand extends StatelessWidget {
  const Brand({super.key, this.pill = false});
  final bool pill;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = pill ? AppColors.white : c.ink;
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Bib(
          kind: BibKind.team,
          width: 34,
          height: 38,
          fill: pill ? AppColors.white : c.team,
        ),
        SizedBox(width: pill ? 8 : 10),
        Text('7v7', style: AppTextStyles.s(20, 900, width: 125, height: 1.4, color: color)),
      ],
    );
    return Semantics(
      label: '7v7',
      excludeSemantics: true,
      child: pill
          ? Container(
              padding: const EdgeInsets.fromLTRB(6, 4, 14, 4),
              decoration: BoxDecoration(
                color: AppColors.kitGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: row,
            )
          : row,
    );
  }
}
