import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formation.dart';
import '../../../core/utils/l10n_keys.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_icons.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bib.dart';
import '../../../core/widgets/option_tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/draft_model.dart';
import '../../../models/user_model.dart';
import '../../../services/draft_service.dart';
import '../../../services/firebase_providers.dart';
import '../../../services/invite_service.dart';
import '../../team/team_actions.dart';

/// Teklif edilebilen mevkiler (§5.4): boş ve bekleyen davetle tutulmamış;
/// sıra Kaleci, Defans, Orta Saha, Hücum.
List<Slot> openSlotsOf(DraftModel d, Set<String> reserved) => [
      for (final s in slotsOf(d.formation))
        if (!d.players.containsKey(s.id) && !reserved.contains(s.id)) s,
    ];

/// Taslak davet göndermeye hazır mı (diziliş, il, ilçe, saha, saat)?
bool draftReady(DraftModel d) =>
    d.formation != null &&
    d.city != null &&
    d.district != null &&
    d.stadium != null &&
    d.matchTime != null;

/// Panel `invite` (§3 ekran 08): İstek yolla / Maça davet et.
Future<void> showInviteSheet(BuildContext context, UserModel user) =>
    showAppSheet<void>(context, builder: (_) => _InviteSheet(user: user));

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.user});
  final UserModel user;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  String? _slot;
  bool _busy = false;

  Future<void> _send(DraftModel d, String slot) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = AppLocalizations.of(context);
    final svc = ref.read(inviteServiceProvider);
    final me = ref.read(uidProvider)!;
    final u = widget.user;
    try {
      await ref.read(draftProvider.notifier).flush();
      final id = await svc.send(
        senderId: me,
        receiverId: u.uid,
        draft: d,
        offeredSlot: slot,
      );
      if (mounted) Navigator.of(context).pop();
      AppToast.show(
        l.invSent(u.fullName, posName(l, d.formation, slot)),
        actionLabel: l.undo,
        onAction: () => svc.withdrawById(id, senderId: me, receiverId: u.uid),
      );
    } catch (_) {
      if (mounted) setState(() => _busy = false);
      AppToast.show(l.eGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final d = ref.watch(draftProvider);
    final reserved = ref.watch(reservedSlotsProvider).keys.toSet();
    final u = widget.user;
    final ready = draftReady(d);
    final open = d.formation == null ? const <Slot>[] : openSlotsOf(d, reserved);

    final head = Row(
      children: [
        BibAvatar(initials: u.initials, goalkeeper: u.isGk),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(l.invTitle(u.fullName), style: AppTextStyles.titleSm(color: c.ink)),
          ),
        ),
      ],
    );
    final cancel = AppButton(
      label: l.cancel,
      variant: AppButtonVariant.alt,
      wide: true,
      onPressed: () => Navigator.of(context).pop(),
    );

    if (!ready || open.isEmpty) {
      return SheetBody(children: [
        head,
        Text(ready ? l.invFull : l.invNeedMatch,
            style: AppTextStyles.bodySm(400, color: c.ink2)),
        AppButton(
          label: l.goTeam,
          icon: PhosphorIconsFill.usersThree,
          wide: true,
          onPressed: () {
            Navigator.of(context).pop();
            context.go('/team');
          },
        ),
        cancel,
      ]);
    }

    final sel = open.any((s) => s.id == _slot) ? _slot! : open.first.id;
    return SheetBody(children: [
      head,
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d.stadium!, style: AppTextStyles.body(800, color: c.ink)),
            const SizedBox(height: 2),
            Text('${d.district}, ${d.city}', style: AppTextStyles.bodySm(400, color: c.ink2)),
            const SizedBox(height: 2),
            Text('${timeRange(d.matchTime!)}, ${l.detForm} ${d.formation}',
                style: AppTextStyles.bodySm(400, color: c.ink2, tabular: true)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(l.invOfferPick, style: AppTextStyles.body(800, color: c.ink)),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, s) in open.indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            OptionTile(
              selected: sel == s.id,
              leading: Bib(
                kind: s.line == Line.gk ? BibKind.gk : BibKind.line,
                number: '${bibNumber(d.formation, s.id)}',
              ),
              title: posName(l, d.formation, s.id),
              onTap: () => setState(() => _slot = s.id),
            ),
          ],
        ],
      ),
      AppButton(
        label: l.invSend,
        icon: PhosphorIconsFill.paperPlaneRight,
        wide: true,
        onPressed: _busy ? null : () => _send(d, sel),
      ),
      cancel,
    ]);
  }
}
