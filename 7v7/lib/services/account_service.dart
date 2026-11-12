import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import 'auth_service.dart';
import 'firebase_providers.dart';

/// Hesabı uygulama içinden kalıcı olarak silme (App Store 5.1.1(v), KVKK).
///
/// Spark planında sunucu kodu yok; silme istemcide, güvenlik kurallarının
/// izin verdiği sırayla yapılır. Herhangi bir adımda kesilirse tekrar
/// çağrılabilir: her adım "zaten silinmiş" durumunu tolere eder.
///
/// 1. Şifreyle yeniden doğrulama (Firebase hesap silmek için ister).
/// 2. Gönderdiğim bekleyen davetlerin alıcıdaki `invite_` bildirimleri.
/// 3. Herkese açık profil (`users/{uid}`) silinir; kurallar bunu "hesap
///    siliniyor" işareti sayar (`leaving()`).
/// 4. Başkalarına bıraktığım `resp_` / `match_` / `msg_` bildirimleri; sonra
///    sahibi olduğum randevular, taraf olduğum davetler + kilitleri,
///    arkadaşlıklar, sohbetler ve mesajları; davetli olduğum randevulardan
///    kendimi çıkarırım.
/// 5. Bildirimlerim, taslağım, telefon dizini kaydım, iletişim belgem.
/// 6. Firebase Auth hesabı.
///
/// Kalan tek iz başkasının verisidir: başka sahiplerin kadrolarına yazılmış ad.
class AccountService {
  AccountService(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static const _server = GetOptions(source: Source.server);

  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('eGeneric');
    final me = user.uid;

    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email ?? '',
          password: password,
        ),
      );
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'wrong-password' ||
        'invalid-credential' ||
        'INVALID_LOGIN_CREDENTIALS' => const AuthFailure(
          'eWrongpw',
          field: 'password',
        ),
        _ => const AuthFailure('eGeneric'),
      };
    }

    // ---- oku ----
    final contact = await _db.contactOf(me).get(_server);
    final phone = contact.data()?['phoneNormalized'] as String?;
    final appts =
        (await _db.appointments
                .where('memberIds', arrayContains: me)
                .get(_server))
            .docs;
    final invites = {
      for (final d in [
        ...(await _db.invites.where('senderId', isEqualTo: me).get(_server))
            .docs,
        ...(await _db.invites.where('receiverId', isEqualTo: me).get(_server))
            .docs,
      ])
        d.id: d,
    }.values.toList();
    final friendships =
        (await _db.friendships.where('userIds', arrayContains: me).get(_server))
            .docs;
    final chatIds = {
      for (final d
          in (await _db.chats.where('userIds', arrayContains: me).get(_server))
              .docs)
        d.id,
      for (final f in friendships) f.id,
    };
    final messages = <DocumentReference<Map<String, dynamic>>>[
      for (final cid in chatIds)
        ...(await _db.chats.doc(cid).collection('messages').get(_server)).docs
            .map((m) => m.reference),
    ];
    final notifs = (await _db.notificationsOf(me).get(_server)).docs;

    // ---- 2) normal kurallarla yapılabilenler ----
    // Profil zaten silindiyse (yarım kalmış önceki deneme) bu adım bitmiştir;
    // başkasının bildirimini yeniden silmeye çalışmak kuralca reddedilir.
    final profileExists = (await _db.users.doc(me).get(_server)).exists;
    if (profileExists) {
      await _commit([
        for (final v in invites)
          if (v.data()['senderId'] == me && v.data()['status'] == 'pending')
            (b) => b.delete(
              _db
                  .notificationsOf(v.data()['receiverId'] as String)
                  .doc(NotificationModel.inviteId(v.id)),
            ),
      ]);
      // ---- 3) herkese açık profil (işaret) ----
      await _db.users.doc(me).delete();
    }

    // ---- 4a) başkalarına bıraktığım bildirimler (kaynak belgeler henüz duruyor) ----
    String other(String cid) =>
        cid.split('_').firstWhere((u) => u != me, orElse: () => '');
    await _commit([
      for (final v in invites)
        if (v.data()['receiverId'] == me && v.data()['status'] != 'pending')
          (b) => b.delete(
            _db
                .notificationsOf(v.data()['senderId'] as String)
                .doc(NotificationModel.responseId(v.id)),
          ),
      for (final a in appts)
        if (a.data()['ownerId'] == me)
          for (final m in List<String>.from(a.data()['memberIds'] as List))
            if (m != me)
              (b) => b.delete(
                _db.notificationsOf(m).doc(NotificationModel.matchId(a.id)),
              ),
      for (final cid in chatIds)
        if (other(cid).isNotEmpty)
          (b) => b.delete(
            _db
                .notificationsOf(other(cid))
                .doc(NotificationModel.messageId(cid)),
          ),
    ]);

    // ---- 4b) ilişkiler ----
    await _commit([
      for (final a in appts)
        if (a.data()['ownerId'] == me) (b) => b.delete(a.reference),
      for (final a in appts)
        if (a.data()['ownerId'] != me)
          (b) => b.update(a.reference, {
            'memberIds': FieldValue.arrayRemove([me]),
          }),
      for (final v in invites) ...[
        (b) => b.delete(
          _db.inviteLocks.doc(
            '${v.data()['senderId']}_${v.data()['receiverId']}',
          ),
        ),
        (b) => b.delete(v.reference),
      ],
      for (final f in friendships) (b) => b.delete(f.reference),
      for (final m in messages) (b) => b.delete(m),
      for (final cid in chatIds) (b) => b.delete(_db.chats.doc(cid)),
    ]);

    // ---- 5) kendi belgelerim ----
    await _commit([
      for (final n in notifs) (b) => b.delete(n.reference),
      (b) => b.delete(_db.drafts.doc(me)),
      if (phone != null && phone.isNotEmpty)
        (b) => b.delete(_db.phoneIndex.doc(phone)),
      (b) => b.delete(_db.contactOf(me)),
    ]);

    // ---- 6) Auth hesabı ----
    await user.delete();
  }

  /// İşlemleri 400'lük batch'lerle sırayla yazar (Firestore sınırı 500).
  Future<void> _commit(List<void Function(WriteBatch)> ops) async {
    for (var i = 0; i < ops.length; i += 400) {
      final b = _db.batch();
      for (final op in ops.skip(i).take(400)) {
        op(b);
      }
      await b.commit();
    }
  }
}

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);
