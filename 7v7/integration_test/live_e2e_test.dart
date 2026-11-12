// CANLI Firebase uçtan uca testi — uygulama mağazadan indirilmiş gibi:
// emülatör yok, demo verisi yok. Gerçek arayüzle iki hesap açılır, giriş
// yapılır, iki kullanıcı arasında davet → kabul → maç → mesaj akışı canlı
// güvenlik kuralları ve indekslere karşı çalıştırılır, ekranlar canlı veriyle
// gezilir. Kişisel veri gizliliği ve uygulama içinden hesap silme denetlenir.
// Tüm test hesapları uygulamanın kendi hesap silme akışıyla temizlenir;
// ardından canlı projede hiçbir şey kalmamalıdır
// (`firebase auth:export` 0 hesap, `firestore:delete --all-collections` boş).
//
// Yalnızca bilerek çalıştırılır:
//   flutter test integration_test/live_e2e_test.dart -d <simülatör> \
//     --dart-define=LIVE_E2E=true
import 'dart:math';

import 'package:app_7v7/app/app.dart';
import 'package:app_7v7/app/theme/theme_controller.dart';
import 'package:app_7v7/core/widgets/app_button.dart';
import 'package:app_7v7/core/widgets/app_link.dart';
import 'package:app_7v7/core/widgets/option_tile.dart';
import 'package:app_7v7/core/widgets/app_text_field.dart';
import 'package:app_7v7/core/widgets/icon_circle_button.dart';
import 'package:app_7v7/core/widgets/notification_bell.dart';
import 'package:app_7v7/features/auth/widgets/auth_widgets.dart';
import 'package:app_7v7/firebase_options.dart';
import 'package:app_7v7/l10n/app_localizations.dart';
import 'package:app_7v7/models/appointment_model.dart';
import 'package:app_7v7/models/draft_model.dart';
import 'package:app_7v7/models/invite_model.dart';
import 'package:app_7v7/models/player_model.dart';
import 'package:app_7v7/models/user_model.dart';
import 'package:app_7v7/services/account_service.dart';
import 'package:app_7v7/services/appointment_service.dart';
import 'package:app_7v7/services/auth_service.dart';
import 'package:app_7v7/services/chat_service.dart';
import 'package:app_7v7/services/draft_service.dart';
import 'package:app_7v7/services/firebase_providers.dart';
import 'package:app_7v7/services/invite_service.dart';
import 'package:app_7v7/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _live = bool.fromEnvironment('LIVE_E2E');
const _pw = 'E2e-Canli-2026!';

class _Acct {
  _Acct(this.first, this.last, this.email, this.phone);
  final String first, last, email, phone;
  String uid = '';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canlı: kayıt, giriş, davet, maç, mesaj, ekranlar', (t) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    expect(db.app.options.projectId, 'sevenv7-hali-saha');
    await auth.signOut();

    final authSvc = AuthService(auth, db);
    final inv = InviteService(db);
    final drafts = DraftService(db);
    final appts = AppointmentService(db);
    final chats = ChatService(db);
    final notifs = NotificationService(db);
    const server = GetOptions(source: Source.server);

