import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/formation.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/icon_circle_button.dart';
import '../../core/widgets/match_widgets.dart';
import '../../core/widgets/pitch.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../models/draft_model.dart';
import '../../models/invite_model.dart';
import '../../models/player_model.dart';
import '../../services/appointment_service.dart';
import '../../services/draft_service.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/user_service.dart';
import '../team/team_actions.dart';

/// 06 Randevu ayrıntısı (§3): sahibi siler / kadroyu aktarır; davetli
/// organizatörle sohbet eder.
class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final async = ref.watch(appointmentProvider(id));
    final uid = ref.watch(uidProvider);
    void back() => goBack(context, '/appointments');

    if (async.isLoading && !async.hasValue) {
      return Scaffold(backgroundColor: c.bg, body: ScreenHeader(onBack: back));
    }
    final a = async.hasError ? null : async.value;
    if (a == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            ScreenHeader(onBack: back),
            Expanded(
              child: SingleChildScrollView(
                child: EmptyState(
                  art: const LineBibs(1),
                  title: l.detNoneT,
                  description: l.detNoneD,
                  actionLabel: l.detNoneBtn,
                  onAction: () => context.go('/appointments'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final owner = a.ownerId == uid;
    final host = owner ? null : ref.watch(usersByIdProvider)[a.ownerId];
    final pm = PlayerModel.mapFrom(a.players);
    final slots = slotsOf(a.formation);

    Future<void> delete() async {
      final linked = (ref.read(outgoingInvitesProvider).value ?? const <InviteModel>[])
          .where((v) => v.appointmentId == a.id)
          .toList();
      final svc = ref.read(appointmentServiceProvider);
      context.go('/appointments');
      await svc.delete(a, linked);
      AppToast.show(l.deletedAppt(a.stadium),
          actionLabel: l.undo, onAction: () => svc.restore(a, linked));
    }

    void reuse() {
      final ctl = ref.read(draftProvider.notifier);
      final before = ref.read(draftProvider);
      ctl.update(DraftModel(
        formation: a.formation,
        city: a.city,
        district: a.district,
        stadium: a.stadium,
        players: pm,
      ));
      ref.read(teamTriedProvider.notifier).set(false);
      context.go('/team');
      AppToast.show(l.reused, actionLabel: l.undo, onAction: () => ctl.update(before));
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(
            onBack: back,
            actions: [
              if (owner)
                IconCircleButton(
                  icon: PhosphorIconsFill.trash,
                  semanticLabel: l.delAppt,
                  variant: IconButtonVariant.danger,
                  onPressed: delete,
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (a.imageAsset != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: Semantics(
                        image: true,
                        label: l.imgPitch,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(a.imageAsset!, height: 168, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  MatchHero(stadium: a.stadium, district: a.district, city: a.city),
                  if (host != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: UserWho(user: host, sub: l.organizer),
                    ),
                  MatchFacts(time: a.matchTime, formation: a.formation),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PitchView(
                      formationId: a.formation,
                      slots: readOnlySlots(l, a.formation, a.players),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const RosterTitle(),
                        for (final (i, s) in slots.indexed)
                          if (pm[s.id] != null)
                            RosterRow(
                              number: i + 1,
                              kind: s.line == Line.gk ? BibKind.gk : BibKind.team,
                              name: pm[s.id]!.fullName,
                              position: posName(l, a.formation, s.id),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset(context)),
            child: host != null
                ? AppButton(
                    label: l.invChat(host.firstName),
                    icon: PhosphorIconsFill.chatCircleDots,
                    wide: true,
                    onPressed: () => context.push('/chats/${pairId(uid!, host.uid)}'),
                  )
                : owner
                    ? AppButton(
                        label: l.reuseBtn,
                        icon: PhosphorIconsFill.usersThree,
                        wide: true,
                        onPressed: reuse,
                      )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
