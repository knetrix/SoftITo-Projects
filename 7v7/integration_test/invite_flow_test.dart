// Uçtan uca davet akışı (§4.4, §10 madde 7–9) — uygulamanın gerçek servis
// kodu, emülatördeki güvenlik kurallarına karşı, kullanıcı değiştirerek.
//
// Önce emülatörleri başlatıp test/emulator_seed/seed.js'i çalıştırın, sonra:
//   flutter test integration_test/invite_flow_test.dart -d <simülatör>
// Test, emülatördeki test verisini değiştirir; ardından seed'i yeniden çalıştırın.
import 'package:app_7v7/firebase_options.dart';
import 'package:app_7v7/models/appointment_model.dart';
import 'package:app_7v7/models/draft_model.dart';
import 'package:app_7v7/models/invite_model.dart';
import 'package:app_7v7/models/user_model.dart';
import 'package:app_7v7/services/appointment_service.dart';
import 'package:app_7v7/services/auth_service.dart';
import 'package:app_7v7/services/chat_service.dart';
import 'package:app_7v7/services/draft_service.dart';
import 'package:app_7v7/services/firebase_providers.dart';
import 'package:app_7v7/services/invite_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore db;
  late FirebaseAuth auth;
  late AuthService authSvc;
  late InviteService inv;
  late DraftService drafts;
  late AppointmentService appts;
  late ChatService chats;

  Future<void> as(String email) async {
    await auth.signOut();
    await authSvc.signIn(email, 'demo12345');
  }

  // Kullanıcı değiştikçe yerel önbellekte eski görüntü kalmasın: sunucudan oku.
  const server = GetOptions(source: Source.server);
  Future<UserModel> user(String uid) async =>
      UserModel.fromDoc(await db.users.doc(uid).get(server));
  Future<DraftModel> draft(String uid) async =>
      DraftModel.fromDoc(await db.drafts.doc(uid).get(server));
  Future<List<InviteModel>> outgoing(String uid) async =>
      (await db.invites.where('senderId', isEqualTo: uid).get(server))
          .docs
          .map(InviteModel.fromDoc)
          .toList();

  Future<void> denied(Future<void> f, String why) async {
    try {
      await f;
      fail('izin verilmemeliydi: $why');
    } on FirebaseException catch (e) {
      expect(e.code, 'permission-denied', reason: why);
    }
  }

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    await auth.useAuthEmulator('127.0.0.1', 9099);
    db.useFirestoreEmulator('127.0.0.1', 8080);
    db.settings = const Settings(persistenceEnabled: false);
    authSvc = AuthService(auth, db);
    inv = InviteService(db);
    drafts = DraftService(db);
    appts = AppointmentService(db);
    chats = ChatService(db);
  });

  testWidgets('§10-7: Kerem → Cem davet, kabul, taslağa işle, kaydet, Davetli, sil + geri al',
      (_) async {
    // 1) Kerem, Cem'e Orta Saha 2 teklif eder.
    await as('kerem@7v7.app');
    final d0 = await draft('u0');
    expect(d0.players.containsKey('m2'), isFalse);
    final cemInvite = await inv.send(senderId: 'u0', receiverId: 'u8', draft: d0, offeredSlot: 'm2');
    // Aynı çifte ikinci bekleyen davet reddedilir (inviteLocks).
    await denied(inv.send(senderId: 'u0', receiverId: 'u8', draft: d0, offeredSlot: 'm2'),
        'aynı kişiye ikinci bekleyen davet');

    // 2) Cem: bildirim + gelen davet; kabul eder.
    await as('cem@7v7.app');
    final cemNotif = await db.notificationsOf('u8').doc('invite_$cemInvite').get(server);
    expect(cemNotif.data()?['type'], 'invite');
    final incoming = (await db.invites.where('receiverId', isEqualTo: 'u8').get(server))
        .docs
        .map(InviteModel.fromDoc)
        .toList();
    expect(incoming.single.id, cemInvite);
    await inv.respond(inviteId: cemInvite, accept: true, me: await user('u8'));
    expect((await db.friendships.doc(pairId('u0', 'u8')).get()).exists, isTrue);

    // 3) Emir, Kerem'in bekleyen davetini (o3, Defans 2) kabul eder.
    await as('emir@7v7.app');
    await inv.respond(inviteId: 'o3', accept: true, me: await user('u6'));

    // 4) Kerem: kabuller taslağa işlenir (göndericinin kendi uygulaması).
    await as('kerem@7v7.app');
    for (final v in (await outgoing('u0')).where((v) => v.isAccepted && !v.appliedToDraft)) {
      await drafts.applyAccepted('u0', v, await user(v.receiverId));
    }
    final d1 = await draft('u0');
    expect(d1.players['m2']?.firstName, 'Cem');
    expect(d1.players['d2']?.firstName, 'Emir');
    expect(d1.players.length, 7);
    final resp = await db.notificationsOf('u0').doc('resp_$cemInvite').get(server);
    expect(resp.data()?['type'], 'inviteAccepted');

    // 5) Kaydet: kadroda adı geçen, kabul edilmiş, bağlanmamış davetler bağlanır
    //    (Burak o1, Cem, Emir o3).
    final names = d1.players.values.map((p) => p.fullName).toSet();
    final users = {for (final u in ['u2', 'u6', 'u8']) u: await user(u)};
    final link = [
      for (final v in await outgoing('u0'))
        if (v.isAccepted && v.appointmentId == null && names.contains(users[v.receiverId]?.fullName)) v,
    ];
    expect(link.map((v) => v.receiverId).toSet(), {'u2', 'u6', 'u8'});
    final apptId = await appts.save(ownerId: 'u0', draft: d1, linkInvites: link);
    final saved = AppointmentModel.fromDoc(await db.appointments.doc(apptId).get());
    expect(saved.memberIds.toSet(), {'u0', 'u2', 'u6', 'u8'});
    final d2 = await draft('u0');
    expect(d2.players, isEmpty);
    expect(d2.matchTime, isNull);
    expect(d2.formation, '2-3-1');

    // 6) Cem: randevunun üyesi + matchSaved bildirimi.
    await as('cem@7v7.app');
    final cemAppts = (await db.appointments.where('memberIds', arrayContains: 'u8').get(server))
        .docs
        .map(AppointmentModel.fromDoc)
        .toList();
    expect(cemAppts.map((a) => a.id), contains(apptId));
    final match = await db.notificationsOf('u8').doc('match_$apptId').get(server);
    expect(match.data()?['type'], 'matchSaved');
    // Davetli silemez.
    await denied(appts.delete(saved, const []), 'davetli randevuyu silemez');
    // Arkadaşa mesaj gider.
    await chats.send(me: 'u8', other: 'u0', text: 'Tamam, geliyorum');

    // 7) Kerem: sil → davetler ayrılır; geri al → yeniden bağlanır.
    await as('kerem@7v7.app');
    final linked = (await outgoing('u0')).where((v) => v.appointmentId == apptId).toList();
    expect(linked.length, 3);
    await appts.delete(saved, linked);
    expect((await db.appointments.doc(apptId).get()).exists, isFalse);
    expect((await outgoing('u0')).where((v) => v.appointmentId == apptId), isEmpty);
    await appts.restore(saved, linked);
    expect((await db.appointments.doc(apptId).get()).exists, isTrue);
    expect((await outgoing('u0')).where((v) => v.appointmentId == apptId).length, 3);
    expect((await db.notificationsOf('u0').doc(NotificationIds.msg(pairId('u0', 'u8'))).get()).exists,
        isTrue);
  });

  testWidgets('§10-8: ret → bildirim + kilit; reddeden arkadaş olmayana yeniden davet yok; geri çekme',
      (_) async {
    await as('kerem@7v7.app');
    final d = (await draft('u0')).copyWith(matchTime: '21:00');

    // Ozan'a davet → Ozan reddeder.
    final ozanInvite = await inv.send(senderId: 'u0', receiverId: 'u4', draft: d, offeredSlot: 'gk');
    await as('ozan@7v7.app');
    await inv.respond(inviteId: ozanInvite, accept: false, me: await user('u4'));
    // Arkadaş olmayana mesaj reddedilir.
    await denied(chats.send(me: 'u4', other: 'u0', text: 'selam'), 'arkadaş olmayana mesaj');

    await as('kerem@7v7.app');
    final resp = await db.notificationsOf('u0').doc('resp_$ozanInvite').get(server);
    expect(resp.data()?['type'], 'inviteRejected');
    final v = (await outgoing('u0')).firstWhere((v) => v.id == ozanInvite);
    expect(v.isRejected, isTrue);
    await denied(inv.send(senderId: 'u0', receiverId: 'u4', draft: d, offeredSlot: 'gk'),
        'reddetmiş, arkadaş olmayan kişiye yeniden davet');

    // Yusuf'a davet → geri çek → davet ve bildirim silinir; geri al → yeniden gönderilir.
    final yusufInvite = await inv.send(senderId: 'u0', receiverId: 'u9', draft: d, offeredSlot: 'd1');
    await inv.withdrawById(yusufInvite, senderId: 'u0', receiverId: 'u9');
    expect((await outgoing('u0')).where((v) => v.id == yusufInvite), isEmpty);
    final again = await inv.send(senderId: 'u0', receiverId: 'u9', draft: d, offeredSlot: 'd1');
    await as('yusuf@7v7.app');
    expect((await db.notificationsOf('u9').doc('invite_$yusufInvite').get()).exists, isFalse);
    expect((await db.notificationsOf('u9').doc('invite_$again').get()).exists, isTrue);
  });
}

/// Bildirim kimlikleri (§6.2) — testte okunabilirlik için.
abstract final class NotificationIds {
  static String msg(String chatId) => 'msg_$chatId';
}
