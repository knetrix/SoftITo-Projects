import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_button.dart';

/// Alt panel (§2.9): `card` zemin, maks %88 yükseklik, kaydırılabilir,
/// 24/20 iç boşluk, alt güvenli alan; öğeler arası 10.
/// Alttan açılır (220 ms), kapanış anlık; arka plan %50 siyah.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    _SheetRoute<T>(builder: builder),
  );
}

class _SheetRoute<T> extends PopupRoute<T> {
  _SheetRoute({required this.builder});
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => AppColors.scrim;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'sheet';
  @override
  Duration get transitionDuration => const Duration(milliseconds: 220);
  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  Widget buildPage(BuildContext context, Animation<double> a, Animation<double> b) {
    final c = context.c;
    final mq = MediaQuery.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * .88),
          child: Material(
            color: c.card,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  mq.viewInsets.bottom > 0 ? 20 : (mq.padding.bottom < 34 ? 34 : mq.padding.bottom),
                ),
                child: SheetScope(child: Builder(builder: builder)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondary, Widget child) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final curved = CurvedAnimation(
      parent: animation,
      curve: const Cubic(.2, .8, .2, 1),
    );
    if (reduce) return FadeTransition(opacity: curved, child: child);
    return SlideTransition(
      position: Tween(begin: const Offset(0, .12), end: Offset.zero)
          .animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}

/// Panel içeriği: öğeler arası 10 boşluk.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.children, this.gap = 10});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}

/// Panel başlığı 20/900 + isteğe bağlı alt metin 14 `ink2`.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.title, {super.key, this.sub});
  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: AppTextStyles.titleSm(color: c.ink)),
        ),
        if (sub != null) ...[
          const SizedBox(height: 10),
          Text(sub!, style: AppTextStyles.bodySm(400, color: c.ink2)),
        ],
      ],
    );
  }
}

/// Onay paneli (§2.9): başlık + açıklama + yıkıcı onay + Vazgeç.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String yes,
  required String no,
}) async {
  final r = await showAppSheet<bool>(
    context,
    builder: (ctx) {
      final c = ctx.c;
      return SheetBody(children: [
        Text(title, style: AppTextStyles.titleSm(color: c.ink)),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(body, style: AppTextStyles.body(400, color: c.ink2)),
        ),
        AppButton(
          label: yes,
          height: 52,
          variant: AppButtonVariant.danger,
          wide: true,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
        AppButton(
          label: no,
          height: 52,
          variant: AppButtonVariant.alt,
          wide: true,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
      ]);
    },
  );
  return r ?? false;
}

/// Alt panel içinde olunduğunu bildirir: panel butonları ve seçenekleri
/// 48 px min yüksekliktedir (prototip `.sheet button{min-height:48px}`).
class SheetScope extends InheritedWidget {
  const SheetScope({super.key, required super.child});

  static bool inSheet(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SheetScope>() != null;

  @override
  bool updateShouldNotify(SheetScope oldWidget) => false;
}
