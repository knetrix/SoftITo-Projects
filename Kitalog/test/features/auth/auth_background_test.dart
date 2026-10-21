import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/storage/digital_file_storage.dart';
import 'package:kitalog/core/theme/app_theme.dart';
import 'package:kitalog/features/auth/widgets/auth_background_widget.dart';

import '../../helpers/test_dependencies.dart';

Future<void> _pump(WidgetTester tester, {bool reduceMotion = false}) async {
  // Diğer testlerin aksine süs animasyonları açık kurulur.
  final scope = AppDependencies(
    await testStorage(),
    digitalFiles: MemoryDigitalFileStorage(),
    animateDecorations: true,
  );
  await tester.pumpWidget(
    scope.scope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Scaffold(
            body: AuthBackgroundWidget(child: SizedBox.expand()),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('arka plan sürekli animasyonludur', (tester) async {
    await _pump(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(SchedulerBinding.instance.transientCallbackCount, greaterThan(0));
    expect(find.byType(CustomPaint), findsWidgets);
    // Sonsuz animasyonu durdurmak için ağaç kaldırılır.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sistemde "hareketi azalt" açıksa sabit kalır', (tester) async {
    await _pump(tester, reduceMotion: true);
    await tester.pumpAndSettle();
    expect(SchedulerBinding.instance.transientCallbackCount, 0);
  });
}
