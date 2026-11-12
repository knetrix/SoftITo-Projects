import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/notification_bell.dart';
import '../../core/widgets/option_tile.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import 'chats_tab.dart';
import 'friends_tab.dart';

/// 08 Sohbet ve Arkadaşlar (§3): segment Arkadaş Ekle | Sohbet.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key, this.tab});

  /// 'friends' | 'chats' (rota sorgusu).
  final String? tab;

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  late int _i = widget.tab == 'chats' ? 1 : 0;

  @override
  void didUpdateWidget(SocialScreen old) {
    super.didUpdateWidget(old);
    if (widget.tab != old.tab && widget.tab != null) {
      _i = widget.tab == 'chats' ? 1 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ColoredBox(
      color: context.c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: l.tabSocial, actions: const [NotificationBell()]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: AppSegment(
              labels: [l.soFriends, l.soChats],
              index: _i,
              onChanged: (i) => setState(() => _i = i),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _i,
              children: [
                const FriendsTab(),
                ChatsTab(onFindFriends: () => setState(() => _i = 0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
