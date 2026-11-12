import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/option_tile.dart';
import '../../../data/static/formations.dart';
import '../../../data/static/locations.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/draft_service.dart';
import '../team_actions.dart';

/// Panel `city`: arama + 81 il (seçili il en üstte, işaretli).
Future<void> showCitySheet(BuildContext context) =>
    showAppSheet<void>(context, builder: (_) => const _CitySheet());

class _CitySheet extends ConsumerStatefulWidget {
  const _CitySheet();
  @override
  ConsumerState<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends ConsumerState<_CitySheet> {
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
    final cur = ref.watch(draftProvider).city;
    final q = trLower(_q.text.trim());
    final list = kCities.where((x) => q.isEmpty || trLower(x).contains(q)).toList()
      ..sort((a, b) => (b == cur ? 1 : 0) - (a == cur ? 1 : 0));
    return SheetBody(children: [
      SheetTitle(l.cpTitle, sub: l.cpSub),
      const SizedBox(height: 6),
      AppTextField(
        controller: _q,
        placeholder: l.cpSearch,
        prefixIcon: PhosphorIconsFill.magnifyingGlass,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}),
      ),
      if (list.isEmpty)
        Text(l.noCity(_q.text.trim()), style: AppTextStyles.bodySm(400, color: c.ink2))
      else
        _Opts(children: [
          for (final x in list)
            OptionTile(
              title: x,
              selected: cur == x,
              onTap: () {
                Navigator.of(context).pop();
                if (ref.read(teamActionsProvider).pickCity(x)) {
                  AppToast.show(l.cityChanged);
                }
              },
            ),
        ]),
    ]);
  }
}

/// Panel `district`: il yoksa `dpNeed` + İl seç; varsa örnek ilçe listesi.
Future<void> showDistrictSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(builder: (ctx, ref, _) {
      final l = AppLocalizations.of(ctx);
      final d = ref.watch(draftProvider);
      if (d.city == null) {
        return SheetBody(children: [
          SheetTitle(l.dpTitle, sub: l.dpNeed),
          AppButton(
            label: l.cpTitle,
            wide: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              showCitySheet(context);
            },
          ),
        ]);
      }
      return SheetBody(children: [
        SheetTitle(l.dpTitle, sub: '${d.city}, ${l.dpSample}'),
        const SizedBox(height: 6),
        _Opts(children: [
          for (final x in districtsOf(d.city!))
            OptionTile(
              title: x,
              selected: d.district == x,
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(teamActionsProvider).pickDistrict(x);
              },
            ),
        ]),
      ]);
    }),
  );
}

/// Panel `stadium`: ilçe yoksa `spNeed` + İlçe seç; varsa 3 örnek saha.
Future<void> showStadiumSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(builder: (ctx, ref, _) {
      final l = AppLocalizations.of(ctx);
      final c = ctx.c;
      final d = ref.watch(draftProvider);
      if (d.district == null) {
        return SheetBody(children: [
          SheetTitle(l.spTitle, sub: l.spNeed),
          AppButton(
            label: l.dpTitle,
            wide: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              showDistrictSheet(context);
            },
          ),
        ]);
      }
      return SheetBody(children: [
        SheetTitle(l.spTitle, sub: l.spSample),
        const SizedBox(height: 6),
        _Opts(children: [
          for (final x in stadiumsOf(d.district!))
            OptionTile(
              title: x,
              selected: d.stadium == x,
              leading: Icon(PhosphorIconsFill.soccerBall, size: 20,
                  color: d.stadium == x ? c.onAccent : c.ink),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(teamActionsProvider).pickStadium(x);
              },
            ),
        ]),
      ]);
    }),
  );
}

/// Panel `time`: 3 sütunlu ızgara, 23 aralık.
Future<void> showTimeSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => Consumer(builder: (ctx, ref, _) {
      final l = AppLocalizations.of(ctx);
      final cur = ref.watch(draftProvider).matchTime;
      return SheetBody(children: [
        SheetTitle(l.tpTitle, sub: l.tpSub),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (ctx, box) {
          final w = (box.maxWidth - 16) / 3;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final h in kMatchHours)
                SizedBox(
                  width: w,
                  child: OptionTile(
                    title: h,
                    centered: true,
                    selected: cur == rangeStart(h),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(teamActionsProvider).pickTime(rangeStart(h));
                    },
                  ),
                ),
            ],
          );
        }),
      ]);
    }),
  );
}

/// Seçenek listesi (`opts`): 8 aralık.
class _Opts extends StatelessWidget {
  const _Opts({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      );
}
