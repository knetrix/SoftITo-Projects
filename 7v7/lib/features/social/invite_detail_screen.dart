import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/formation.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/match_widgets.dart';
import '../../core/widgets/pitch.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../models/invite_model.dart';
import '../../models/notification_model.dart';
import '../../models/player_model.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';

/// 10 Maç daveti (§3, §5.4): alıcı kabul eder / reddeder (onaylı);
/// gönderen durum satırını görür.
class InviteDetailScreen extends ConsumerStatefulWidget {
  const InviteDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<InviteDetailScreen> createState() => _InviteDetailScreenState();
}

class _InviteDetailScreenState extends ConsumerState<InviteDetailScreen> {
  bool _busy = false;

  Future<void> _respond(InviteModel v, bool accept) async {
    final l = AppLocalizations.of(context);
    final me = ref.read(currentUserProvider).value;
    if (me == null || _busy) return;
    if (!accept) {
      final ok = await showConfirmSheet(
        context,
        title: l.invRejQ,
        body: l.invRejD,
        yes: l.invRejYes,
        no: l.cancel,
      );
      if (!ok) return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(inviteServiceProvider).respond(inviteId: v.id, accept: accept, me: me);
      ref
          .read(notificationServiceProvider)
          .markRead(me.uid, NotificationModel.inviteId(v.id))
          .catchError((_) {});
      final sender = ref.read(usersByIdProvider)[v.senderId];
      AppToast.show(accept
          ? l.invAcceptedT(posName(l, v.formation, v.offeredSlot))
          : l.invRejectedT(sender?.fullName ?? ''));
    } catch (_) {
      AppToast.show(l.eGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final async = ref.watch(inviteProvider(widget.id));
    final me = ref.watch(uidProvider);
    final users = ref.watch(usersByIdProvider);
    void back() => goBack(context, '/social');

    if (async.isLoading && !async.hasValue) {
      return Scaffold(backgroundColor: c.bg, body: ScreenHeader(onBack: back, title: l.invH));
    }
    final v = async.hasError ? null : async.value;
    final mine = v != null && v.receiverId == me;
    final u = v == null ? null : users[mine ? v.senderId : v.receiverId];
    if (v == null || u == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            ScreenHeader(onBack: back),
            Expanded(
              child: SingleChildScrollView(
                child: EmptyState(
                  art: const LineBibs(1),
                  title: l.invNoneT,
                  description: l.invNoneD,
                  actionLabel: l.back,
                  onAction: back,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final f = v.formation;
    final slots = slotsOf(f);
    final s = slotInfo(f, v.offeredSlot);
    final pos = posName(l, f, v.offeredSlot);
    final pm = PlayerModel.mapFrom(v.players);
    final done = v.isAccepted;

    Widget status(IconData icon, String text, {bool ok = true}) {
      final color = ok ? c.ok : c.ink2;
      return Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.bodySm(700, color: color))),
        ],
      );
    }

    final List<Widget> dock;
    if (!mine) {
      dock = [
        switch (v.status) {
          InviteStatus.accepted => status(
              PhosphorIconsFill.checkCircle, l.invSenderAccepted(u.firstName, pos)),
          InviteStatus.rejected =>
            status(PhosphorIconsFill.x, l.invSenderRejected(u.firstName), ok: false),
          InviteStatus.pending =>
            status(PhosphorIconsFill.clock, l.invSenderPending(u.firstName), ok: false),
        },
      ];
    } else if (v.isPending) {
      dock = [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: l.invReject,
                icon: PhosphorIconsFill.x,
                variant: AppButtonVariant.danger,
                wide: true,
                onPressed: _busy ? null : () => _respond(v, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                label: l.invAccept,
                icon: PhosphorIconsFill.check,
                wide: true,
                onPressed: _busy ? null : () => _respond(v, true),
              ),
            ),
          ],
        ),
      ];
    } else if (done) {
      dock = [
        status(PhosphorIconsFill.checkCircle, l.invStatusAcc(u.firstName)),
        AppButton(
          label: l.invChat(u.firstName),
          icon: PhosphorIconsFill.chatCircleDots,
          wide: true,
          onPressed: () => context.push('/chats/${pairId(me!, u.uid)}'),
        ),
      ];
    } else {
      dock = [status(PhosphorIconsFill.x, l.invStatusRej(u.firstName), ok: false)];
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(onBack: back, title: l.invH),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: UserWho(user: u, sub: mine ? l.invFrom : l.invTo),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20)),
                    // Kontur yer kaplamaz (CSS inset box-shadow).
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.ink, width: 2),
                    ),
                    child: Row(
                      children: [
                        Bib(
                          kind: s.line == Line.gk
                              ? BibKind.gk
                              : done
                                  ? BibKind.team
                                  : BibKind.line,
                          number: '${bibNumber(f, v.offeredSlot)}',
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(done ? l.invOfferDone : l.invOfferLabel,
                                  style: AppTextStyles.s(12, 600, color: c.ink2)),
                              Text(pos, style: AppTextStyles.titleSm(color: c.ink)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  MatchHero(stadium: v.stadium, district: v.district, city: v.city, top: 16),
                  MatchFacts(time: v.matchTime, formation: f),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PitchView(
                      formationId: f,
                      slots: readOnlySlots(l, f, v.players,
                          offerSlot: v.isPending ? v.offeredSlot : null),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const RosterTitle(),
                        for (final (i, x) in slots.indexed)
                          () {
                            final p = pm[x.id];
                            return RosterRow(
                              number: i + 1,
                              kind: p == null
                                  ? BibKind.line
                                  : x.line == Line.gk
                                      ? BibKind.gk
                                      : BibKind.team,
                              name: p?.fullName ??
                                  (x.id == v.offeredSlot && v.isPending ? l.offerRow : l.emptySlot),
                              open: p == null,
                              position: posName(l, f, x.id),
                            );
                          }(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (i, w) in dock.indexed) ...[
                  if (i > 0) const SizedBox(height: 8),
                  w,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
