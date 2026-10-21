import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/view_status.dart';
import 'package:kitalog/core/routing/app_routes.dart';
import 'package:kitalog/features/splash/controllers/splash_controller.dart';

import '../../helpers/test_dependencies.dart';

void main() {
  test('oturum yoksa kayıt ekranına yönlendirir ve seed yükler', () async {
    final deps = await createTestDependencies();
    final controller = SplashController(
      auth: deps.authController,
      library: deps.libraryController,
      minDuration: Duration.zero,
    );
    expect(controller.state.value.status, ViewStatus.initial);
    await controller.start();
    expect(controller.state.value.status, ViewStatus.success);
    expect(controller.state.value.destination, AppRoutes.register);
    expect(deps.libraryController.books.value, isNotEmpty);
    controller.dispose();
  });

  test('açık oturum varsa ana kabuğa yönlendirir', () async {
    final deps = await createTestDependencies();
    await deps.authController.register(
      email: 'a@b.com',
      phone: '05321234567',
      password: 'Abcdefg1',
    );
    final controller = SplashController(
      auth: deps.authController,
      library: deps.libraryController,
      minDuration: Duration.zero,
    );
    await controller.start();
    expect(controller.state.value.destination, AppRoutes.home);
    controller.dispose();
  });
}
