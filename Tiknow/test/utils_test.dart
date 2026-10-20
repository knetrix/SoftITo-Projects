import 'package:flutter_test/flutter_test.dart';
import 'package:tiknow/core/utils/distance_calculator.dart';
import 'package:tiknow/core/utils/duration_formatter.dart';
import 'package:tiknow/core/utils/money_formatter.dart';
import 'package:tiknow/core/utils/password_hasher.dart';

void main() {
  group('MoneyFormatter', () {
    test('TL biçimi', () {
      expect(MoneyFormatter.format(2.95), '2,95 TL');
      expect(MoneyFormatter.format(150), '150,00 TL');
      expect(MoneyFormatter.format(1250.5), '1.250,50 TL');
      expect(MoneyFormatter.format(0), '0,00 TL');
      expect(MoneyFormatter.rate(2.95, 'dk'), '2,95 TL/dk');
    });
  });

  group('DistanceCalculator', () {
    test('haversine: aynı nokta 0', () {
      expect(DistanceCalculator.haversineMeters(41, 29, 41, 29), 0);
    });
    test('haversine: 1 derece enlem ~111 km', () {
      final d = DistanceCalculator.haversineMeters(41, 29, 42, 29);
      expect(d, closeTo(111195, 300));
    });
    test('yürüme süresi: metre × 1,3 ÷ 80 yukarı yuvarlanır', () {
      expect(DistanceCalculator.walkingMinutesForMeters(0), 0);
      expect(DistanceCalculator.walkingMinutesForMeters(80), 2); // 104/80
      expect(DistanceCalculator.walkingMinutesForMeters(800), 13); // 1040/80
      expect(DistanceCalculator.walkingMinutesForMeters(615), 10); // 799.5/80
    });
    test('Taksim - Cihangir birkaç dakika', () {
      final m = DistanceCalculator.walkingMinutes(41.0370, 28.9850, 41.0320, 28.9830);
      // ~580 m düz mesafe × 1,3 ÷ 80 m/dk = 9,4 -> 10 dk
      expect(m, 10);
    });
  });

  group('DurationFormatter', () {
    test('dakika biçimi', () {
      String f(int m) => DurationFormatter.minutes(m, hourUnit: 'sa', minuteUnit: 'dk');
      expect(f(45), '45 dk');
      expect(f(60), '1 sa');
      expect(f(90), '1 sa 30 dk');
      expect(f(1440), '24 sa');
    });
    test('sayaç', () {
      expect(DurationFormatter.clock(3725), '01:02:05');
      expect(DurationFormatter.clock(-61), '00:01:01');
    });
  });

  group('PasswordHasher', () {
    test('düz metin saklanmaz, doğrulama çalışır', () {
      final salt = PasswordHasher.generateSalt();
      final hash = PasswordHasher.hash('Abcdefg1', salt);
      expect(hash, isNot(contains('Abcdefg1')));
      expect(hash.length, 64);
      expect(PasswordHasher.verify('Abcdefg1', salt, hash), isTrue);
      expect(PasswordHasher.verify('abcdefg1', salt, hash), isFalse);
      expect(PasswordHasher.hash('Abcdefg1', 'başka'), isNot(hash));
    });
  });
}
