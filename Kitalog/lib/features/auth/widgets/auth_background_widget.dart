import 'package:flutter/material.dart';

import '../../../core/di/app_scope.dart';
import 'auth_background_painter.dart';

/// Giriş / Kayıt ekranlarının animasyonlu sahnesi: arka planı (yıldızlar, ışık,
/// uçuşan harfler) çizer ve aynı animasyonu [child] içindeki kitapla
/// ([AuthBookWidget]) paylaşır. Sistem "hareketi azalt" ayarı açıksa (veya
/// testlerde) sabit tek kare çizilir.
class AuthBackgroundWidget extends StatefulWidget {
  const AuthBackgroundWidget({super.key, required this.child});

  final Widget child;

  static const Duration cycle = Duration(seconds: 24);

  /// Sahnenin animasyonu (kitap bu döngüyle sayfa çevirir).
  static Animation<double> animationOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SceneAnimation>()!.animation;

  @override
  State<AuthBackgroundWidget> createState() => _AuthBackgroundWidgetState();
}

class _AuthBackgroundWidgetState extends State<AuthBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AuthBackgroundWidget.cycle,
    value: 0.3,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate =
        AppScope.of(context).animateDecorations &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SceneAnimation(
      animation: _controller,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: AuthBackgroundPainter(
                    animation: _controller,
                    colors: Theme.of(context).colorScheme,
                    glyphStyle:
                        Theme.of(context).textTheme.headlineMedium ??
                        const TextStyle(),
                  ),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _SceneAnimation extends InheritedWidget {
  const _SceneAnimation({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SceneAnimation oldWidget) =>
      animation != oldWidget.animation;
}

/// Sahnenin altındaki açık kitap; sayfa düzeninde formun altında yer alır.
class AuthBookWidget extends StatelessWidget {
  const AuthBookWidget({super.key, required this.screen});

  /// Kitabın ölçüsünün hesaplandığı ekran boyutu.
  final Size screen;

  @override
  Widget build(BuildContext context) {
    // Kırpma: çizim hiçbir koşulda kitabın alanının dışına taşmaz.
    return ExcludeSemantics(
      child: ClipRect(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(screen.width, AuthBookPainter.heightFor(screen)),
            painter: AuthBookPainter(
              animation: AuthBackgroundWidget.animationOf(context),
              colors: Theme.of(context).colorScheme,
              screen: screen,
            ),
          ),
        ),
      ),
    );
  }
}
