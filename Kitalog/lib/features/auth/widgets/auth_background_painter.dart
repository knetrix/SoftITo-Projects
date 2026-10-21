import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Giriş / Kayıt arka planı: göz kırpan yıldızlar ve lamba ışığı altında, ekranın
/// altındaki açık kitaptan (bkz. [AuthBookPainter]) harfler havaya süzülür.
/// Uygulamaya özel çizilmiştir (dış görsel yok); renkler ve yazı tipi temadan gelir.
class AuthBackgroundPainter extends CustomPainter {
  AuthBackgroundPainter({
    required this.animation,
    required this.colors,
    required this.glyphStyle,
  }) : _glyphs = [
         for (final char in _alphabet.characters)
           TextPainter(
             text: TextSpan(
               text: char,
               style: glyphStyle.copyWith(color: colors.primary),
             ),
             textDirection: TextDirection.ltr,
           )..layout(),
       ],
       super(repaint: animation);

  /// 0 → 1 arası döngü (tekrar eden animasyon); hareket kapalıysa sabit kalır.
  final Animation<double> animation;
  final ColorScheme colors;

  /// Uçuşan harflerin yazı tipi (temadaki başlık stili).
  final TextStyle glyphStyle;
  final List<TextPainter> _glyphs;

  static const String _alphabet = 'KitalogçğıöşüAaBbEeRrSsMmNnYy';

