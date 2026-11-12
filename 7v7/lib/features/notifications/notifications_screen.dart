import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/l10n_keys.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_link.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../models/appointment_model.dart';
import '../../models/chat_model.dart';
import '../../models/invite_model.dart';
import '../../models/notification_model.dart';
import '../../services/appointment_service.dart';
import '../../services/chat_service.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_service.dart';

/// 11 Bildirimler (§3): türüne göre ikon, başlık, alt satır ve hedef ekran.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final list = ref.watch(notificationsProvider).value ?? const <NotificationModel>[];
    final unread = list.where((n) => !n.isRead).map((n) => n.id).toList();
    final uid = ref.watch(uidProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(onBack: () => goBack(context, '/team'), title: l.noH),
          if (list.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.sampleNotifs, style: AppTextStyles.bodySm(400, color: c.ink2)),
                  ),
                  const SizedBox(width: 12),
                  Opacity(
                    opacity: unread.isEmpty ? .45 : 1,
                    child: AppLink(
                      text: l.markAll,
                      small: true,
                      onTap: unread.isEmpty || uid == null
                          ? null
                          : () async {
                              await ref
                                  .read(notificationServiceProvider)
                                  .markAllRead(uid, unread);
                              AppToast.show(l.allRead);
                            },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: list.isEmpty
                ? SingleChildScrollView(
                    child: EmptyState(
                      art: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: c.chip, shape: BoxShape.circle),
                        child: Icon(PhosphorIconsFill.bell, size: 22, color: c.ink),
                      ),
                      title: l.noEmptyT,
                      description: l.noEmptyD,
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.only(bottom: bottomInset(context)),
                    children: [for (final n in list) _NotifRow(n: n)],
                  ),
          ),
        ],
      ),
    );
  }
}

typedef _Meta = ({IconData icon, String title, String sub, VoidCallback onTap});

class _NotifRow extends ConsumerWidget {
  const _NotifRow({required this.n});
  final NotificationModel n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final m = _meta(context, ref, l);
    return Pressable(
      onTap: () {
        final uid = ref.read(uidProvider);
        if (uid != null && !n.isRead) {
          ref.read(notificationServiceProvider).markRead(uid, n.id);
        }
        m.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: c.chip, shape: BoxShape.circle),
              child: Icon(m.icon, size: 22, color: c.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title, style: AppTextStyles.body(n.isRead ? 500 : 800, color: c.ink)),
                  if (m.sub.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(m.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm(400, color: c.ink2)),
                  ],
                  if (n.createdAt != null) ...[
                    const SizedBox(height: 2),
                    Text(agoText(l, agoParts(n.createdAt!)),
                        // `.nt` satır yüksekliğini (1.4) devralır.
                        style: AppTextStyles.s(12, 400, color: c.ink2)),
                  ],
                ],
              ),
            ),
            if (!n.isRead) ...[
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: c.ink, borderRadius: BorderRadius.circular(10)),
                child: Text(l.newTag, style: AppTextStyles.label(800, color: c.bg)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _Meta _meta(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final users = ref.watch(usersByIdProvider);
    String name(String? uid) => users[uid]?.fullName ?? '';
    AppointmentModel? appt(String id) =>
        (ref.watch(myAppointmentsProvider).value ?? const <AppointmentModel>[])
            .where((a) => a.id == id)
            .firstOrNull;
    InviteModel? inv(List<InviteModel>? list) =>
        (list ?? const <InviteModel>[]).where((v) => v.id == n.relatedId).firstOrNull;
    void openAppt(AppointmentModel? a) =>
        a == null ? AppToast.show(l.apptGone) : context.push('/appointments/${a.id}');

    switch (n.type) {
      case NotificationType.invite:
        final v = inv(ref.watch(incomingInvitesProvider).value);
        if (v == null) {
          return (
            icon: PhosphorIconsFill.soccerBall,
            title: l.inviteGone,
            sub: '',
            onTap: () => AppToast.show(l.inviteGone),
          );
        }
        return (
          icon: PhosphorIconsFill.soccerBall,
          title: l.nInvite(name(v.senderId)),
          sub: l.nInviteSub(v.stadium, posName(l, v.formation, v.offeredSlot)),
          onTap: () => context.push('/invites/${v.id}'),
        );
      case NotificationType.inviteAccepted:
      case NotificationType.inviteRejected:
        final v = inv(ref.watch(outgoingInvitesProvider).value);
        final acc = n.type == NotificationType.inviteAccepted;
        final pos = v == null ? '' : posName(l, v.formation, v.offeredSlot);
        return (
          icon: acc ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.x,
          title: acc ? l.nInvAcc(name(v?.receiverId)) : l.nInvRej(name(v?.receiverId)),
          sub: acc ? l.nInvAccSub(pos) : l.nInvRejSub(pos),
          onTap: () => context.go('/team'),
        );
      case NotificationType.matchSaved:
        final a = appt(n.relatedId);
        return (
          icon: PhosphorIconsFill.calendarCheck,
          title: l.nSaved(name(a?.ownerId), a?.matchTime ?? ''),
          sub: a?.stadium ?? l.apptGone,
          onTap: () => openAppt(a),
        );
      case NotificationType.reminder:
        final a = appt(n.relatedId);
        return (
          icon: PhosphorIconsFill.clock,
          title: l.nReminder(a?.matchTime ?? ''),
          sub: a?.stadium ?? l.apptGone,
          onTap: () => openAppt(a),
        );
      case NotificationType.message:
        final me = ref.watch(uidProvider) ?? '';
        final ch = (ref.watch(myChatsProvider).value ?? const <ChatModel>[])
            .where((x) => x.id == n.relatedId)
            .firstOrNull;
        final other = n.relatedId.split('_').where((x) => x != me).firstOrNull;
        return (
          icon: PhosphorIconsFill.chatCircleDots,
          title: l.nMessage(name(other)),
          sub: ch?.lastText ?? '',
          onTap: () => context.push('/chats/${n.relatedId}'),
        );
    }
  }
}