    final run = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final rnd = Random();
    String phone() => '0555 ${100 + rnd.nextInt(900)} ${10 + rnd.nextInt(90)} ${10 + rnd.nextInt(90)}';
    // Karışık harfli e-posta: kayıt küçük harfe çevirmeli (phoneIndex kuralı).
    final a = _Acct('Arda', 'Canlı', 'E2E.Arda.$run@Example.com', phone());
    final b = _Acct('Berk', 'Canlı', 'e2e.berk.$run@example.com', phone());

    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const SevenApp(),
    ));

    AppLocalizations l() => AppLocalizations.of(t.element(find.byType(Scaffold).last));

    Future<void> until(Finder f, {int secs = 40}) async {
      final end = DateTime.now().add(Duration(seconds: secs));
      while (f.evaluate().isEmpty) {
        if (DateTime.now().isAfter(end)) {
          final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>();
          fail('ekranda bulunamadı: $f\nEKRAN: ${texts.join(' | ')}');
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await t.pump();
      }
    }

    Future<void> settle([int ms = 800]) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await t.pump();
      }
    }

    Future<void> tap(Finder f) async {
      await until(f);
      await t.ensureVisible(f.first);
      await t.pump();
      await t.tap(f.first);
      await settle();
    }

    Finder field(String label) => find.descendant(
        of: find.widgetWithText(AppTextField, label), matching: find.byType(TextField));
    Finder button(String label) => find.widgetWithText(AppButton, label);

    Future<void> type(String label, String text) async {
      await until(field(label));
      await t.ensureVisible(field(label));
      await t.enterText(field(label), text);
      await t.pump();
    }

    Future<void> back() async {
      // Ekranın sol üstündeki geri düğmesi (ağaçtaki ilk yuvarlak düğme).
      await tap(find.byType(IconCircleButton));
    }

    final cleanup = <_Acct>[];
    try {
      // ---------- Hoş geldin → Giriş ----------
      await until(find.byType(Scaffold));
      await settle(1500);
      if (button(l().onbStart).evaluate().isNotEmpty) await tap(button(l().onbStart));
      await until(button(l().siBtn));
      expect(find.text('Demo hesabıyla dene'), findsNothing);
      expect(find.text('Try the demo account'), findsNothing);

      Future<void> signUpUi(_Acct x) async {
        await tap(find.widgetWithText(AppLink, l().toSignup));
        await until(button(l().suBtn));
        await type(l().fFirst, x.first);
        await type(l().fLast, x.last);
        await type(l().fEmail, x.email);
        await type(l().fPhone, x.phone);
        await type(l().fPw, _pw);
        FocusManager.instance.primaryFocus?.unfocus();
        await settle(400);
        for (var i = 0; i < 2; i++) {
          await tap(find.descendant(
              of: find.byType(AgreeCheck).at(i), matching: find.byType(GestureDetector)).first);
        }
        await tap(button(l().suBtn));
        // Başarılıysa giriş ekranına döner (e-posta dolu).
        await until(button(l().siBtn), secs: 60);
        cleanup.add(x);
      }

      Future<void> signInUi(_Acct x, String ident) async {
        await type(l().fEmail, ident);
        await type(l().fPw, _pw);
        await tap(button(l().siBtn));
        await until(find.text(l().tabTeam), secs: 60);
        await settle(1500);
        x.uid = auth.currentUser!.uid;
      }

      String digits(_Acct x) => x.phone.replaceAll(' ', '').substring(1);

      Future<void> signOutUi() async {
        await tap(find.text(l().tabProfile));
        await tap(button(l().signOut));
        await until(button(l().siBtn));
      }

      // ---------- A: kayıt (arayüz) + karışık harfli e-postayla giriş ----------
      await signUpUi(a);
      await signInUi(a, a.email);
      // Profil herkese açık alanlar; e-posta / telefon yalnızca sahibine açık belgede.
      final pubA = (await db.users.doc(a.uid).get(server)).data()!;
      expect(pubA.keys, isNot(contains('email')));
      expect(pubA.keys, isNot(contains('phone')));
      final contactA = (await db.contactOf(a.uid).get(server)).data()!;
      expect(contactA['email'], a.email.toLowerCase());
      expect((await db.phoneIndex.doc(digits(a)).get(server)).data(), {'uid': a.uid});
      await signOutUi();

      // ---------- B: kayıt (arayüz) + BÜYÜK harfli e-postayla giriş ----------
      await signUpUi(b);
      await signInUi(b, b.email.toUpperCase());
      // B, A'nın iletişim bilgilerini ve telefon kaydını okuyamaz.
      await expectLater(db.contactOf(a.uid).get(server), throwsA(isA<FirebaseException>()));
      await expectLater(
          db.phoneIndex.doc(digits(a)).get(server), throwsA(isA<FirebaseException>()));
      // Tüm canlı sorgular (indeks / izin hatası olmadan) açılır.
      await appts.watchMine(b.uid).first.timeout(const Duration(seconds: 20));
      await inv.watchIncoming(b.uid).first.timeout(const Duration(seconds: 20));
      await inv.watchOutgoing(b.uid).first.timeout(const Duration(seconds: 20));
      await chats.watchChats(b.uid).first.timeout(const Duration(seconds: 20));
      await notifs.watch(b.uid).first.timeout(const Duration(seconds: 20));
      await signOutUi();
      // Oturumsuz telefon dizini okunamaz (telefon → kişi eşlemesi sızmaz).
      await expectLater(
          db.phoneIndex.doc(digits(b)).get(server), throwsA(isA<FirebaseException>()));

      // ---------- C: B'nin telefonuyla kayıt reddedilir, yetim hesap kalmaz ----------
      final c = _Acct('Cem', 'Canlı', 'e2e.cem.$run@example.com', b.phone);
      await tap(find.widgetWithText(AppLink, l().toSignup));
      await until(button(l().suBtn));
      await type(l().fFirst, c.first);
      await type(l().fLast, c.last);
      await type(l().fEmail, c.email);
      await type(l().fPhone, c.phone);
      await type(l().fPw, _pw);
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(400);
      for (var i = 0; i < 2; i++) {
        await tap(find.descendant(
            of: find.byType(AgreeCheck).at(i), matching: find.byType(GestureDetector)).first);
      }
      await tap(button(l().suBtn));
      await until(find.text(l().ePhoneExists), secs: 60);
      expect(auth.currentUser, isNull);
      await expectLater(authSvc.signIn(c.email, _pw), throwsA(isA<AuthFailure>()));
      await tap(find.widgetWithText(AppLink, l().toSignin));
      await until(button(l().siBtn));

      // Şifre sıfırlama e-postası canlıda gönderilebilir.
      await authSvc.sendPasswordReset(a.email);

      // ---------- A: taslak + B'ye davet ----------
      await authSvc.signIn(a.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      final ub = UserModel.fromDoc(await db.users.doc(b.uid).get(server));
      PlayerModel p(String s, String f) => PlayerModel(slot: s, firstName: f, lastName: 'Test');
      final d0 = DraftModel(
        formation: '2-3-1',
        city: 'İzmir',
        district: 'Bornova',
        stadium: 'Bornova Arena',
        matchTime: '21:00',
        players: {
          'gk': p('gk', 'Kaleci'),
          'd1': p('d1', 'Defans'),
          'd2': p('d2', 'Bek'),
          'm1': p('m1', 'Orta'),
          'm3': p('m3', 'Kanat'),
          'a1': p('a1', 'Forvet'),
        },
      );
      await drafts.write(a.uid, d0);
      final inviteId =
          await inv.send(senderId: a.uid, receiverId: b.uid, draft: d0, offeredSlot: 'm2');

      // ---------- B: bildirim + kabul + mesaj ----------
      await authSvc.signOut();
      await authSvc.signIn(b.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      expect((await db.notificationsOf(b.uid).doc('invite_$inviteId').get(server)).exists, isTrue);
      final incoming = await inv
          .watchIncoming(b.uid)
          .firstWhere((x) => x.any((v) => v.id == inviteId))
          .timeout(const Duration(seconds: 20));
      expect(incoming.first.isPending, isTrue);
      await inv.respond(inviteId: inviteId, accept: true, me: ub);
      expect((await db.friendships.doc(pairId(a.uid, b.uid)).get(server)).exists, isTrue);

      // ---------- A: kabulü taslağa işle, maçı kaydet ----------
      await authSvc.signOut();
      await authSvc.signIn(a.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      final out = await inv
          .watchOutgoing(a.uid)
          .firstWhere((x) => x.any((v) => v.id == inviteId && v.isAccepted))
          .timeout(const Duration(seconds: 20));
      final accepted = out.firstWhere((v) => v.id == inviteId);
      await drafts.applyAccepted(a.uid, accepted, ub);
      await settle(3000);
      final d1 = DraftModel.fromDoc(await db.drafts.doc(a.uid).get(server));
      final vPost = InviteModel.fromDoc(await db.invites.doc(inviteId).get(server));
      expect(vPost.appliedToDraft, isTrue);
      expect(d1.players.length, 7);
      expect(d1.players['m2']?.firstName, b.first);
      final apptId = await appts.save(
          ownerId: a.uid,
          draft: d1,
          linkInvites: [InviteModel.fromDoc(await db.invites.doc(inviteId).get(server))]);
      final mine = await appts
          .watchMine(a.uid)
          .firstWhere((x) => x.any((v) => v.id == apptId))
          .timeout(const Duration(seconds: 20));
      expect(mine.single.memberIds.toSet(), {a.uid, b.uid});

      // ---------- B: davetli olarak görür, mesaj atar ----------
      await authSvc.signOut();
      await authSvc.signIn(b.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      final guest = await appts
          .watchMine(b.uid)
          .firstWhere((x) => x.any((v) => v.id == apptId))
          .timeout(const Duration(seconds: 20));
      expect(guest.single.ownerId, a.uid);
      expect((await db.notificationsOf(b.uid).doc('match_$apptId').get(server)).exists, isTrue);
      await chats.send(me: b.uid, other: a.uid, text: 'Geliyorum, 21:00');
      await chats
          .watchChats(b.uid)
          .firstWhere((x) => x.isNotEmpty)
          .timeout(const Duration(seconds: 20));

      // ---------- A: arayüzde canlı veriyle ekranlar ----------
      await authSvc.signOut();
      await authSvc.signIn(a.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      final n = await notifs
          .watch(a.uid)
          .firstWhere((x) => x.length >= 2)
          .timeout(const Duration(seconds: 20));
      expect(n.map((x) => x.type.name).toSet(), containsAll(['inviteAccepted', 'message']));

      await tap(find.text(l().tabAppts));
      await until(find.textContaining('Bornova Arena'));
      await tap(find.textContaining('Bornova Arena'));
      await until(find.textContaining('${b.first} ${b.last}'));
      expect(t.takeException(), isNull);
      await back();
      await settle(1200);

      await tap(find.text(l().tabSocial));
      await until(find.textContaining(b.first));
      // Arkadaş satırında "Maça davet et" görünmeli (arkadaşlık canlı okunur).
      await until(button(l().invFriend), secs: 20);
      await tap(find.descendant(of: find.byType(AppSegment), matching: find.text(l().soChats)));
      await until(find.textContaining('Geliyorum'));
      await tap(find.textContaining('Geliyorum'));
      await until(find.text('Geliyorum, 21:00'));
      await t.enterText(find.byType(TextField).last, 'Tamam, görüşürüz');
      await t.testTextInput.receiveAction(TextInputAction.send);
      await settle(2000);
      await until(find.text('Tamam, görüşürüz'), secs: 20);
      await back();
      await settle(1200);

      await tap(find.text(l().tabTeam));
      await tap(find.byType(NotificationBell));
      await until(find.textContaining(b.first));
      expect(t.takeException(), isNull);
      await back();
      await settle(1000);

      final appt = AppointmentModel.fromDoc(await db.appointments.doc(apptId).get(server));
      expect(appt.players.length, 7);
      final pairChat = pairId(a.uid, b.uid);

      // ---------- B: hesabını uygulamadan siler (arayüz) ----------
      await authSvc.signOut();
      await authSvc.signIn(b.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      await settle(1500);
      await tap(find.text(l().tabProfile));
      // Yanlış şifre: hata gösterilir, hiçbir şey silinmez.
      await tap(button(l().delAcct));
      await until(button(l().delBtn));
      await type(l().fPw, 'yanlis-sifre-123');
      await tap(button(l().delBtn));
      await until(find.text(l().eWrongpw), secs: 30);
      expect(auth.currentUser?.uid, b.uid);
      // Alanı yeniden odaklayıp doğru şifreyi yaz (önceki metnin yerine).
      await t.tap(field(l().fPw));
      await settle(300);
      await t.enterText(field(l().fPw), _pw);
      await settle(300);
      expect(find.text(l().eWrongpw), findsNothing);
      await tap(button(l().delBtn));
      await until(button(l().siBtn), secs: 90);
      expect(auth.currentUser, isNull);
      cleanup.remove(b);
      await expectLater(authSvc.signIn(b.email, _pw), throwsA(isA<AuthFailure>()));

      // ---------- A: B'den iz kalmadı, ekranlar çökmeden açılır ----------
      await authSvc.signIn(a.email, _pw);
      await until(find.text(l().tabTeam), secs: 60);
      await settle(1500);
      expect((await db.users.doc(b.uid).get(server)).exists, isFalse);
      expect((await db.friendships.doc(pairChat).get(server)).exists, isFalse);
      expect((await db.chats.doc(pairChat).get(server)).exists, isFalse);
      expect((await db.chats.doc(pairChat).collection('messages').get(server)).docs, isEmpty);
      expect((await db.invites.doc(inviteId).get(server)).exists, isFalse);
      final apptAfter = AppointmentModel.fromDoc(await db.appointments.doc(apptId).get(server));
      expect(apptAfter.memberIds, [a.uid]);
      await tap(find.text(l().tabSocial));
      await settle(2500);
      expect(find.textContaining(b.first), findsNothing);
      await tap(find.text(l().tabAppts));
      await until(find.textContaining('Bornova Arena'));
      await tap(find.text(l().tabTeam));
      await tap(find.byType(NotificationBell));
      await settle(2500);
      expect(t.takeException(), isNull);
      // B'nin A'ya bıraktığı bildirimler (kabul, mesaj) da silindi.
      expect((await db.notificationsOf(a.uid).doc('resp_$inviteId').get(server)).exists, isFalse);
      expect((await db.notificationsOf(a.uid).doc('msg_$pairChat').get(server)).exists, isFalse);
      await back();
      await settle(1000);

      // ---------- B'nin telefonu yeniden kullanılabilir ----------
      await authSvc.signOut();
      await authSvc.signUp(
          firstName: c.first,
          lastName: c.last,
          email: c.email,
          phone: c.phone,
          password: _pw,
          locale: 'tr',
          themeMode: 'light');
      cleanup.add(c);
    } finally {
      // Kalan test hesapları uygulamanın kendi silme akışıyla silinir.
      for (final x in cleanup) {
        try {
          await auth.signOut();
          await auth.signInWithEmailAndPassword(email: x.email.toLowerCase(), password: _pw);
          await AccountService(auth, db).deleteAccount(_pw);
          debugPrint('E2E_ACCOUNT_DELETED ${x.email}');
        } catch (e) {
          debugPrint('E2E_ACCOUNT_DELETE_FAILED ${x.email}: $e');
        }
      }
      await auth.signOut();
      await settle(500);
    }
  }, skip: !_live);
}
