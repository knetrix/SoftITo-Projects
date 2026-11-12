import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formation.dart';
import '../../../core/utils/l10n_keys.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/option_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/draft_service.dart';
import '../team_actions.dart';

/// Panel `formation` (§3 ekran 04): 5 seçenek; mini saha + ad + açıklama.
Future<void> showFormationSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(builder: (ctx, ref, _) {
      final l = AppLocalizations.of(ctx);
      final cur = ref.watch(draftProvider).formation;
      String desc(Formation f) => [
            if (f.def > 0) l.fdD('${f.def}'),
            if (f.mid > 0) l.fdM('${f.mid}'),
            if (f.att > 0) l.fdA('${f.att}'),
          ].join(', ');
      return SheetBody(children: [
        SheetTitle(l.fpTitle, sub: l.fpSub),
        const SizedBox(height: 6),
        for (final f in Formation.all)
          OptionTile(
            selected: cur == f.id,
            leading: MiniFormation(formationId: f.id),
            titleWidget: Text(
              f.id,
              style: AppTextStyles.s(20, 900, height: 1.2, tabular: true,
                  color: cur == f.id ? ctx.c.onAccent : ctx.c.ink),
            ),
            subtitle: desc(f),
            onTap: () {
              Navigator.of(ctx).pop();
              final moved = ref.read(teamActionsProvider).setFormation(f.id);
              if (cur == f.id) return;
              if (moved.length == 1) {
                AppToast.show(l.movedOne(moved.first.$1, posName(l, f.id, moved.first.$2.id)));
              } else if (moved.length > 1) {
                AppToast.show(l.movedMany(moved
                    .map((m) => '${m.$1} (${posName(l, f.id, m.$2.id)})')
                    .join(', ')));
              } else {
                AppToast.show(l.formationSet(f.id));
              }
            },
          ),
      ]);
    }),
  );
}

/// Mini saha 40×52, köşe 8, 8 px noktalar (kaleci turuncu).
class MiniFormation extends StatelessWidget {
  const MiniFormation({super.key, required this.formationId});
  final String formationId;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 52,
        decoration: BoxDecoration(color: c.pitch, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            _dot(50, 88, AppColors.bibGk),
            for (final s in slotsOf(formationId).where((s) => s.line != Line.gk))
              () {
                final xy = slotXY(formationId, s);
                return _dot(xy.x, xy.y, AppColors.white);
              }(),
          ],
        ),
      ),
    );
  }

  Widget _dot(double x, double y, Color color) => Positioned(
        left: 40 * x / 100 - 4,
        top: 52 * y / 100 - 4,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      );
}
