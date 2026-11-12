import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/theme_controller.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/bib.dart';
import '../../core/widgets/notification_bell.dart';
import '../../core/widgets/option_tile.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../services/appointment_service.dart';
import '../../services/auth_service.dart';
import '../../services/invite_service.dart';
import '../../services/user_service.dart';
import 'delete_account_sheet.dart';

/// 07 Profil (§3): kart, 2 istatistik, Görünüm (tema + dil), Hesap (çıkış).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final u = ref.watch(currentUserProvider).value;
    final contact = ref.watch(myContactProvider).value;
    final settings = ref.watch(settingsProvider);
    final appts = ref.watch(bookingsProvider).length;
    final friends = ref.watch(friendsProvider).value?.length ?? 0;
    final lang = settings.locale.languageCode == 'en' ? l.langEn : l.langTr;

    Future<void> signOut() async {
      await ref.read(authServiceProvider).signOut();
      if (context.mounted) context.go('/signin');
      AppToast.show(l.signedOut);
    }

    Widget section(String title, List<Widget> children, {double bottom = 0}) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: AppTextStyles.body(800, color: c.ink)),
              ),
              for (final w in children) ...[const SizedBox(height: 10), w],
            ],
          ),
        );

    return ColoredBox(
      color: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: l.prH, actions: const [NotificationBell()]),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24)),
                    // Kontur yer kaplamaz (CSS inset box-shadow).
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: c.line, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ProfileBibAvatar(initials: u?.initials ?? ''),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(u?.fullName ?? '',
                                  style: AppTextStyles.titleSm(color: c.ink)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon: PhosphorIconsFill.phone,
                          label: l.prPhone,
                          value: (contact?.phone ?? '').isEmpty ? l.noPhone : contact!.phone,
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(
                          icon: PhosphorIconsFill.envelope,
                          label: l.prEmail,
                          value: contact?.email ?? '',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            n: appts,
                            label: l.prAppts,
                            onTap: () => context.go('/appointments'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Stat(
                            n: friends,
                            label: l.prFriends,
                            onTap: () => context.go('/social?tab=friends'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  section(l.prLook, [
                    Semantics(
                      label: l.theme,
                      container: true,
                      child: AppSegment(
                        labels: [l.light, l.dark],
                        index: settings.themeMode == ThemeMode.dark ? 1 : 0,
                        onChanged: (i) => ref
                            .read(settingsProvider.notifier)
                            .setTheme(i == 1 ? ThemeMode.dark : ThemeMode.light),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l.language, style: AppTextStyles.bodySm(700, color: c.ink)),
                        const SizedBox(height: 6),
                        _Select(
                          value: lang,
                          semanticLabel: '${l.language}, $lang',
                          onTap: () => _pickLanguage(context, ref),
                        ),
                      ],
                    ),
                  ]),
                  section(l.prAccount, [
                    AppButton(
                      label: l.signOut,
                      icon: PhosphorIconsFill.signOut,
                      variant: AppButtonVariant.alt,
                      wide: true,
                      onPressed: signOut,
                    ),
                    AppButton(
                      label: l.delAcct,
                      icon: PhosphorIconsFill.trash,
                      variant: AppButtonVariant.danger,
                      wide: true,
                      onPressed: () => showDeleteAccountSheet(context),
                    ),
                  ], bottom: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) {
    return showAppSheet<void>(
      context,
      builder: (ctx) => Consumer(builder: (ctx, ref, _) {
        final l = AppLocalizations.of(ctx);
        final cur = ref.watch(settingsProvider).locale.languageCode;
        return SheetBody(children: [
          SheetTitle(l.language),
          const SizedBox(height: 6),
          for (final (code, name) in [('tr', l.langTr), ('en', l.langEn)])
            OptionTile(
              title: name,
              selected: cur == code,
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(settingsProvider.notifier).setLocale(code);
              },
            ),
        ]);
      }),
    );
  }
}

/// `prow`: ikon 22 `ink2` + etiket 12/600 + değer 16/600.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return MergeSemantics(
      child: Row(
        children: [
          Icon(icon, size: 22, color: c.ink2),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.s(12, 600, color: c.ink2)),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(600, color: c.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// İstatistik kutusu `stat`: 76 min, köşe 20, `chip` zemin, 28/900 sayı.
class _Stat extends StatelessWidget {
  const _Stat({required this.n, required this.label, required this.onTap});
  final int n;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: onTap,
      semanticLabel: '$n $label',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$n', style: AppTextStyles.s(28, 900, height: 1, color: c.ink, tabular: true)),
              const SizedBox(height: 2),
              Text(label, style: AppTextStyles.bodySm(400, color: c.ink2)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seçim kutusu `sel`: 52 yükseklik, köşe 16, `card` zemin, 1.5 `line`, 16/600.
class _Select extends StatelessWidget {
  const _Select({required this.value, required this.onTap, this.semanticLabel});
  final String value;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Pressable(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(16)),
          // Kontur yer kaplamaz (CSS inset box-shadow).
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.line, width: 1.5),
          ),
          child: Text(value, style: AppTextStyles.body(600, color: c.ink)),
        ),
      ),
    );
  }
}
