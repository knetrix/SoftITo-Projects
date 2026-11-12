import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// Oturum durumu.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// Oturum açmış kullanıcının uid'i (yoksa null).
final uidProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

/// Tipli koleksiyon kısayolları.
extension Collections on FirebaseFirestore {
  CollectionReference<Map<String, dynamic>> get users => collection('users');
  CollectionReference<Map<String, dynamic>> get phoneIndex => collection('phoneIndex');
  CollectionReference<Map<String, dynamic>> get drafts => collection('drafts');
  CollectionReference<Map<String, dynamic>> get appointments => collection('appointments');
  CollectionReference<Map<String, dynamic>> get invites => collection('invites');
  CollectionReference<Map<String, dynamic>> get inviteLocks => collection('inviteLocks');
  CollectionReference<Map<String, dynamic>> get friendships => collection('friendships');
  CollectionReference<Map<String, dynamic>> get chats => collection('chats');
  CollectionReference<Map<String, dynamic>> notificationsOf(String uid) =>
      users.doc(uid).collection('notifications');

  /// Yalnızca sahibinin okuyabildiği iletişim bilgileri.
  DocumentReference<Map<String, dynamic>> contactOf(String uid) =>
      users.doc(uid).collection('private').doc('contact');
}

/// Sıralı uid çifti: `u0_u2`.
String pairId(String a, String b) {
  final l = [a, b]..sort();
  return '${l[0]}_${l[1]}';
}

/// Tek belge dinleyicisinde silinmiş / erişilemeyen belge `null` olarak
/// yayınlanır (ekran "yok" durumunu gösterir).
StreamTransformer<T?, T?> nullOnDenied<T>() => StreamTransformer.fromHandlers(
      handleError: (e, st, sink) {
        if (e is FirebaseException &&
            (e.code == 'permission-denied' || e.code == 'not-found')) {
          sink.add(null);
        } else {
          sink.addError(e, st);
        }
      },
    );
