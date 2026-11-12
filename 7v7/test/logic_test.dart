import 'package:app_7v7/core/utils/formation.dart';
import 'package:app_7v7/core/utils/phone.dart';
import 'package:app_7v7/core/utils/time_format.dart';
import 'package:app_7v7/core/utils/validators.dart';
import 'package:app_7v7/features/appointments/appointments_screen.dart';
import 'package:app_7v7/features/social/widgets/invite_sheet.dart';
import 'package:app_7v7/features/team/team_actions.dart';
import 'package:app_7v7/models/appointment_model.dart';
import 'package:app_7v7/models/draft_model.dart';
import 'package:app_7v7/models/player_model.dart';
import 'package:app_7v7/services/appointment_service.dart';
import 'package:flutter_test/flutter_test.dart';

PlayerModel p(String slot, String first, [String last = '']) =>
    PlayerModel(slot: slot, firstName: first, lastName: last);

void main() {
  group('validators (§3 ekran 02/03)', () {
    test('e-posta', () {
      expect(Validators.email('kerem@7v7.app'), isNull);
      expect(Validators.email('demo@7v7'), 'eEmail');
      expect(Validators.email(''), 'eEmail');
    });
    test('telefon: 10 hane, 5 ile başlar, +90 / 0 öneki', () {
      expect(phoneOk('0532 418 27 90'), isTrue);
      expect(phoneOk('+90 532 418 27 90'), isTrue);
      expect(phoneOk('5324182790'), isTrue);
      expect(phoneOk('0432 418 27 90'), isFalse);
      expect(phoneOk('0532 418 27'), isFalse);
      expect(normPhone('+90 (532) 418-27-90'), '5324182790');
      expect(formatPhone('5324182790'), '0532 418 27 90');
    });
    test('şifre', () {
      expect(Validators.newPassword(''), 'ePassword');
      expect(Validators.newPassword('1234567'), 'ePwlen');
      expect(Validators.newPassword('demo12345'), isNull);
      expect(Validators.password('x'), isNull);
    });
    test('ad / soyad / kimlik', () {
      expect(Validators.firstName('  '), 'eFirst');
      expect(Validators.lastName(''), 'eLast');
    });
    test(
      'aynı oyuncu (§5.2-2): tr büyük/küçük harf, soyad boşsa yalnız ad',
      () {
        expect(samePlayer('İsmail', '', 'ismail', 'Kaya'), isTrue);
        expect(samePlayer('Irmak', 'Kaya', 'ırmak', 'KAYA'), isTrue);
        expect(samePlayer('Ali', 'Kaya', 'Ali', 'Demir'), isFalse);
        expect(samePlayer('Ali', '', 'Veli', ''), isFalse);
      },
    );
  });

  group('dizilişler ve saha (§5.1, §2.8)', () {
    test('her dizilişte 7 mevki, kaleci ilk', () {
      for (final f in Formation.all) {
        final s = slotsOf(f.id);
        expect(s.length, 7, reason: f.id);
        expect(s.first.id, 'gk');
      }
    });
    test(
      'koordinatlar: 3 çizgi 67/43/19, 2 çizgi 62/25; x 50 / 30-70 / 17-50-83',
      () {
        final f = '2-3-1';
        final xy = {for (final s in slotsOf(f)) s.id: slotXY(f, s)};
        expect(xy['gk'], (x: 50.0, y: 87.0));
        expect(xy['d1'], (x: 30.0, y: 67.0));
        expect(xy['d2'], (x: 70.0, y: 67.0));
        expect([xy['m1']!.x, xy['m2']!.x, xy['m3']!.x], [17.0, 50.0, 83.0]);
        expect(xy['m1']!.y, 43.0);
        expect(xy['a1'], (x: 50.0, y: 19.0));

        final g = '3-3';
        final ys = {for (final s in slotsOf(g)) s.id: slotXY(g, s).y};
        expect(ys['d1'], 62.0);
        expect(ys['a1'], 25.0);
      },
    );
    test('yelek numarası ve mevki adı', () {
      expect(bibNumber('2-3-1', 'gk'), 1);
      expect(bibNumber('2-3-1', 'm1'), 4);
      expect(bibNumber('2-3-1', 'a1'), 7);
      String name(Line l) => l.name;
      expect(positionName(slotInfo('2-3-1', 'd2'), name), 'def 2');
      expect(positionName(slotInfo('2-3-1', 'a1'), name), 'att');
    });
  });

  group('diziliş değişimi (§5.2-1)', () {
    test('açıkta kalan oyuncular boş mevkilere sırayla taşınır', () {
      final r = changeFormation<PlayerModel>(
        from: '2-3-1',
        to: '3-3',
        players: {
          'gk': p('gk', 'Emre'),
          'd1': p('d1', 'Tolga'),
          'm1': p('m1', 'Burak'),
          'm3': p('m3', 'Arda'),
          'a1': p('a1', 'Mert'),
        },
        pendingBySlot: const {},
      );
      expect(r.players.keys.toSet(), {'gk', 'd1', 'a1', 'd2', 'd3'});
      expect(
        r.moved.map((m) => ((m.$1 as PlayerModel).firstName, m.$2.id)).toList(),
        [('Burak', 'd2'), ('Arda', 'd3')],
      );
    });
    test(
      'bekleyen davetin tuttuğu mevkiye oyuncu taşınmaz; davet de taşınır',
      () {
        final r = changeFormation<PlayerModel>(
          from: '2-3-1',
          to: '3-2-1',
          players: {'m3': p('m3', 'Arda')},
          pendingBySlot: const {'d1': 'inviteA', 'm2': 'inviteB'},
        );
        // m3 yok: Arda ilk serbest mevkiye (kaleci) geçer; d1 tutulu kalır.
        expect(r.players.keys, ['gk']);
        expect(r.players['gk']!.firstName, 'Arda');
        expect(r.inviteMoves, isEmpty);

        final r2 = changeFormation<PlayerModel>(
          from: '2-3-1',
          to: '3-3',
          players: {'gk': p('gk', 'Emre')},
          pendingBySlot: const {'m2': 'inviteB'},
        );
        expect(r2.inviteMoves, {'m2': 'd1'});
      },
    );
  });

  group('eksik kontrolü (§5.3)', () {
    test('boş taslak', () {
      expect(missingOf(DraftModel.empty).map((m) => m.key), [
        'mFormation',
        'mCity',
        'mDistrict',
        'mStadium',
        'mTime',
      ]);
    });
    test('oyuncu eksiği sayılır', () {
      final d = DraftModel(
        formation: '2-3-1',
        city: 'İzmir',
        district: 'Bornova',
        stadium: 'Bornova Halı Saha',
        matchTime: '21:00',
        players: {'gk': p('gk', 'Emre')},
      );
      expect(missingOf(d), [(key: 'mPlayers', n: 6)]);
    });
  });

  group('davet kuralları (§5.4)', () {
    final d = DraftModel(
      formation: '2-3-1',
      city: 'İzmir',
      district: 'Bornova',
      stadium: 'Bornova Halı Saha',
      matchTime: '21:00',
      players: {
        'gk': p('gk', 'Emre'),
        'd1': p('d1', 'Tolga'),
        'm1': p('m1', 'Burak'),
        'm3': p('m3', 'Arda'),
        'a1': p('a1', 'Mert'),
      },
    );
    test('teklif edilebilen: boş ve davetle tutulmamış mevkiler, sırayla', () {
      expect(openSlotsOf(d, const {'d2'}).map((s) => s.id), ['m2']);
      expect(openSlotsOf(d, const {}).map((s) => s.id), ['d2', 'm2']);
    });
    test('taslak hazır değilse davet gönderilemez', () {
      expect(draftReady(d), isTrue);
      expect(draftReady(d.copyWith(matchTime: null)), isFalse);
      expect(draftReady(DraftModel.empty), isFalse);
    });
  });

  group('Randevularım arama ve filtre (§3 ekran 05)', () {
    final a = Booking.own(
      AppointmentModel(
        id: 'a1',
        ownerId: 'u0',
        memberIds: const ['u0'],
        formation: '2-3-1',
        city: 'İzmir',
        district: 'Bornova',
        stadium: 'Bornova Arena',
        matchTime: '21:00',
        players: [p('gk', 'Emre', 'Yıldız')],
      ),
    );
    test('saha, ilçe, il ve oyuncu adı (tr küçük harf)', () {
      expect(bookingMatches(a, 'bornova'), isTrue);
      expect(bookingMatches(a, 'İZMİR'), isTrue);
      expect(bookingMatches(a, 'yıldız'), isTrue);
      expect(bookingMatches(a, 'Trabzon'), isFalse);
    });
    test('Gündüz = 06:00–16:00 başlangıç', () {
      expect(isDaytime('06:00'), isTrue);
      expect(isDaytime('16:00'), isTrue);
      expect(isDaytime('17:00'), isFalse);
      expect(bookingMatches(a, '', day: false), isTrue);
      expect(bookingMatches(a, '', day: true), isFalse);
    });
    test('saat aralığı', () {
      expect(timeRange('21:00'), '21:00–22:00');
      expect(timeRange('09:00'), '09:00–10:00');
    });
  });
}
