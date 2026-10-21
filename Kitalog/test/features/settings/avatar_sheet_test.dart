import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/features/settings/views/settings_view.dart';

import '../../helpers/fake_avatar_picker.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  for (final size in [const Size(390, 700), const Size(360, 560)]) {
    testWidgets('profil resmi paneli ${size.width}x${size.height} ekranda taşmaz', (tester) async {
      final deps = await createTestDependencies();
      await deps.authController.register(
        email: 'a@b.com',
        phone: '05321234567',
        password: 'Abcdefg1',
      );
      await pumpScreen(
        tester,
        deps,
        SettingsView(avatarPicker: FakeAvatarPicker()),
        size: size,
      );
      await tester.tap(find.byTooltip('Profil resmini değiştir').first);
      await tester.pumpAndSettle();
      expect(find.text('Profil resmini kaldır'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