  static final List<_Star> _stars = _Star.generate(46);
  static final List<_Letter> _letters = _Letter.generate(34);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.surface, colors.surfaceContainerHigh],
        ).createShader(rect),
    );
    _paintGlow(canvas, size, t);
    _paintStars(canvas, size, t);
    final book = _BookGeometry(size);
    _paintBookGlow(canvas, book, t);
    _paintLetters(canvas, size, book, t);
  }

  void _paintGlow(Canvas canvas, Size size, double t) {
    final pulse = 0.85 + 0.15 * math.sin(t * 2 * math.pi * 2);
    final center = Offset(size.width * 0.85, size.height * 0.08);
    final radius = size.shortestSide * 0.85;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.primary.withValues(alpha: 0.26 * pulse),
            colors.primary.withValues(alpha: 0.07 * pulse),
            colors.primary.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintStars(Canvas canvas, Size size, double t) {
    final paint = Paint();
    for (final star in _stars) {
      final twinkle =
          0.5 + 0.5 * math.sin((t * star.speed + star.phase) * 2 * math.pi);
      paint.color = colors.onSurface.withValues(alpha: 0.08 + 0.32 * twinkle);
      final center = Offset(star.x * size.width, star.y * size.height * 0.62);
      canvas.drawCircle(center, star.radius, paint);
      if (star.bright) {
        // Parlak yıldızlarda ince, dört kollu ışıltı.
        paint.strokeWidth = 0.8;
        final arm = star.radius * (2.5 + 2 * twinkle);
        canvas.drawLine(
          center.translate(-arm, 0),
          center.translate(arm, 0),
          paint,
        );
        canvas.drawLine(
          center.translate(0, -arm),
          center.translate(0, arm),
          paint,
        );
      }
    }
  }

  /// Kitabın üstünde, sayfalardan yayılan sıcak ışık.
  void _paintBookGlow(Canvas canvas, _BookGeometry book, double t) {
    final pulse = 0.8 + 0.2 * math.sin(t * 2 * math.pi * 3);
    final center = Offset(book.spineX, book.top);
    final radius = book.width * 0.75;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            colors.primary.withValues(alpha: 0.22 * pulse),
            colors.primary.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintLetters(Canvas canvas, Size size, _BookGeometry book, double t) {
    // Harfler kitaptan ekranın üst kısmına kadar uçar (kartın üstünde de görünsün).
    final rise = book.top - size.height * 0.04;
    for (final letter in _letters) {
      // Harf, kitabın üstünden doğar; yükselirken yana salınır, döner ve söner.
      final p = (letter.phase + t * letter.speed) % 1.0;
      final x =
          book.spineX +
          (letter.origin - 0.5) * book.width * 0.8 +
          math.sin((p * letter.waves + letter.phase) * 2 * math.pi) *
              letter.sway;
      final y = book.top - 6 - p * rise;
      final fade = math.sin(p * math.pi);
      final glyph = _glyphs[letter.glyph % _glyphs.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((p - 0.5) * letter.spin);
      canvas.scale(letter.scale * (1 - 0.35 * p));
      // Küçük sınırlı katman: yalnızca harfin saydamlığı değişir, metin yeniden dizilmez.
      canvas.saveLayer(
        Rect.fromCenter(
          center: Offset.zero,
          width: glyph.width + 4,
          height: glyph.height + 4,
        ),
        Paint()..color = colors.primary.withValues(alpha: fade),
      );
      glyph.paint(canvas, Offset(-glyph.width / 2, -glyph.height / 2));
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(AuthBackgroundPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.glyphStyle != glyphStyle;
}

/// Ekranın altındaki açık kitap: kapak, sayfa destesi, sırt gölgesi ve düzenli
/// aralıklarla çevrilen sayfa. Sayfa düzeninde formun altında kendi alanını
/// kaplar (form uzarsa kitap da içerikle birlikte aşağı kayar, üstüne binilmez).
class AuthBookPainter extends CustomPainter {
  AuthBookPainter({
    required this.animation,
    required this.colors,
    required this.screen,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final ColorScheme colors;

  /// Kitabın ölçüsü ekran boyutundan hesaplanır (arka plandaki harfler ve ışık
  /// da aynı ölçüyü kullanır).
  final Size screen;

  /// Bir döngüde kaç kez sayfa çevrilir (tam sayı: döngü atlamasız birleşir).
  static const int _flipsPerCycle = 4;

  /// Sayfa çevirme, her çevirme aralığının ilk bu kadarlık kısmında olur.
  static const double _flipShare = 0.28;

  /// Kitabın kapladığı yükseklik: sayfa kubbesi ve çevrilirken en yükseğe
  /// kalkan sayfa (yaklaşık 0,45 kitap yüksekliği) dahil; çizim bu alanın
  /// dışına taşmaz.
  static double heightFor(Size screen) {
    final book = _BookGeometry(screen);
    return screen.height - book.top + book.height * 0.5 + 8;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ölçüler ekran koordinatında; kitap kendi alanının altına oturtulur.
    canvas.translate(0, size.height - screen.height);
    _paintBook(canvas, _BookGeometry(screen), animation.value);
  }

  void _paintBook(Canvas canvas, _BookGeometry book, double t) {
    final edge = Paint()
      ..color = colors.primary.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final stackEdge = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // Kapak: sayfaların altından taşan, sırtı ortada olan sert kapak.
    final cover = book.page(-1, 1.04, drop: book.height * 0.07)
      ..addPath(book.page(1, 1.04, drop: book.height * 0.07), Offset.zero);
    canvas.drawPath(cover, Paint()..color = colors.primaryContainer);
    canvas.drawPath(cover, edge);
    for (final side in [-1.0, 1.0]) {
      // Sayfa destesi: alttaki sayfaların kenarları kademeli görünür.
      for (var k = 3; k >= 1; k--) {
        final layer = book.page(side, 1 + k * 0.006, drop: k * 2.6);
        canvas.drawPath(layer, Paint()..color = colors.surfaceContainerHigh);
        canvas.drawPath(layer, stackEdge);
      }
      _paintPage(canvas, book, book.page(side, 1), side, edge);
      _paintTextLines(canvas, book, side);
    }
    _paintSpineShadow(canvas, book);
    // Çevrilen sayfa: sağdan sola, ucu kavis çizerek kalkar.
    final cycle = (t * _flipsPerCycle) % 1.0;
    if (cycle < _flipShare) {
      final p = Curves.easeInOut.transform(cycle / _flipShare);
      final reach = math.cos(p * math.pi);
      final side = reach < 0 ? -1.0 : 1.0;
      final turning = book.page(side, reach.abs(), lift: math.sin(p * math.pi));
      _paintPage(canvas, book, turning, side, edge);
    }
  }

  /// Sayfa: sırta doğru koyulaşan kağıt tonu ve kenar çizgisi.
  void _paintPage(
    Canvas canvas,
    _BookGeometry book,
    Path page,
    double side,
    Paint edge,
  ) {
    final bounds = page.getBounds();
    canvas.drawPath(
      page,
      Paint()
        ..shader = LinearGradient(
          begin: side < 0 ? Alignment.centerRight : Alignment.centerLeft,
          end: side < 0 ? Alignment.centerLeft : Alignment.centerRight,
          colors: [colors.surfaceContainer, colors.surfaceContainerHighest],
          stops: const [0, 0.35],
        ).createShader(bounds),
    );
    canvas.drawPath(page, edge);
  }

  void _paintSpineShadow(Canvas canvas, _BookGeometry book) {
    final rect = Rect.fromLTRB(
      book.spineX - book.width * 0.035,
      book.top,
      book.spineX + book.width * 0.035,
      book.bottom,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            colors.shadow.withValues(alpha: 0),
            colors.shadow.withValues(alpha: 0.28),
            colors.shadow.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  /// Sayfadaki satırları andıran, sayfanın kavisini izleyen ince çizgiler.
  void _paintTextLines(Canvas canvas, _BookGeometry book, double side) {
    final paint = Paint()
      ..color = colors.onSurfaceVariant.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const rows = 7;
    for (var i = 0; i < rows; i++) {
      final f = (i + 1) / (rows + 1);
      final y = book.top + book.height * 0.08 + (book.height * 0.8) * f;
      final inner = book.spineX + side * book.width * 0.05;
      final outer =
          book.spineX + side * book.width * (i == rows - 1 ? 0.27 : 0.44);
      final bow = book.height * 0.1 * (1 - f * 0.6);
      canvas.drawPath(
        Path()
          ..moveTo(inner, y + bow * 0.4)
          ..quadraticBezierTo(
            (inner + outer) / 2,
            y - bow,
            outer,
            y - bow * 0.2,
          ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(AuthBookPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.screen != screen;
}

/// Ekranın altındaki açık kitabın ölçüleri.
class _BookGeometry {
  _BookGeometry(Size size)
    // Kısa ekranlarda (yatay telefon) kitap küçülür, forma yer kalır.
    : width = math.min(math.min(size.width * 0.8, 420), size.height * 0.45),
      spineX = size.width / 2,
      bottom = size.height * 0.95 {
    height = width * 0.3;
    top = bottom - height;
    dip = height * 0.12;
  }

  final double width;
  final double spineX;
  final double bottom;
  late final double height;
  late final double top;

  /// Sayfaların sırtta içeri çöküşü.
  late final double dip;

  /// [side] -1 sol, 1 sağ sayfa; [reach] sayfanın sırttan açılma oranı (0-1);
  /// [lift] çevrilen sayfanın kalkması (0-1); [drop] sayfayı aşağı kaydırır
  /// (alttaki sayfa ve kapak katmanları için).
  Path page(double side, double reach, {double lift = 0, double drop = 0}) {
    final w = width / 2 * reach * side;
    final raise = lift * height * 0.32;
    final top0 = top + drop - raise;
    final bottom0 = bottom + drop - raise * 0.5;
    final spineTop = top + dip + drop;
    final spineBottom = bottom + drop;
    // Üst kenar sırttan kalkıp sayfa ortasında kubbe yapar, dış köşeye iner.
    return Path()
      ..moveTo(spineX, spineTop)
      ..cubicTo(
        spineX + w * 0.18,
        top0 - height * 0.14,
        spineX + w * 0.62,
        top0 - height * 0.12,
        spineX + w,
        top0 + height * 0.04,
      )
      ..quadraticBezierTo(
        spineX + w * 1.02,
        (top0 + bottom0) / 2,
        spineX + w,
        bottom0,
      )
      ..cubicTo(
        spineX + w * 0.62,
        bottom0 - height * 0.16,
        spineX + w * 0.18,
        bottom0 - height * 0.14,
        spineX,
        spineBottom,
      )
      ..close();
  }
}

/// Yıldız; sabit tohumla üretilir, her açılışta aynı görünür.
class _Star {
  const _Star(this.x, this.y, this.radius, this.phase, this.speed, this.bright);

  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;
  final bool bright;

  static List<_Star> generate(int count) {
    final random = math.Random(5);
    return [
      for (var i = 0; i < count; i++)
        _Star(
          random.nextDouble(),
          random.nextDouble(),
          0.6 + random.nextDouble() * 1.3,
          random.nextDouble(),
          // Tam sayı hız: döngü (t: 1 → 0) atlamasız birleşir.
          2 + random.nextInt(4).toDouble(),
          random.nextDouble() < 0.15,
        ),
    ];
  }
}

/// Kitaptan uçan harf.
class _Letter {
  const _Letter(
    this.glyph,
    this.origin,
    this.phase,
    this.speed,
    this.sway,
    this.waves,
    this.spin,
    this.scale,
  );

  final int glyph;
  final double origin;
  final double phase;
  final double speed;
  final double sway;
  final double waves;
  final double spin;
  final double scale;

  static List<_Letter> generate(int count) {
    final random = math.Random(13);
    return [
      for (var i = 0; i < count; i++)
        _Letter(
          random.nextInt(1000),
          random.nextDouble(),
          random.nextDouble(),
          1 + random.nextInt(2).toDouble(),
          10 + random.nextDouble() * 26,
          1 + random.nextInt(2).toDouble(),
          (random.nextDouble() - 0.5) * 2.4,
          0.55 + random.nextDouble() * 0.7,
        ),
    ];
  }
}
