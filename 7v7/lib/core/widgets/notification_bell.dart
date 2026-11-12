import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';
import 'icon_circle_button.dart';

/// Ana sekme ekranlarının sağ üstündeki bildirim ikonu (44×44) + okunmamış rozeti.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final n = ref.watch(unreadCountProvider);
    return IconCircleButton(
      icon: PhosphorIconsFill.bell,
      semanticLabel: n > 0 ? '${l.notifBtn}, ${l.notifUnread('$n')}' : l.notifBtn,
      badge: n > 0 ? '$n' : null,
      onPressed: () => context.push('/notifications'),
    );
  }
}
