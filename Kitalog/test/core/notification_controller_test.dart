import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/di/app_dependencies.dart';
import 'package:kitalog/core/models/notification_target_model.dart';

import '../helpers/fake_reminder_engine.dart';
import '../helpers/test_dependencies.dart';

void main() {
  Future<AppDependencies> deps(FakeReminderEngine engine) =>
      createTestDependencies({}, null, null, null, null, null, engine);

  test('motor bir kez hazırlanır ve iade ile okuma planları ayrı gruplarda kurulur', () async {
    final engine = FakeReminderEngine();
    final d = await deps(engine);
    await d.notificationController.start();
    await d.notificationController.start();
    expect(engine.initializeCalls, 1);

    await d.libraryController.load();
    await d.loanReminderController.idle;
    await d.readingReminderController.idle;
    expect(engine.replaceCalls, 1);
    expect(engine.readingReplaceCalls, 1);
    expect(engine.permissionRequests, 0, reason: 'açılışta izin istenmez');
  });

  test('bildirimden açılış ve açıkken dokunma hedefi iletir; bir kez tüketilir', () async {
    final engine = FakeReminderEngine(launchedWith: 'seed-9781979064927');
    final d = await deps(engine);
    final notifications = d.notificationController;
    await notifications.start();
    expect(notifications.pendingTarget.value, const NotificationTargetModel.book('seed-9781979064927'),
        reason: 'önceki sürümün düz kimliği Kitap Detay sayılır');
    expect(notifications.takePendingTarget(), isNotNull);
    expect(notifications.takePendingTarget(), isNull);

    engine.onOpen!('read:seed-9780140817591');
    expect(notifications.pendingTarget.value, const NotificationTargetModel.read('seed-9780140817591'));
    engine.onOpen!('');
    expect(notifications.pendingTarget.value, const NotificationTargetModel.read('seed-9780140817591'),
        reason: 'boş payload yok sayılır');
  });

  test('desteklenmeyen platformda motor hazırlanmaz', () async {
    final engine = FakeReminderEngine(isSupported: false);
    final d = await deps(engine);
    await d.notificationController.start();
    expect(engine.initializeCalls, 0);
    expect(d.notificationController.isSupported, isFalse);
  });
}
