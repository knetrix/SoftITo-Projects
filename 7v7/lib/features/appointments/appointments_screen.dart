import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/time_format.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/notification_bell.dart';
import '../../core/widgets/option_tile.dart';
import '../../core/widgets/pressable.dart';
import '../../core/widgets/screen_header.dart';
import '../../l10n/app_localizations.dart';
import '../../services/appointment_service.dart';

enum _Filter { all, day, eve }

/// Arama: saha, ilçe, il ve oyuncu adları (tr küçük harf); Gündüz / Akşam.
bool bookingMatches(Booking b, String q, {bool? day}) {
  if (day != null && isDaytime(b.matchTime) != day) return false;
  final query = trLower(q.trim());
  if (query.isEmpty) return true;
  final hay = [b.stadium, b.district, b.city, ...b.players.map((p) => p.fullName)].join(' ');
  return trLower(hay).contains(query);
}

/// 05 Randevularım (§3, §5.5).
class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  final _q = TextEditingController();
  _Filter _f = _Filter.all;

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  void _clear() => setState(() {
        _q.clear();
        _f = _Filter.all;
      });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final all = ref.watch(bookingsProvider);
    final day = switch (_f) {
      _Filter.all => null,
      _Filter.day => true,
      _Filter.eve => false,
    };
    final list = all.where((b) => bookingMatches(b, _q.text, day: day)).toList();

    Widget chip(_Filter f, String label) => AppChip(
          label: label,
          selected: _f == f,
          onTap: () => setState(() => _f = f),
        );

    final Widget body;
    if (all.isEmpty) {
      body = EmptyState(
        image: 'assets/images/empty_appts.jpg',
        imageLabel: l.imgEmptyAppts,
        title: l.apEmptyT,
        description: l.apEmptyD,
        actionLabel: l.apEmptyBtn,
        actionIcon: PhosphorIconsFill.usersThree,
        onAction: () => context.go('/team'),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                chip(_Filter.all, l.fAll),
                const SizedBox(width: 8),
                chip(_Filter.day, l.fDay),
                const SizedBox(width: 8),
                chip(_Filter.eve, l.fEve),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.nAppts('${list.length}'),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm(400, color: c.ink2, tabular: true),
                  ),
                ),
              ],
            ),
          ),
          if (list.isEmpty)
            EmptyState(
              title: l.apNone,
              actionLabel: l.clearSearch,
              actionVariant: AppButtonVariant.alt,
              onAction: _clear,
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, b) in list.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    BookingCard(booking: b),
                  ],
                ],
              ),
            ),
        ],
      );
    }

    return ColoredBox(
      color: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenHeader(title: l.apH, actions: const [NotificationBell()]),
          if (all.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: AppTextField(
                controller: _q,
                placeholder: l.apSearch,
                prefixIcon: PhosphorIconsFill.magnifyingGlass,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
              ),
            ),
          Expanded(child: SingleChildScrollView(child: body)),
          if (all.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: AppButton(
                label: l.newMatch,
                icon: PhosphorIconsFill.plus,
                wide: true,
                onPressed: () => context.go('/team'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Randevu kartı (`acard`): saat kutusu + saha, konum, etiketler, oyuncular.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final l = AppLocalizations.of(context);
    final b = booking;
    final names = b.players.map((p) => p.firstName).join(', ');
    return Pressable(
      onTap: () => b.building
          ? context.push('/invites/${b.invite!.id}')
          : context.push('/appointments/${b.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(24)),
        // Kontur yer kaplamaz (CSS inset box-shadow).
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.line, width: 1.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                decoration: BoxDecoration(
                  color: c.chip,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(b.matchTime,
                        style: AppTextStyles.s(20, 900, height: 1.2, color: c.ink, tabular: true)),
                    const SizedBox(height: 2),
                    Text(l.oneHour, style: AppTextStyles.label(400, color: c.ink2)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.stadium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body(800, color: c.ink)),
                      const SizedBox(height: 4),
                      Text('${b.district}, ${b.city}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm(400, color: c.ink2)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(b.formation),
                          if (b.isSample) ...[const SizedBox(width: 8), _Tag(l.sampleTag)],
                          if (b.guest) ...[
                            const SizedBox(width: 8),
                            // Dar ekranda (360) etiket kısalır, satır taşmaz.
                            Flexible(
                              flex: 0,
                              fit: FlexFit.loose,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 140),
                                child: _Tag(b.building ? l.buildingTag : l.guestTag),
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(names,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySm(400, color: c.ink2)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: c.chip, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySm(800, color: c.ink, tabular: true)),
    );
  }
}
