// Uygulama ikonunu üretir: `flutter test tool/make_icon_test.dart`
// Çıktı: assets/icon/app_icon.png (1024, turuncu zemin) ve
// assets/icon/app_icon_foreground.png (adaptive icon ön planı, şeffaf).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

const _orange = ui.Color(0xFFFF7A1A);
const _orangeLight = ui.Color(0xFFFF9547);
const _white = ui.Color(0xFFFFFFFF);

void _drawSymbol(ui.Canvas canvas, double scale) {
  canvas.save();
  canvas.translate(512, 512);
  canvas.scale(scale);
  canvas.translate(-512, -512);

  final white = ui.Paint()..color = _white..isAntiAlias = true;
  final orange = ui.Paint()..color = _orange..isAntiAlias = true;

  // Konum iğnesi: daire + alta inen sivri uç.
  const cx = 512.0, cy = 440.0, r = 262.0;
  canvas.drawCircle(const ui.Offset(cx, cy), r, white);
  canvas.drawPath(
    ui.Path()
      ..moveTo(cx - 215, cy + 150)
      ..quadraticBezierTo(cx - 90, cy + 300, cx, cy + 440)
      ..quadraticBezierTo(cx + 90, cy + 300, cx + 215, cy + 150)
      ..close(),
    white,
  );
  canvas.drawCircle(const ui.Offset(cx, cy), 190, orange);

  // İğnenin içinde beyaz araç (yandan görünüm).
  canvas.save();
  canvas.translate(cx, cy + 4);
  canvas.scale(1.4);
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTRB(-112, -4, 112, 50),
      const ui.Radius.circular(22),
    ),
    white,
  );
  canvas.drawPath(
    ui.Path()
      ..moveTo(-70, -2)
      ..lineTo(-44, -52)
      ..lineTo(44, -52)
      ..lineTo(76, -2)
      ..close(),
    white,
  );
  canvas.drawPath(
    ui.Path()
      ..moveTo(-58, -8)
      ..lineTo(-38, -43)
      ..lineTo(-6, -43)
      ..lineTo(-6, -8)
      ..close(),
    orange,
  );
  canvas.drawPath(
    ui.Path()
      ..moveTo(6, -8)
      ..lineTo(6, -43)
      ..lineTo(38, -43)
      ..lineTo(60, -8)
      ..close(),
    orange,
  );
  for (final x in [-64.0, 64.0]) {
    canvas.drawCircle(ui.Offset(x, 50), 38, orange);
    canvas.drawCircle(ui.Offset(x, 50), 28, white);
    canvas.drawCircle(ui.Offset(x, 50), 12, orange);
  }
  canvas.restore();
  canvas.restore();
}

Future<void> _save(String path, {required bool foreground}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  const size = 1024.0;
  if (!foreground) {
    final bg = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(0, 0),
        const ui.Offset(size, size),
        [_orangeLight, _orange],
      );
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, size, size), bg);
  }
  // Adaptive ön plan güvenli alana (≈%66) sığacak şekilde küçültülür.
  _drawSymbol(canvas, foreground ? 0.62 : 0.86);
  final image = await recorder.endRecording().toImage(1024, 1024);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  testWidgets('ikonları üret', (tester) async {
    await tester.runAsync(() async {
      await _save('assets/icon/app_icon.png', foreground: false);
      await _save('assets/icon/app_icon_foreground.png', foreground: true);
    });
  });
}
