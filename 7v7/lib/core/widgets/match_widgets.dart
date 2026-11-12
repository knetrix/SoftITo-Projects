import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/player_model.dart';
import '../../models/user_model.dart';
import '../utils/formation.dart';
import '../utils/l10n_keys.dart';
import 'bib.dart';
import 'pitch.dart';

/// Saha adı (28/900, wdth 112) + "ilçe, il" (`hero`).
class MatchHero extends StatelessWidget {
  const MatchHero({
    super.key,
    required this.stadium,
    required this.district,
    required this.city,
    this.top = 0,
  });

  final String stadium;
  final String district;
  final String city;
  final double top;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(stadium,
                style: AppTextStyles.s(28, 900, width: 112, height: 1.15, color: c.ink)),
          ),
          const SizedBox(height: 2),
          Text('$district, $city', style: AppTextStyles.bodySm(400, color: c.ink2)),
        ],
      ),
    );
  }
}

/// 3 bilgi kutusu (`facts`): Saat, Süre, Diziliş.
class MatchFacts extends StatelessWidget {
  const MatchFacts({super.key, required this.time, required this.formation});
  final String time;
  final String formation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Expanded(child: _Fact(l.detTime, time)),
          const SizedBox(width: 8),
          Expanded(child: _Fact(l.detDur, l.oneHour)),
          const SizedBox(width: 8),
          Expanded(child: _Fact(l.detForm, formation)),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
      // Kontur yer kaplamaz (CSS inset box-shadow).
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.line, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.s(12, 600, color: c.ink2)),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s(16, 800, color: c.ink, tabular: true)),
        ],
      ),
    );
  }
}

/// Kadro satırı (`rrow`): yelek 30×33 + ad (16/700) + mevki (14 `ink2`).
class RosterRow extends StatelessWidget {
  const RosterRow({
    super.key,
    required this.number,
    required this.kind,
    required this.name,
    required this.position,
    this.open = false,
  });

  final int number;
  final BibKind kind;
  final String name;
  final String position;

  /// Boş mevki: ad `ink2` 600.
  final bool open;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          Bib(kind: kind, number: '$number', width: 30, height: 33),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: open
                  ? AppTextStyles.body(600, color: c.ink2)
                  : AppTextStyles.body(700, color: c.ink),
            ),
          ),
          const SizedBox(width: 12),
          Text(position, style: AppTextStyles.bodySm(400, color: c.ink2)),
        ],
      ),
    );
  }
}

/// "Kadro" başlığı (`roster h2`).
class RosterTitle extends StatelessWidget {
  const RosterTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        header: true,
        child: Text(AppLocalizations.of(context).squad,
            style: AppTextStyles.body(800, color: c.ink)),
      ),
    );
  }
}

/// Salt-okunur saha mevkileri: dolu mevkide oyuncunun adı, [offerSlot]
/// "Senin yerin", diğer boşlar mevki adı.
List<PitchSlot> readOnlySlots(
  AppLocalizations l,
  String formation,
  List<PlayerModel> players, {
  String? offerSlot,
}) {
  final pm = PlayerModel.mapFrom(players);
  return [
    for (final (i, s) in slotsOf(formation).indexed)
      () {
        final p = pm[s.id];
        final pos = posName(l, formation, s.id);
        if (p != null) {
          return PitchSlot(
            slot: s,
            number: i + 1,
            state: SlotState.filled,
            label: p.firstName,
            semanticLabel: '${p.fullName}, $pos',
          );
        }
        if (s.id == offerSlot) {
          return PitchSlot(
            slot: s,
            number: i + 1,
            state: SlotState.offer,
            label: l.offerYou,
            semanticLabel: '$pos, ${l.offerYou}',
          );
        }
        return PitchSlot(
          slot: s,
          number: i + 1,
          state: SlotState.empty,
          label: pos,
          semanticLabel: '$pos, ${l.emptySlot}',
        );
      }(),
  ];
}

/// Kullanıcı satırı başı: avatar + ad (16/800) + alt satır (14 `ink2`).
class UserWho extends StatelessWidget {
  const UserWho({
    super.key,
    required this.user,
    this.sub,
    this.subWidget,
    this.nameStyle,
    this.wrapName = false,
    this.title,
  });

  final UserModel user;

  /// Ad yerine gösterilecek başlık (ör. "{ad} seni maçına davet etti").
  final String? title;
  final String? sub;
  final Widget? subWidget;
  final TextStyle? nameStyle;
  final bool wrapName;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      children: [
        BibAvatar(initials: user.initials, goalkeeper: user.isGk),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? user.fullName,
                maxLines: wrapName ? null : 1,
                overflow: wrapName ? null : TextOverflow.ellipsis,
                style: nameStyle ?? AppTextStyles.body(800, color: c.ink),
              ),
              if (subWidget != null)
                subWidget!
              else if (sub != null)
                Text(sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm(400, color: c.ink2)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Saha dışı boş yelekler (`lineBibs`): ilki kaleci, diğerleri kesikli.
class LineBibs extends StatelessWidget {
  const LineBibs(this.n, {super.key});
  final int n;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < n; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Bib(kind: i == 0 ? BibKind.gk : BibKind.line, number: '${i + 1}'),
          ],
        ],
      ),
    );
  }
}
