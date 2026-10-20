import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiknow/core/services/settings_controller.dart';
import 'package:tiknow/core/services/storage_service.dart';
import 'package:tiknow/features/active_rentals/controllers/active_rentals_controller.dart';
import 'package:tiknow/features/auth/controllers/auth_controller.dart';
import 'package:tiknow/features/payment/controllers/payment_controller.dart';
import 'package:tiknow/features/payment/models/payment_model.dart';
import 'package:tiknow/features/rental_map/controllers/rental_map_controller.dart';
import 'package:tiknow/features/rental_map/models/vehicle_catalog.dart';
import 'package:tiknow/features/rental_packages/models/rental_package_model.dart';
import 'package:tiknow/features/settings/controllers/profile_controller.dart';

Future<StorageService> newStorage([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return StorageService.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsController', () {
    test('tema ve dil kalıcıdır', () async {
      final storage = await newStorage();
      final settings = SettingsController(storage);
      expect(settings.themeMode.value, ThemeMode.system);
      expect(settings.locale.value, const Locale('tr'));

      await settings.setThemeMode(ThemeMode.dark);
      await settings.setLocale(const Locale('en'));

      final reloaded = SettingsController(storage);
      expect(reloaded.themeMode.value, ThemeMode.dark);
      expect(reloaded.locale.value, const Locale('en'));
    });
  });

  group('AuthController', () {
    const good = (
      email: 'Mustafa@Example.com',
      phone: '0532 123 45 67',
      password: 'Abcdefg1',
    );

    test('kayıt: normalleştirir, hash saklar, oturum açar', () async {
      final storage = await newStorage();
      final auth = AuthController(storage);
      expect(auth.state.value, AuthState.unauthenticated);

      final ok = await auth.register(
        email: good.email,
        phone: good.phone,
        password: good.password,
        passwordConfirm: good.password,
      );
      expect(ok, isTrue);
      expect(auth.state.value, AuthState.authenticated);
      expect(auth.user.value!.email, 'mustafa@example.com');
      expect(auth.user.value!.phone, '5321234567');
      expect(auth.user.value!.passwordHash, isNot(contains(good.password)));

      // Yeniden açılış: oturum korunur.
      expect(AuthController(storage).state.value, AuthState.authenticated);
    });

    test('hatalı kayıt alan hatası verir', () async {
      final auth = AuthController(await newStorage());
      final ok = await auth.register(
        email: 'x',
        phone: good.phone,
        password: good.password,
        passwordConfirm: good.password,
      );
      expect(ok, isFalse);
      expect(auth.errorKey.value, 'err_email_invalid');
      expect(auth.state.value, AuthState.failure);
    });

    test('çıkış sonrası giriş: yanlış şifre reddedilir, doğrusu girer', () async {
      final storage = await newStorage();
      final auth = AuthController(storage);
      await auth.register(
        email: good.email,
        phone: good.phone,
        password: good.password,
        passwordConfirm: good.password,
      );
      await auth.logout();
      expect(auth.state.value, AuthState.unauthenticated);
      expect(AuthController(storage).state.value, AuthState.unauthenticated);

      expect(await auth.login(email: good.email, password: 'Yanlis123'), isFalse);
      expect(auth.errorKey.value, 'err_login_failed');
      expect(await auth.login(email: good.email, password: good.password), isTrue);
      expect(auth.state.value, AuthState.authenticated);
    });
  });

  group('ProfileController', () {
    Future<(AuthController, ProfileController)> setUpProfile() async {
      final auth = AuthController(await newStorage());
      await auth.register(
        email: 'a@b.co',
        phone: '5321234567',
        password: 'Abcdefg1',
        passwordConfirm: 'Abcdefg1',
      );
      return (auth, ProfileController(auth));
    }

    test('e-posta ve telefon değişir', () async {
      final (auth, profile) = await setUpProfile();
      expect(await profile.changeEmail('yeni@mail.com'), isNull);
      expect(await profile.changePhone('05431112233'), isNull);
      expect(profile.profile.value.email, 'yeni@mail.com');
      expect(profile.profile.value.phone, '5431112233');
      expect(auth.user.value!.phone, '5431112233');
      expect(await profile.changeEmail('bozuk'), 'err_email_invalid');
    });

    test('şifre değişimi eski şifreyi doğrular', () async {
      final (auth, profile) = await setUpProfile();
      expect(
        await profile.changePassword(
          oldPassword: 'Yanlis123',
          newPassword: 'Yenisifre1',
          newPasswordConfirm: 'Yenisifre1',
        ),
        'err_old_password_wrong',
      );
      expect(
        await profile.changePassword(
          oldPassword: 'Abcdefg1',
          newPassword: 'zayif',
          newPasswordConfirm: 'zayif',
        ),
        'err_password_weak',
      );
      expect(
        await profile.changePassword(
          oldPassword: 'Abcdefg1',
          newPassword: 'Yenisifre1',
          newPasswordConfirm: 'Yenisifre1',
        ),
        isNull,
      );
      await auth.logout();
      expect(await auth.login(email: 'a@b.co', password: 'Yenisifre1'), isTrue);
    });
  });

  group('PaymentController', () {
    const ok = PaymentModel(
      cardNumber: '4242 4242 4242 4242',
      holderName: 'A B',
      expiry: '12/30',
      cvv: '123',
    );

    test('başarılı ve reddedilen test kartı', () async {
      final c = PaymentController(processingDelay: Duration.zero);
      expect(c.state.value, PaymentState.initial);
      expect(await c.pay(ok), isTrue);
      expect(c.state.value, PaymentState.success);

      final declined = PaymentController(processingDelay: Duration.zero);
      const bad = PaymentModel(
        cardNumber: '4242 4242 4242 0000',
        holderName: 'A B',
        expiry: '12/30',
        cvv: '123',
      );
      expect(await declined.pay(bad), isFalse);
      expect(declined.state.value, PaymentState.failure);
      expect(declined.errorKey.value, 'err_payment_declined');
    });
  });

  group('ActiveRentalsController + RentalMapController', () {
    test('başlat, uzat, km ekle, bitir ve kalıcılık', () async {
      var now = DateTime(2026, 10, 21, 12);
      final storage = await newStorage();
      final rentals = ActiveRentalsController(storage, clock: () => now);
      final map = RentalMapController(
        vehicles: VehicleCatalog.vehicles,
        activeRentals: rentals.rentals,
      );
      final vehicle = VehicleCatalog.vehicles.first;
      expect(map.available.value.length, VehicleCatalog.vehicles.length);

      final rental = rentals.start(vehicle, const RentalPlan.package('hour1'));
      expect(rentals.rentals.value.single.id, rental.id);
      // Kiralanan araç haritadan düşer.
      expect(map.available.value.any((v) => v.id == vehicle.id), isFalse);

      expect(rentals.extendTime(rental.id, 30), closeTo(30 * 2.90, 1e-9));
      expect(rentals.addKm(rental.id, 10), closeTo(10 * 2.90, 1e-9));
      final updated = rentals.rentals.value.single;
      expect(updated.includedMinutes, 90);
      expect(updated.includedKm, 40);
      expect(updated.extras.length, 2);

      // Yeniden açılışta kalıcı.
      final reloaded = ActiveRentalsController(storage, clock: () => now);
      expect(reloaded.rentals.value.single.extras.length, 2);
      reloaded.dispose();

      now = now.add(const Duration(minutes: 80));
      final summary = rentals.finish(rental.id)!;
      expect(summary.baseFee, 150);
      expect(summary.extrasFee, closeTo(116, 1e-9));
      expect(summary.overageFee, 0);
      expect(rentals.rentals.value, isEmpty);
      expect(map.available.value.length, VehicleCatalog.vehicles.length);

      map.dispose();
      rentals.dispose();
    });

    test('dakikalıkta süre/km eklenemez', () async {
      final rentals = ActiveRentalsController(await newStorage());
      final r = rentals.start(
        VehicleCatalog.vehicles.first,
        const RentalPlan.perMinute(),
      );
      expect(rentals.extendTime(r.id, 15), 0);
      expect(rentals.addKm(r.id, 10), 0);
      expect(rentals.rentals.value.single.extras, isEmpty);
      rentals.dispose();
    });
  });

  group('StorageService', () {
    test('bozuk JSON varsayılana döner', () async {
      final storage = await newStorage({
        'tiknow.user': '{bozuk',
        'tiknow.active_rentals': 'xx',
      });
      expect(storage.loadUser(), isNull);
      expect(storage.loadRentals(), isEmpty);
    });
  });
}
