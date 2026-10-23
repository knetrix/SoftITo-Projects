import 'package:flutter_test/flutter_test.dart';
import 'package:money_habit_tracker/core/services/local_storage_service.dart';
import 'package:money_habit_tracker/features/auth/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalStorageService storage;
  late AuthController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await LocalStorageService.init();
    controller = AuthController(storage);
  });

  tearDown(() {
    controller.dispose();
  });

  test('başlangıçta oturum kapalı ve kullanıcı boştur', () {
    expect(controller.state.value.status, AuthStatus.initial);
    expect(controller.state.value.user, isNull);
    expect(storage.isLoggedIn, isFalse);
  });

  test('başarılı kayıt oturumu açar ve kullanıcıyı kaydeder', () async {
    final success = await controller.register(
      email: 'test@moneyhabit.com',
      phone: '05551234567',
      password: 'Password123',
    );

    expect(success, isTrue);
    expect(controller.state.value.status, AuthStatus.success);
    expect(controller.state.value.user?.email, 'test@moneyhabit.com');
    expect(controller.state.value.user?.phone, '5551234567');
    expect(storage.isLoggedIn, isTrue);
  });

  test('aynı e-posta ile kayıt olmaya çalışmak başarısız olur', () async {
    await controller.register(
      email: 'test@moneyhabit.com',
      phone: '05551234567',
      password: 'Password123',
    );

    final secondAttempt = await controller.register(
      email: 'test@moneyhabit.com',
      phone: '05559998877',
      password: 'Password123',
    );

    expect(secondAttempt, isFalse);
    expect(controller.state.value.status, AuthStatus.failure);
    expect(controller.state.value.errorMessage, 'userAlreadyExists');
  });

  test('doğru şifre ile giriş başarılı olur', () async {
    await controller.register(
      email: 'user@example.com',
      phone: '05551234567',
      password: 'MyPassword1',
    );

    await controller.logout();
    expect(storage.isLoggedIn, isFalse);

    final loginSuccess = await controller.login(
      email: 'user@example.com',
      password: 'MyPassword1',
    );

    expect(loginSuccess, isTrue);
    expect(controller.state.value.status, AuthStatus.success);
    expect(storage.isLoggedIn, isTrue);
  });

  test('yanlış şifre ile giriş başarısız olur', () async {
    await controller.register(
      email: 'user@example.com',
      phone: '05551234567',
      password: 'MyPassword1',
    );

    await controller.logout();

    final loginSuccess = await controller.login(
      email: 'user@example.com',
      password: 'WrongPassword1',
    );

    expect(loginSuccess, isFalse);
    expect(controller.state.value.status, AuthStatus.failure);
    expect(storage.isLoggedIn, isFalse);
  });

  test('quickLogin test kullanıcısını oluşturup giriş yapar', () async {
    final success = await controller.quickLogin();
    expect(success, isTrue);
    expect(controller.state.value.user?.email, AuthController.testEmail);
    expect(storage.isLoggedIn, isTrue);
  });
}
