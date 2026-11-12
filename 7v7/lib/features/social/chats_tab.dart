import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/pressable.dart';
import '../../l10n/app_localizations.dart';
import '../../services/chat_service.dart';
import '../../services/firebase_providers.dart';
import '../../services/user_service.dart';

/// Sohbet zamanı: bugünse SS:DD, dünse "Dün", değilse tarih.
String chatTime(BuildContext context, DateTime at) {
  final l = AppLocalizations.of(context);
  return chatClock(at, Localizations.localeOf(context).toLanguageTag()) ?? l.yesterday;
}

/// Sohbet sekmesi (§3 ekran 08).
class ChatsTab extends ConsumerWidget {
  const ChatsTab({super.key, required this.onFindFriends});
  final VoidCallback onFindFriends;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final me = ref.watch(uidProvider);
    final chats = ref.watch(myChatsProvider).value ?? const [];
    final users = ref.watch(usersByIdProvider);
    final rows = [
      for (final ch in chats)
        if (users[ch.otherOf(me ?? '')] != null) (ch, users[ch.otherOf(me ?? '')]!),
    ];
    if (rows.isEmpty) {
      return SingleChildScrollView(
        child: EmptyState(
          image: 'assets/images/empty_chats.jpg',
          imageLabel: l.imgEmptyChats,
          title: l.chatsEmptyT,
          description: l.chatsEmptyD,
          actionLabel: l.chatsEmptyBtn,
          actionIcon: PhosphorIconsFill.userPlus,
          onAction: onFindFriends,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        for (final (ch, u) in rows)
          Pressable(
            onTap: () => context.push('/chats/${ch.id}'),
            child: Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
              child: Row(
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
                        Text(
                          ch.lastText == null
                              ? l.chatFirst
                              : '${ch.lastSenderId == me ? '${l.you} ' : ''}${ch.lastText}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm(400, color: c.ink2),
                        ),
                      ],
                    ),
                  ),
                  if (ch.lastText != null) ...[
                    const SizedBox(width: 12),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chatTime(context, ch.lastAt ?? clockNow()),
                          style: AppTextStyles.label(400, color: c.ink2, tabular: true),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
