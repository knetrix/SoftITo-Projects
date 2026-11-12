import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_icons.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_link.dart';
import '../../core/widgets/brand.dart';
import '../../l10n/app_localizations.dart';

/// 01 Karşılama (§3). Onboarding bir kez gösterilir; her iki eylem de
/// giriş ekranına gider (doğrudan ana uygulamaya gitmez).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final mq = MediaQuery.of(context);

    Future<void> finish() async {
      await ref.read(sharedPrefsProvider).setBool('onboardingSeen', true);
      if (context.mounted) context.go('/signin');
    }

    Widget feat(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 20, color: c.ok),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: AppTextStyles.bodySm(600, color: c.ink))),
          ],
        );

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: c.pitch),
                  Semantics(
                    image: true,
                    label: l.imgWelcome,
                    child: Image.asset(
                      'assets/images/welcome.jpg',
                      fit: BoxFit.cover,
                      alignment: const Alignment(-.16, 0),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: mq.padding.top + 4,
                    child: const Brand(pill: true),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, mq.padding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(l.onbH, style: AppTextStyles.display(color: c.ink)),
                ),
                const SizedBox(height: 14),
                Text(l.onbP, style: AppTextStyles.body(400, color: c.ink2)),
                const SizedBox(height: 14),
                feat(PhosphorIconsFill.strategy, l.onbF1),
                const SizedBox(height: 6),
                feat(PhosphorIconsFill.mapPin, l.onbF2),
                const SizedBox(height: 6),
                feat(PhosphorIconsFill.chatsCircle, l.onbF3),
                const SizedBox(height: 14),
                AppButton(label: l.onbStart, wide: true, onPressed: finish),
                const SizedBox(height: 14),
                Center(child: AppLink(text: l.onbHave, ink: true, onTap: finish)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
