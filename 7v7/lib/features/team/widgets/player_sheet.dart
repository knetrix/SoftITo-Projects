import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/formation.dart';
import '../../../core/utils/l10n_keys.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bib.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/invite_model.dart';
import '../../../services/draft_service.dart';
import '../../../services/firebase_providers.dart';
import '../../../services/invite_service.dart';
import '../../../services/user_service.dart';
import '../team_actions.dart';

/// Panel `player` (§3 ekran 04): mevkiye dokununca. Davet bekleyen mevkide
/// form yerine bekleme metni + "Daveti geri çek".
Future<void> showPlayerSheet(BuildContext context, String slot) {
  return showAppSheet<void>(context, builder: (_) => _PlayerSheet(slot: slot));
}

class _PlayerSheet extends ConsumerStatefulWidget {
  const _PlayerSheet({required this.slot});
  final String slot;

  @override
  ConsumerState<_PlayerSheet> createState() => _PlayerSheetState();
}

class _PlayerSheetState extends ConsumerState<_PlayerSheet> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  String? _err;

  @override
  void initState() {
    super.initState();
    final p = ref.read(draftProvider).players[widget.slot];
    _first = TextEditingController(text: p?.firstName ?? '');
    _last = TextEditingController(text: p?.lastName ?? '');
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  void _save() {
    final l = AppLocalizations.of(context);
    final d = ref.read(draftProvider);
    final first = squish(_first.text), last = squish(_last.text);
    if (first.isEmpty) {
      setState(() => _err = l.ePfirst);
      return;
    }
    final actions = ref.read(teamActionsProvider);
    final clash = actions.clashOf(widget.slot, first, last);
    if (clash != null) {
      setState(() => _err = l.eDup(d.players[clash]!.fullName, posName(l, d.formation, clash)));
      return;
    }
    final existed = d.players.containsKey(widget.slot);
    actions.savePlayer(widget.slot, first, last);
    Navigator.of(context).pop();
    final full = last.isEmpty ? first : '$first $last';
    AppToast.show(existed
        ? l.playerUpdated(full)
        : l.playerSaved(first, posName(l, d.formation, widget.slot)));
  }

  void _remove() {
    final l = AppLocalizations.of(context);
    final actions = ref.read(teamActionsProvider);
    final p = actions.removePlayer(widget.slot);
    Navigator.of(context).pop();
    if (p != null) {
      AppToast.show(l.playerRemoved(p.firstName),
          actionLabel: l.undo, onAction: () => actions.restorePlayer(p));
    }
  }

  Future<void> _withdraw(InviteModel v, String name) async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(inviteServiceProvider);
    final uid = ref.read(uidProvider)!;
    Navigator.of(context).pop();
    await svc.withdraw(v);
    AppToast.show(l.invWithdrawn(name), actionLabel: l.undo, onAction: () {
      svc.send(
        senderId: uid,
        receiverId: v.receiverId,
        draft: ref.read(draftProvider),
        offeredSlot: v.offeredSlot,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final d = ref.watch(draftProvider);
    final f = d.formation;
    final s = slotInfo(f, widget.slot);
    final n = bibNumber(f, widget.slot);
    final pos = posName(l, f, widget.slot);
    final reserved = ref.watch(reservedSlotsProvider)[widget.slot];
    final ru = reserved == null ? null : ref.watch(usersByIdProvider)[reserved.receiverId];

    Widget head(BibKind kind) => Row(
          children: [
            Bib(kind: kind, number: '$n'),
            const SizedBox(width: 12),
            Expanded(child: Text(pos, style: AppTextStyles.titleSm(color: c.ink))),
          ],
        );

    if (reserved != null) {
      final name = ru?.fullName ?? '';
      return SheetBody(children: [
        head(BibKind.line),
        Text(l.waitText(name), style: AppTextStyles.bodySm(400, color: c.ink2)),
        AppButton(
          label: l.withdraw,
          icon: PhosphorIconsFill.x,
          variant: AppButtonVariant.danger,
          wide: true,
          onPressed: () => _withdraw(reserved, name),
        ),
        AppButton(
          label: l.cancel,
          variant: AppButtonVariant.alt,
          wide: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ]);
    }

    final has = d.players.containsKey(widget.slot);
    return SheetBody(children: [
      head(s.line == Line.gk ? BibKind.gk : BibKind.team),
      AppTextField(
        label: l.fFirst,
        controller: _first,
        error: _err,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onChanged: (_) => _err == null ? null : setState(() => _err = null),
      ),
      const SizedBox(height: 6),
      AppTextField(
        label: l.fLastOpt,
        controller: _last,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) => _err == null ? null : setState(() => _err = null),
      ),
      const SizedBox(height: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(label: l.ppSave, wide: true, onPressed: _save),
          if (has) ...[
            const SizedBox(height: 8),
            AppButton(
              label: l.ppRemove,
              icon: PhosphorIconsFill.trash,
              variant: AppButtonVariant.danger,
              wide: true,
              onPressed: _remove,
            ),
          ],
          const SizedBox(height: 8),
          AppButton(
            label: l.cancel,
            variant: AppButtonVariant.alt,
            wide: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ]);
  }
}
