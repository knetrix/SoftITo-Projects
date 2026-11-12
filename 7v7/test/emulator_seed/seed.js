/*
  7v7 test verisi — YALNIZCA Firebase Emulator Suite için (widget/golden testlerin
  fixture'ı ve integration_test/invite_flow_test.dart bunu kullanır).
  Canlı projeye ASLA yazmaz: FIRESTORE_EMULATOR_HOST ve FIREBASE_AUTH_EMULATOR_HOST
  tanımlı değilse çalışmayı reddeder.
  Kullanım:
    firebase emulators:start
    cd test/emulator_seed && npm i
    FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
      FIREBASE_PROJECT_ID=sevenv7-hali-saha node seed.js
*/
if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error('Bu betik yalnızca emülatörde çalışır (FIRESTORE_EMULATOR_HOST / FIREBASE_AUTH_EMULATOR_HOST yok).');
  process.exit(1);
}
const admin = require('firebase-admin');
const seed = require('./firestore_seed.json');

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || process.env.FIREBASE_PROJECT_ID });
const auth = admin.auth();
const db = admin.firestore();
const now = Date.now();
const ts = minutesAgo => admin.firestore.Timestamp.fromMillis(now - (minutesAgo || 0) * 60000);

async function upsertUser(uid, u) {
  const props = { uid, email: u.email, password: u.password, displayName: `${u.firstName} ${u.lastName}`, emailVerified: true };
  try { await auth.getUser(uid); await auth.updateUser(uid, props); }
  catch (e) { if (e.code === 'auth/user-not-found') await auth.createUser(props); else throw e; }
}

async function main() {
  const batch = db.batch();

  for (const [uid, u] of Object.entries(seed.users)) {
    await upsertUser(uid, u);
    const { password, email, phone, ...profile } = u;
    let digits = String(phone || '').replace(/\D/g, '');
    if (digits.length === 12 && digits.startsWith('90')) digits = digits.slice(2);
    if (digits.length === 11 && digits.startsWith('0')) digits = digits.slice(1);
    // Herkese açık profil / yalnızca sahibine açık iletişim / telefon tekilliği.
    batch.set(db.doc(`users/${uid}`), { ...profile, createdAt: ts(0) });
    batch.set(db.doc(`users/${uid}/private/contact`), { email, phone: phone || '', phoneNormalized: digits, createdAt: ts(0) });
    batch.set(db.doc(`phoneIndex/${digits}`), { uid });
  }
  for (const [uid, d] of Object.entries(seed.drafts)) batch.set(db.doc(`drafts/${uid}`), { ...d, updatedAt: ts(0) });
  for (const [id, a] of Object.entries(seed.appointments)) {
    const { createdMinutesAgo, ...rest } = a;
    batch.set(db.doc(`appointments/${id}`), { ...rest, createdAt: ts(createdMinutesAgo) });
  }
  for (const [id, v] of Object.entries(seed.invites)) {
    const { createdMinutesAgo, ...rest } = v;
    batch.set(db.doc(`invites/${id}`), { ...rest, createdAt: ts(createdMinutesAgo), respondedAt: v.status === 'pending' ? null : ts(createdMinutesAgo - 5) });
  }
  for (const [id, l] of Object.entries(seed.inviteLocks)) batch.set(db.doc(`inviteLocks/${id}`), l);
  for (const [id, f] of Object.entries(seed.friendships)) batch.set(db.doc(`friendships/${id}`), { ...f, createdAt: ts(600) });
  for (const [id, c] of Object.entries(seed.chats)) {
    const last = c.messages[c.messages.length - 1];
    batch.set(db.doc(`chats/${id}`), { userIds: c.userIds, lastMessage: last ? { text: last.text, senderId: last.senderId, createdAt: ts(last.createdMinutesAgo) } : null, updatedAt: ts(last ? last.createdMinutesAgo : 0) });
    for (const m of c.messages) batch.set(db.doc(`chats/${id}/messages/${m.id}`), { senderId: m.senderId, text: m.text, createdAt: ts(m.createdMinutesAgo) });
  }
  for (const [uid, list] of Object.entries(seed.notifications)) {
    for (const n of list) batch.set(db.doc(`users/${uid}/notifications/${n.id}`), { type: n.type, relatedId: n.relatedId, isRead: n.isRead, createdAt: ts(n.createdMinutesAgo) });
  }

  await batch.commit();
  console.log(`Seeded ${Object.keys(seed.users).length} users, ${Object.keys(seed.invites).length} invites, ${Object.keys(seed.appointments).length} appointments.`);
}

main().catch(e => { console.error(e); process.exit(1); });
