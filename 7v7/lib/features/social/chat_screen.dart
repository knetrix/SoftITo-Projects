import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/icon_circle_button.dart';
import '../../core/widgets/match_widgets.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../services/firebase_providers.dart';
import '../../services/invite_service.dart';
import '../../services/user_service.dart';
import 'chats_tab.dart';

/// 09 Mesajlaşma (§3): yalnızca arkadaşlar arasında (§5.6).
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.chatId});
  final String chatId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msg = TextEditingController();
  bool _err = false;

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _send(String me, String other) async {
    final text = _msg.text.trim();
    if (text.isEmpty) {
      setState(() => _err = true);
      return;
    }
    _msg.clear();
    setState(() => _err = false);
    await ref.read(chatServiceProvider).send(me: me, other: other, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final me = ref.watch(uidProvider);
    final ids = widget.chatId.split('_');
    final otherId = me != null && ids.length == 2 && ids.contains(me)
        ? ids.firstWhere((x) => x != me, orElse: () => '')
        : '';
    final friends = ref.watch(friendsProvider).value;
    final other = ref.watch(usersByIdProvider)[otherId];
    void back() => goBack(context, '/social?tab=chats');

    if (friends == null || (other == null && ref.watch(allUsersProvider).isLoading)) {
      return Scaffold(backgroundColor: c.bg, body: ScreenHeader(onBack: back));
    }
    if (other == null || !friends.contains(otherId)) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Column(
          children: [
            ScreenHeader(onBack: back),
            Expanded(
              child: SingleChildScrollView(
                child: EmptyState(
                  art: const LineBibs(2),
                  title: l.chatNoneT,
                  description: l.chatNoneD,
                  actionLabel: l.chatNoneBtn,
                  onAction: back,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final msgs = ref.watch(messagesProvider(widget.chatId)).value ?? const <MessageModel>[];
    return Scaffold(
      backgroundColor: c.bg,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChatTop(user: other, onBack: back),
          Expanded(
            child: msgs.isEmpty
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(l.chatFirst,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm(400, color: c.ink2)),
                      ),
                    ),
                  )
                : ListView.separated(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: msgs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = msgs[msgs.length - 1 - i];
                      return _Bubble(message: m, mine: m.senderId == me);
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.line)),
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : bottomInset(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_err) ...[FieldError(l.eMsg), const SizedBox(height: 6)],
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _msg,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(me!, otherId),
                          onChanged: (_) => _err ? setState(() => _err = false) : null,
                          style: AppTextStyles.body(400, color: c.ink),
                          cursorColor: c.ink,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: c.bg,
                            hintText: l.msgPh,
                            hintStyle: AppTextStyles.body(400, color: c.ink2),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            border: _pill(c.line),
                            enabledBorder: _pill(c.line),
                            focusedBorder: _pill(c.ink2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconCircleButton(
                      icon: PhosphorIconsFill.paperPlaneRight,
                      semanticLabel: l.send,
                      variant: IconButtonVariant.pri,
                      size: 48,
                      onPressed: () => _send(me!, otherId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _pill(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: color, width: 1.5),
      );
}

/// Üst çubuk (`chat-top`): geri, avatar (0.9), ad 20/900, not; altta 1 px çizgi.
class _ChatTop extends StatelessWidget {
  const _ChatTop({required this.user, required this.onBack});
  final UserModel user;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 4, 20, 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(
        children: [
          IconCircleButton(
            icon: PhosphorIconsFill.caretLeft,
            semanticLabel: l.back,
            onPressed: onBack,
          ),
          const SizedBox(width: 10),
          BibAvatar(initials: user.initials, goalkeeper: user.isGk, scale: .9),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s(20, 900, color: c.ink)),
                ),
                Text(l.chatNote, style: AppTextStyles.bodySm(400, color: c.ink2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mesaj balonu (`bub`): benim sağda `mine`, karşı taraf solda `card` + kontur.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final MessageModel message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const r = Radius.circular(20), t = Radius.circular(6);
    final radius = BorderRadius.only(
      topLeft: r,
      topRight: r,
      bottomLeft: mine ? r : t,
      bottomRight: mine ? t : r,
    );
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: .8,
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: mine ? c.mine : c.card, borderRadius: radius),
            // Kontur yer kaplamaz (CSS inset box-shadow).
            foregroundDecoration: mine
                ? null
                : BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: c.line, width: 1.5),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message.text, style: AppTextStyles.s(16, 400, height: 1.35, color: c.ink)),
                const SizedBox(height: 2),
                Text(chatTime(context, message.createdAt ?? clockNow()),
                    style: AppTextStyles.label(400, color: c.ink2, tabular: true)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
