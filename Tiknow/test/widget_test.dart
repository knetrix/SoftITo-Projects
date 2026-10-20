import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiknow/core/services/app_dependencies.dart';
import 'package:tiknow/core/services/storage_service.dart';
import 'package:tiknow/features/payment/views/payment_view.dart';
import 'package:tiknow/features/rental_map/models/vehicle_catalog.dart';
import 'package:tiknow/features/rental_packages/models/rental_package_model.dart';
import 'package:tiknow/main.dart';

Future<AppDependencies> boot(
  WidgetTester tester, [
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  tester.view.physicalSize = const Size(1080, 2200);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  final deps = AppDependencies.create(await StorageService.init());
  addTearDown(deps.dispose);
  await tester.pumpWidget(TiknowApp(deps: deps));
  await tester.pumpAndSettle();
  return deps;
}

Future<void> registerUser(WidgetTester tester) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'test@tiknow.com');
  await tester.enterText(fields.at(1), '05321234567');
  await tester.enterText(fields.at(2), 'Abcdefg1');
  await tester.enterText(fields.at(3), 'Abcdefg1');
  await tester.tap(find.text('Kayıt ol').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('oturum yoksa kayıt ekranı; geçersiz form hata gösterir',
      (tester) async {
    await boot(tester);
    expect(find.text('Hesap oluştur'), findsOneWidget);
    // Hesap yokken giriş bağlantısı görünmez.
    expect(find.text('Zaten hesabın var mı? Giriş yap'), findsNothing);

    await tester.tap(find.text('Kayıt ol').last);
    await tester.pumpAndSettle();
    expect(find.text('E-posta gerekli.'), findsOneWidget);
    expect(find.text('Cep telefonu gerekli.'), findsOneWidget);
  });

  testWidgets('kayıt sonrası harita açılır, dil anında değişir', (tester) async {
    final deps = await boot(tester);
    await registerUser(tester);

    expect(find.text('Aktif Kiralamalar'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    await deps.settings.setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(find.text('Active Rentals'), findsOneWidget);
    expect(find.text('Aktif Kiralamalar'), findsNothing);
  });

  testWidgets('kayıtlı oturum doğrudan haritayı açar', (tester) async {
    final first = AppDependencies.create(await (() async {
      SharedPreferences.setMockInitialValues({});
      return StorageService.init();
    })());
    await first.auth.register(
      email: 'a@b.co',
      phone: '5321234567',
      password: 'Abcdefg1',
      passwordConfirm: 'Abcdefg1',
    );
    first.dispose();

    await boot(tester, {
      'tiknow.user': '{"id":"u1","email":"a@b.co","phone":"5321234567",'
          '"passwordHash":"x","salt":"y"}',
      'tiknow.session_active': true,
    });
    expect(find.text('Aktif Kiralamalar'), findsOneWidget);
  });

  testWidgets('ayarlar: tema ve çıkış', (tester) async {
    final deps = await boot(tester);
    await registerUser(tester);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Ayarlar'), findsWidgets);
    expect(find.text('test@tiknow.com'), findsOneWidget);

    await tester.tap(find.text('Koyu'));
    await tester.pumpAndSettle();
    expect(deps.settings.themeMode.value, ThemeMode.dark);

    await tester.scrollUntilVisible(find.text('Çıkış yap'), 200);
    await tester.tap(find.text('Çıkış yap'));
    await tester.pumpAndSettle();
    expect(find.text('Hesap oluştur'), findsOneWidget);
    // Hesap var: giriş bağlantısı görünür.
    expect(find.text('Zaten hesabın var mı? Giriş yap'), findsOneWidget);
  });

  testWidgets('ödeme: kart doğrulama ve başarılı ödeme true döner',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => PaymentView(
                        vehicle: VehicleCatalog.vehicles.first,
                        plan: const RentalPlan.package('hour1'),
                      ),
                    ),
                  );
                },
                child: const Text('git'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('git'));
    await tester.pumpAndSettle();
    expect(find.text('Ödeme'), findsWidgets);

    // Boş formda hata.
    await tester.tap(find.text('150,00 TL öde'));
    await tester.pump();
    expect(find.text('Kart numarası gerekli.'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '4242424242424242');
    await tester.enterText(fields.at(1), 'ali veli');
    await tester.enterText(fields.at(2), '1230');
    await tester.enterText(fields.at(3), '123');
    await tester.tap(find.text('150,00 TL öde'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Ödeme başarılı!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
