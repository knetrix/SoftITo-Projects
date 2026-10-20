import 'package:flutter_test/flutter_test.dart';
import 'package:tiknow/features/active_rentals/models/active_rental_model.dart';
import 'package:tiknow/features/rental_map/models/vehicle_catalog.dart';
import 'package:tiknow/features/rental_packages/models/rental_package_model.dart';

void main() {
  final t0 = DateTime(2026, 10, 21, 12);
  final vehicle = VehicleCatalog.vehicles.first; // 2,95 TL/dk

  ActiveRentalModel start(RentalPlan plan) => ActiveRentalModel.start(
        id: 'r1',
        vehicle: vehicle,
        plan: plan,
        now: t0,
      );

  group('dakikalık', () {
    final rental = start(const RentalPlan.perMinute());
    test('geçen dakika × dakika fiyatı', () {
      final s = rental.summaryAt(t0.add(const Duration(minutes: 10)));
      expect(s.elapsedMinutes, 10);
      expect(s.total, closeTo(10 * 2.95, 1e-9));
      expect(s.overageFee, 0);
    });
    test('başlanan dakika tam sayılır, en az 1 dk', () {
      expect(rental.elapsedMinutes(t0), 1);
      expect(rental.elapsedMinutes(t0.add(const Duration(seconds: 61))), 2);
      expect(rental.summaryAt(t0).total, closeTo(2.95, 1e-9));
    });
  });

  group('paket', () {
    final rental = start(const RentalPlan.package('hour1')); // 60 dk / 30 km / 150 TL
    test('hak içinde yalnızca paket ücreti', () {
      final s = rental.summaryAt(t0.add(const Duration(minutes: 40)));
      expect(s.baseFee, 150);
      expect(s.overageFee, 0);
      expect(s.total, 150);
    });
    test('süre aşımı dakika başına 2,90 TL', () {
      final s = rental.summaryAt(t0.add(const Duration(minutes: 70)));
      expect(rental.overMinutes(t0.add(const Duration(minutes: 70))), 10);
      expect(s.overageFee, closeTo(10 * 2.90 + _kmOverage(rental, 70), 1e-9));
    });
    test('km aşımı km başına 2,90 TL (simüle 0,5 km/dk)', () {
      final at = t0.add(const Duration(minutes: 80));
      expect(rental.usedKm(at), 40);
      expect(rental.overKm(at), 10);
    });
    test('kalan süre ve km', () {
      final at = t0.add(const Duration(minutes: 15));
      expect(rental.remainingSeconds(at), 45 * 60);
      expect(rental.remainingKm(at), 30 - 7);
    });
    test('ekler toplama eklenir ve hakkı artırır', () {
      final extended = rental.copyWith(
        includedMinutes: 90,
        includedKm: 40,
        extras: [
          RentalExtraModel(
            type: RentalExtraType.minutes,
            amount: 30,
            fee: 87,
            addedAt: t0,
          ),
          RentalExtraModel(
            type: RentalExtraType.km,
            amount: 10,
            fee: 29,
            addedAt: t0,
          ),
        ],
      );
      final at = t0.add(const Duration(minutes: 80));
      final s = extended.summaryAt(at);
      expect(s.overageFee, 0); // 80 < 90 dk, 40 km = 40 km
      expect(s.extrasFee, 116);
      expect(s.total, 150 + 116);
    });
  });

  test('JSON gidiş-dönüş', () {
    final rental = start(const RentalPlan.package('day')).copyWith(
      extras: [
        RentalExtraModel(
          type: RentalExtraType.km,
          amount: 10,
          fee: 26,
          addedAt: t0,
        ),
      ],
    );
    final back = ActiveRentalModel.fromJson(rental.toJson());
    expect(back.id, rental.id);
    expect(back.vehicle.model, vehicle.model);
    expect(back.plan, rental.plan);
    expect(back.startedAt, rental.startedAt);
    expect(back.extras.single.fee, 26);
    expect(back.includedKm, 250);
  });
}

double _kmOverage(ActiveRentalModel r, int minutes) {
  final at = DateTime(2026, 10, 21, 12).add(Duration(minutes: minutes));
  return r.overKm(at) * 2.90;
}
