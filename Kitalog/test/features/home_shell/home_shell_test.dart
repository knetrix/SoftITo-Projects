import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/notification_target_model.dart';
import 'package:kitalog/features/home_shell/controllers/home_shell_controller.dart';
import 'package:kitalog/features/home_shell/views/home_shell_view.dart';
import 'package:kitalog/features/reader/views/reader_view.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

void main() {
  test('selectTab geçerli aralıkta çalışır, dışındakini yok sayar', () {
    final controller = HomeShellController();
    expect(controller.tabCount, 4, reason: 'Kitaplığım, Okuma Durumu, Ödünç, Hedef');
    expect(controller.state.value.selectedIndex, 0);
    controller.selectTab(3);
    expect(controller.state.value.selectedIndex, 3);
    controller.selectTab(5);
    controller.selectTab(-1);
    expect(controller.state.value.selectedIndex, 3);
    controller.dispose();
  });

  test('başlangıç sekmesi sınırlanır', () {
    final controller = HomeShellController(tabCount: 3, initialIndex: 9);
    expect(controller.state.value.selectedIndex, 2);
    controller.dispose();
  });

  testWidgets('NavigationBar sekme değiştirir, sağ üstte ayarlar simgesi vardır', (tester) async {
    final deps = await createTestDependencies();
    await pumpScreen(
      tester,
      deps,
      const HomeShellView(
        pages: [Text('birinci'), Text('ikinci'), Text('üçüncü'), Text('dördüncü')],
      ),
    );
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    await tester.tap(find.text('Okuma Durumu'));
    await tester.pumpAndSettle();
    expect(find.text('Okuma Durumu'), findsWidgets);
    final stack = tester.widget<IndexedStack>(find.byType(IndexedStack));
    expect(stack.index, 1);
    await tester.tap(find.text('Ödünç'));
    await tester.pumpAndSettle();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);
    expect(find.text('Ödünç Takibi'), findsOneWidget, reason: 'AppBar başlığı');
    await tester.tap(find.text('Hedef'));
    await tester.pumpAndSettle();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 3);
  });

  testWidgets('Ödünç sekmesinde gecikmiş iade sayısı rozetle gösterilir', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final overdue = deps.libraryController.lentBooks.where((b) => b.loan!.isOverdue(DateTime.now())).length;
    expect(overdue, greaterThan(0), reason: 'örnek veride gecikmiş ödünç var');
    await pumpScreen(
      tester,
      deps,
      const HomeShellView(pages: [Text('1'), Text('2'), Text('3'), Text('4')]),
    );
    final badge = find.ancestor(of: find.byIcon(Icons.handshake_outlined), matching: find.byType(Badge));
    expect(tester.widget<Badge>(badge).isLabelVisible, isTrue);
    expect(find.descendant(of: badge, matching: find.text('$overdue')), findsOneWidget);
    expect(find.byTooltip('Ödünç: $overdue gecikmiş iade'), findsOneWidget);

    for (final book in deps.libraryController.lentBooks) {
      await deps.libraryController.returnBook(book.id);
    }
    await tester.pumpAndSettle();
    expect(tester.widget<Badge>(badge).isLabelVisible, isFalse);
  });

  testWidgets('dokunulan iade hatırlatmasının kitabı Kitap Detay\'da açılır, bir kez tüketilir', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final notifications = deps.notificationController;
    // Uygulama bildirimden açıldıysa istek ana kabuk kurulmadan gelmiştir.
    notifications.pendingTarget.value = const NotificationTargetModel.book('seed-9781979064927');
    await pumpScreen(tester, deps, const HomeShellView(pages: [Text('1'), Text('2'), Text('3'), Text('4')]));
    expect(find.text('Kitap Detayı'), findsOneWidget);
    expect(find.text("Alice's Adventures in Wonderland"), findsWidgets);
    expect(find.byType(ReaderView), findsNothing, reason: 'iade hatırlatması okuyucuyu açmaz');
    expect(notifications.pendingTarget.value, isNull);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    // Uygulama açıkken dokunma; silinmiş kitabın isteği yok sayılır.
    notifications.pendingTarget.value = const NotificationTargetModel.book('olmayan-kitap');
    await tester.pumpAndSettle();
    expect(find.text('Kitap Detayı'), findsNothing);
    notifications.pendingTarget.value = const NotificationTargetModel.book('seed-9780140817591');
    await tester.pumpAndSettle();
    expect(find.text('Pride and Prejudice'), findsWidgets);
    expect(find.text('Kitap Detayı'), findsOneWidget);
  });

  testWidgets('okuma hatırlatması dijital sürümü olan kitapta Okuyucu\'yu, geri gelince Kitap Detay\'ı açar', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const HomeShellView(pages: [Text('1'), Text('2'), Text('3'), Text('4')]));
    deps.notificationController.pendingTarget.value = const NotificationTargetModel.read('seed-9781435136168');
    await tester.pumpAndSettle();
    expect(find.byType(ReaderView), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(find.text('Kitap Detayı'), findsOneWidget);
  });

  testWidgets('okuma hatırlatması dijital sürümü olmayan kitapta Kitap Detay\'ı açar', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    final book = deps.libraryController.bookById('seed-9781435136168')!;
    await deps.libraryController.updateBook(book.copyWith(clearDigitalEdition: true));
    await pumpScreen(tester, deps, const HomeShellView(pages: [Text('1'), Text('2'), Text('3'), Text('4')]));
    deps.notificationController.pendingTarget.value = NotificationTargetModel.read(book.id);
    await tester.pumpAndSettle();
    expect(find.byType(ReaderView), findsNothing);
    expect(find.text('Kitap Detayı'), findsOneWidget);
  });

  testWidgets('okunan kitap yokken günlük hatırlatma Okuma Durumu sekmesini açar', (tester) async {
    final deps = await createTestDependencies();
    await deps.libraryController.load();
    await pumpScreen(tester, deps, const HomeShellView(pages: [Text('1'), Text('2'), Text('3'), Text('4')]));
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    deps.notificationController.pendingTarget.value = const NotificationTargetModel.readingStatus();
    await tester.pumpAndSettle();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 1);
    expect(deps.notificationController.pendingTarget.value, isNull);
  });
}
