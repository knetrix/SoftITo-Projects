import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/match_widgets.dart';
import '../../core/widgets/pressable.dart';
import '../../l10n/app_localizations.dart';
import '../../models/invite_model.dart';
import '../../models/user_model.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/user_service.dart';
import 'widgets/invite_sheet.dart';

/// Kullanıcının profil mevkisi ('gk'|'def'|'mid'|'att') yerelleştirilmiş adı.
String profilePos(AppLocalizations l, String p) => switch (p) {
      'gk' => l.posGk,
      'def' => l.posDef,
      'mid' => l.posMid,
      'att' => l.posAtt,
      _ => '',
    };

/// Arkadaş Ekle sekmesi (§3 ekran 08).
class FriendsTab extends ConsumerStatefulWidget {
  const FriendsTab({super.key});

  @override
  ConsumerState<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends ConsumerState<FriendsTab> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final me = ref.watch(uidProvider);
    final users = ref.watch(allUsersProvider).value ?? const <UserModel>[];
    final byId = ref.watch(usersByIdProvider);
    final incoming = (ref.watch(incomingInvitesProvider).value ?? const <InviteModel>[])
        .where((v) => v.isPending)
        .toList();
    final q = trLower(_q.text.trim());
    final list = [
      for (final u in users)
        if (u.uid != me && (q.isEmpty || trLower(u.fullName).contains(q))) u,
    ]..sort((a, b) => a.uid.compareTo(b.uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: AppTextField(
            controller: _q,
            placeholder: l.userSearch,
            prefixIcon: PhosphorIconsFill.magnifyingGlass,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (incoming.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Semantics(
                      header: true,
                      child: Text(l.inInvites, style: AppTextStyles.body(800, color: c.ink)),
                    ),
                  ),
                  for (final v in incoming)
                    if (byId[v.senderId] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IncomingInviteCard(invite: v, sender: byId[v.senderId]!),
                      ),
                ],
                if (list.isEmpty)
                  EmptyState(
                    title: l.noUsers(_q.text.trim()),
                    actionLabel: l.clearSearch,
                    actionVariant: AppButtonVariant.alt,
                    onAction: () => setState(_q.clear),
                  )
                else
                  for (final u in list) _UserRow(user: u),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gelen davet kartı (`icard`).
class IncomingInviteCard extends StatelessWidget {
  const IncomingInviteCard({super.key, required this.invite, required this.sender});
  final InviteModel invite;
  final UserModel sender;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final v = invite;
    return Pressable(
      onTap: () => context.push('/invites/${v.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(20)),
        // Kontur yer kaplamaz (CSS inset box-shadow).
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.line, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: UserWho(
                user: sender,
                title: l.nInvite(sender.fullName),
                wrapName: true,
                nameStyle: AppTextStyles.body(800, color: c.ink),
                subWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.inInvLine(posName(l, v.formation, v.offeredSlot)),
                        style: AppTextStyles.bodySm(400, color: c.ink2)),
                    Text('${v.stadium}, ${v.matchTime}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm(400, color: c.ink2)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(PhosphorIconsFill.caretRight, size: 20, color: c.ink2),
          ],
        ),
      ),
    );
  }
}

/// Kullanıcı satırı (`urow`) ve eylemleri (§3 ekran 08, öncelik sırası).
class _UserRow extends ConsumerWidget {
  const _UserRow({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final u = user;
    final me = ref.watch(uidProvider);
    final friend = ref.watch(friendsProvider).value?.contains(u.uid) ?? false;
    final out = ref.watch(outgoingInvitesProvider).value ?? const <InviteModel>[];
    final pendingOut = out.where((v) => v.receiverId == u.uid && v.isPending).firstOrNull;
    final refused = out.any((v) => v.receiverId == u.uid && v.isRejected);
    final pendingIn = (ref.watch(incomingInvitesProvider).value ?? const <InviteModel>[])
        .where((v) => v.senderId == u.uid && v.isPending)
        .firstOrNull;

    final chat = AppButton(
      label: l.msgBtn,
      icon: PhosphorIconsFill.chatCircleDots,
      variant: AppButtonVariant.alt,
      small: true,
      semanticLabel: l.msgUser(u.fullName),
      onPressed: me == null ? null : () => context.push('/chats/${pairId(me, u.uid)}'),
    );

    final List<Widget> acts;
    if (pendingIn != null) {
      acts = [
        AppButton(
          label: l.invView,
          icon: PhosphorIconsFill.soccerBall,
          variant: AppButtonVariant.alt,
          small: true,
          onPressed: () => context.push('/invites/${pendingIn.id}'),
        ),
        if (friend) chat,
      ];
    } else if (pendingOut != null) {
      acts = [
        AppButton(
          label: friend ? l.invSentBtn : l.reqSentBtn,
          icon: PhosphorIconsFill.check,
          variant: AppButtonVariant.sent,
          small: true,
        ),
        Text(l.invOffered(posName(l, pendingOut.formation, pendingOut.offeredSlot)),
            style: AppTextStyles.bodySm(400, color: c.ink2)),
        if (friend) chat,
      ];
    } else if (friend) {
      acts = [
        AppButton(
          label: l.invFriend,
          icon: PhosphorIconsFill.soccerBall,
          variant: AppButtonVariant.alt,
          small: true,
          onPressed: () => showInviteSheet(context, u),
        ),
        chat,
      ];
    } else if (refused) {
      acts = [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsFill.x, size: 18, color: c.ink2),
              const SizedBox(width: 6),
              Text(l.invRefused, style: AppTextStyles.bodySm(400, color: c.ink2)),
            ],
          ),
        ),
      ];
    } else {
      acts = [
        AppButton(
          label: l.reqSend,
          icon: PhosphorIconsFill.userPlus,
          variant: AppButtonVariant.alt,
          small: true,
          onPressed: () => showInviteSheet(context, u),
        ),
      ];
    }

    final sub = [u.city, profilePos(l, u.position)].where((s) => s.isNotEmpty).join(', ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BibAvatar(initials: u.initials, goalkeeper: u.isGk),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body(800, color: c.ink)),
                    if (friend)
                      Row(
                        children: [
                          Icon(PhosphorIconsFill.checkCircle, size: 16, color: c.ok),
                          const SizedBox(width: 4),
                          Text(l.friendsYes, style: AppTextStyles.bodySm(700, color: c.ok)),
                        ],
                      )
                    else if (sub.isNotEmpty)
                      Text(sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm(400, color: c.ink2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: acts,
            ),
          ),
        ],
      ),
    );
  }
}
