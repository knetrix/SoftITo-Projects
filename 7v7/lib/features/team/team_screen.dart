import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/formation.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/notification_bell.dart';
import '../../core/widgets/picker_tile.dart';
import '../../core/widgets/pitch.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../services/draft_service.dart';
import '../../services/user_service.dart';
import 'team_actions.dart';
import 'widgets/location_sheets.dart';
import 'widgets/formation_sheet.dart';
import 'widgets/missing_bar.dart';
import 'widgets/player_sheet.dart';

/// 04 Takım Kur (§3): konum + saat seçicileri, saha (kalan alanı doldurur,
/// 340–420), sabit alt bar (eksik satırı + Diziliş + yeşil tik).
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final d = ref.watch(draftProvider);
    final tried = ref.watch(teamTriedProvider);
    final reserved = ref.watch(reservedSlotsProvider);
    final users = ref.watch(usersByIdProvider);
    final slots = slotsOf(d.formation);
    final filled = slots.where((s) => d.players.containsKey(s.id)).length;
    final miss = tried ? missingOf(d) : const <({String key, int n})>[];

    String squad = l.squadN('$filled');
    if (reserved.isNotEmpty) squad += ', ${l.nWaiting('${reserved.length}')}';

    final pitchSlots = [
      for (final (i, s) in slots.indexed)
        () {
          final p = d.players[s.id];
          final r = reserved[s.id];
          final ru = r == null ? null : users[r.receiverId];
          final pos = posName(l, d.formation, s.id);
          if (p != null) {
            return PitchSlot(
              slot: s,
              number: i + 1,
              state: SlotState.filled,
              label: p.firstName,
              semanticLabel: l.editPlayer(p.fullName, pos),
            );
          }
          if (r != null) {
            return PitchSlot(
              slot: s,
              number: i + 1,
              state: SlotState.waiting,
              label: l.waiting(ru?.firstName ?? ''),
              semanticLabel: l.slotWaiting(ru?.fullName ?? '', pos),
            );
          }
          return PitchSlot(
            slot: s,
            number: i + 1,
            state: SlotState.empty,
            label: pos,
            semanticLabel: l.addPlayerTo(pos),
          );
        }(),
    ];

    Future<void> save() async {
      final id = await ref.read(teamActionsProvider).save();
      if (id == null || !context.mounted) return;
      AppToast.show(l.savedAppt);
      context.push('/appointments/$id');
    }

    return ColoredBox(
      color: c.bg,
      child: Column(
        children: [
          ScreenHeader(title: l.scrTeam, actions: const [NotificationBell()]),
          Expanded(
            child: LayoutBuilder(builder: (context, box) {
              // Saha kalan alanı doldurur (340–420); üst blok yüksekliği:
              // seçiciler 56 + 10 + geniş seçici 56 + 10 + başlık (2 + 16×1.4) + 10.
              final ts = MediaQuery.textScalerOf(context);
              final pick = (16 + ts.scale(12) * 1.3 + 2 + ts.scale(14) * 1.4).clamp(56.0, double.infinity);
              final top = pick + 10 + pick + 10 + 2 + ts.scale(16) * 1.4 + 10;
              final pitchH = (box.maxHeight - top - 8).clamp(340.0, 420.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PickerTile(
                            label: l.locCity,
                            value: d.city,
                            placeholder: l.pick,
                            requiredText: l.required,
                            error: tried && d.city == null,
                            onTap: () => showCitySheet(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PickerTile(
                            label: l.locDistrict,
                            value: d.district,
                            placeholder: l.pick,
                            requiredText: l.required,
                            error: tried && d.district == null,
                            onTap: () => showDistrictSheet(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PickerTile(
                            label: l.locStadium,
                            value: d.stadium,
                            placeholder: l.pick,
                            requiredText: l.required,
                            error: tried && d.stadium == null,
                            onTap: () => showStadiumSheet(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    WidePickerTile(
                      icon: PhosphorIconsFill.clock,
                      label: l.matchTime,
                      value: d.matchTime == null ? null : timeRange(d.matchTime!),
                      placeholder: l.pick,
                      requiredText: l.required,
                      trailing: l.oneHour,
                      error: tried && d.matchTime == null,
                      onTap: () => showTimeSheet(context),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SectionHeader(l.squad, trailing: squad),
                    ),
                    const SizedBox(height: 10),
                    PitchView(
                      formationId: d.formation,
                      height: pitchH,
                      slots: pitchSlots,
                      onTap: (slot) => showPlayerSheet(context, slot),
                      overlay: d.formation != null
                          ? null
                          : _PitchEmpty(
                              text: l.pickFormationFirst,
                              button: l.formationNone,
                              onTap: () => showFormationSheet(context),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (miss.isNotEmpty) ...[
                  MissingBar(
                    text: '${l.missing} ${miss.map((m) => switch (m.key) {
                          'mFormation' => l.mFormation,
                          'mPlayers' => l.mPlayers('${m.n}'),
                          'mCity' => l.mCity,
                          'mDistrict' => l.mDistrict,
                          'mStadium' => l.mStadium,
                          _ => l.mTime,
                        }).join(', ')}',
                  ),
                  const SizedBox(height: 8),
                ],
                _DockRow(
                  formationLabel: d.formation == null ? l.formationNone : l.formationBtn(d.formation!),
                  saveLabel: l.saveTeam,
                  onFormation: () => showFormationSheet(context),
                  onSave: save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Saha içinde diziliş yokken (`pitch-empty`).
class _PitchEmpty extends StatelessWidget {
  const _PitchEmpty({required this.text, required this.button, required this.onTap});
  final String text;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.slotLabelOff,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(600, color: AppColors.white),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: button,
            icon: PhosphorIconsFill.strategy,
            variant: AppButtonVariant.alt,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

/// Alt bar: ince yatay Diziliş butonu (48, flex) + yeşil tik (48, flex).
/// CSS'teki gibi ikisi eşit paylaşır; Diziliş butonu içeriğinden dar olamaz.
class _DockRow extends StatelessWidget {
  const _DockRow({
    required this.formationLabel,
    required this.saveLabel,
    required this.onFormation,
    required this.onSave,
  });

  final String formationLabel;
  final String saveLabel;
  final VoidCallback onFormation;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final tp = TextPainter(
        text: TextSpan(text: formationLabel, style: AppTextStyles.button()),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      final minAlt = (24 + 20 + 8 + tp.width + 24).ceilToDouble() + 1;
      final half = (box.maxWidth - 8) / 2;
      final altW = minAlt > half ? minAlt.clamp(0.0, box.maxWidth - 8 - 56) : half;
      return Row(
        children: [
          SizedBox(
            width: altW,
            child: AppButton(
              label: formationLabel,
              icon: PhosphorIconsFill.strategy,
              variant: AppButtonVariant.alt,
              height: 48,
              wide: true,
              onPressed: onFormation,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppButton(
              label: '',
              height: 48,
              wide: true,
              onPressed: onSave,
              semanticLabel: saveLabel,
              iconOnly: PhosphorIconsFill.check,
            ),
          ),
        ],
      );
    });
  }
}
