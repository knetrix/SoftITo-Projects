// firestore.rules emülatör testleri (7V7_HANDOFF.md §6.4, §10 madde 11).
// Çalıştırma (proje kökünden):
//   firebase emulators:exec --only firestore "npm --prefix test/rules test"
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, writeBatch, runTransaction,
  serverTimestamp, collection, query, where, getDocs,
} from 'firebase/firestore';

// Ayrı emülatör projesi: testler clearFirestore ile demo verisini silmesin.
const PROJECT = 'demo-7v7-rules';
let env;

const pair = (a, b) => (a < b ? `${a}_${b}` : `${b}_${a}`);
const db = (uid) => env.authenticatedContext(uid, { email: `${uid}@7v7.app` }).firestore();
const anon = () => env.unauthenticatedContext().firestore();

async function seed(fn) {
  await env.withSecurityRulesDisabled(async (ctx) => fn(ctx.firestore()));
}

// Herkese açık profil: e-posta / telefon yok (bkz. users/{uid}/private/contact).
const user = (uid, extra = {}) => ({
  firstName: uid.toUpperCase(), lastName: 'Test', city: '', position: '',
  settings: { themeMode: 'light', locale: 'tr' }, ...extra,
});

/** Uygulamadaki AuthService.signUp ile aynı batch. */
function signUpBatch(uid, phone) {
  const f = db(uid);
  const b = writeBatch(f);
  b.set(doc(f, 'users', uid), { ...user(uid), createdAt: serverTimestamp() });
  b.set(doc(f, 'users', uid, 'private', 'contact'),
    { email: `${uid}@7v7.app`, phone: `0${phone}`, phoneNormalized: phone, createdAt: serverTimestamp() });
  b.set(doc(f, 'phoneIndex', phone), { uid });
  return b.commit();
}

const draft = { formation: '2-3-1', city: 'İzmir', district: 'Bornova', stadium: 'Bornova Arena',
  matchTime: '21:00', players: [{ slot: 'gk', firstName: 'Emre', lastName: 'Y' }] };

function inviteData(sender, receiver, slot = 'd2') {
  return {
    senderId: sender, receiverId: receiver, ...draft, durationMinutes: 60, offeredSlot: slot,
    status: 'pending', appointmentId: null, appliedToDraft: false,
    createdAt: serverTimestamp(), respondedAt: null,
  };
}

/** Uygulamadaki InviteService.send ile aynı batch. */
async function sendInvite(sender, receiver, id, slot) {
  const f = db(sender);
  const b = writeBatch(f);
  b.set(doc(f, 'invites', id), inviteData(sender, receiver, slot));
  b.set(doc(f, 'inviteLocks', `${sender}_${receiver}`), { inviteId: id, state: 'pending' });
  b.set(doc(f, 'users', receiver, 'notifications', `invite_${id}`),
    { type: 'invite', relatedId: id, isRead: false, createdAt: serverTimestamp() });
  return b.commit();
}

/** Uygulamadaki InviteService.respond ile aynı transaction. */
async function respond(receiver, id, accept) {
  const f = db(receiver);
  return runTransaction(f, async (tx) => {
    const ref = doc(f, 'invites', id);
    const v = (await tx.get(ref)).data();
    const fid = pair(v.senderId, v.receiverId);
    const fr = await tx.get(doc(f, 'friendships', fid));
    tx.update(ref, {
      status: accept ? 'accepted' : 'rejected', respondedAt: serverTimestamp(),
      ...(accept ? { players: [...v.players, { slot: v.offeredSlot, firstName: 'X', lastName: '' }] } : {}),
    });
    const lock = doc(f, 'inviteLocks', `${v.senderId}_${v.receiverId}`);
    if (accept) tx.delete(lock); else tx.set(lock, { inviteId: id, state: 'rejected' });
    if (accept && !fr.exists()) {
      tx.set(doc(f, 'friendships', fid), { userIds: fid.split('_'), inviteId: id, createdAt: serverTimestamp() });
    }
    tx.set(doc(f, 'users', v.senderId, 'notifications', `resp_${id}`), {
      type: accept ? 'inviteAccepted' : 'inviteRejected', relatedId: id, isRead: false, createdAt: serverTimestamp(),
    });
  });
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});
after(async () => env?.cleanup());
beforeEach(async () => {
  await env.clearFirestore();
  await seed(async (f) => {
    for (const u of ['u0', 'u1', 'u2', 'u3', 'u4', 'u5', 'u6', 'u7', 'u8', 'u9']) {
      await setDoc(doc(f, 'users', u), user(u));
    }
    await setDoc(doc(f, 'drafts', 'u0'), draft);
  });
});

describe('taslak ve bildirim yetkisi', () => {
  test('başkasının taslağı okunamaz/yazılamaz', async () => {
    await assertFails(getDoc(doc(db('u1'), 'drafts', 'u0')));
    await assertFails(setDoc(doc(db('u1'), 'drafts', 'u0'), draft));
    await assertSucceeds(setDoc(doc(db('u0'), 'drafts', 'u0'), draft));
  });

  test('başkasına keyfi bildirim yazılamaz', async () => {
    await assertFails(setDoc(doc(db('u1'), 'users', 'u0', 'notifications', 'x'),
      { type: 'invite', relatedId: 'nope', isRead: false, createdAt: serverTimestamp() }));
    await assertFails(setDoc(doc(db('u1'), 'users', 'u0', 'notifications', 'invite_nope'),
      { type: 'invite', relatedId: 'nope', isRead: false, createdAt: serverTimestamp() }));
  });

  test('başkasının bildirimi okunamaz; sahibi yalnızca isRead günceller', async () => {
    await seed((f) => setDoc(doc(f, 'users', 'u0', 'notifications', 'rem_a1'),
      { type: 'reminder', relatedId: 'a1', isRead: false, createdAt: new Date() }));
    await assertFails(getDoc(doc(db('u1'), 'users', 'u0', 'notifications', 'rem_a1')));
    await assertSucceeds(updateDoc(doc(db('u0'), 'users', 'u0', 'notifications', 'rem_a1'), { isRead: true }));
    await assertFails(updateDoc(doc(db('u0'), 'users', 'u0', 'notifications', 'rem_a1'), { type: 'invite' }));
  });
});

describe('davet akışı', () => {
  test('gönder → kabul → arkadaşlık + bildirim + taslağa işle', async () => {
    await assertSucceeds(sendInvite('u0', 'u8', 'inv1', 'd2'));
    await assertSucceeds(getDoc(doc(db('u8'), 'users', 'u8', 'notifications', 'invite_inv1')));
    // Gönderen yanıt veremez.
    await assertFails(updateDoc(doc(db('u0'), 'invites', 'inv1'), { status: 'accepted', respondedAt: serverTimestamp() }));
    await assertSucceeds(respond('u8', 'inv1', true));
    await assertSucceeds(getDoc(doc(db('u0'), 'friendships', 'u0_u8')));
    await assertSucceeds(getDoc(doc(db('u0'), 'users', 'u0', 'notifications', 'resp_inv1')));
    // Kabulü taslağa işle (göndericinin kendi uygulaması).
    await assertSucceeds(updateDoc(doc(db('u0'), 'invites', 'inv1'), { appliedToDraft: true }));
    await assertFails(updateDoc(doc(db('u8'), 'invites', 'inv1'), { appliedToDraft: true }));
  });

  test('aynı çifte ikinci bekleyen davet reddedilir', async () => {
    await assertSucceeds(sendInvite('u0', 'u8', 'inv1', 'd2'));
    await assertFails(sendInvite('u0', 'u8', 'inv2', 'm2'));
  });

  test('reddetmiş ve arkadaş olmayan kişiye yeniden davet reddedilir', async () => {
    await assertSucceeds(sendInvite('u0', 'u3', 'inv1', 'd2'));
    await assertSucceeds(respond('u3', 'inv1', false));
    await assertFails(sendInvite('u0', 'u3', 'inv2', 'd2'));
  });

  test('arkadaş yanıtlanmış davetten sonra yeniden davet edilebilir', async () => {
    await assertSucceeds(sendInvite('u0', 'u8', 'inv1', 'd2'));
    await assertSucceeds(respond('u8', 'inv1', true));
    await assertSucceeds(sendInvite('u0', 'u8', 'inv2', 'm2'));
    await assertSucceeds(respond('u8', 'inv2', false));
    await assertSucceeds(sendInvite('u0', 'u8', 'inv3', 'm3'));
  });

  test('geri çekme: davet + kilit + alıcının bildirimi', async () => {
    await assertSucceeds(sendInvite('u0', 'u6', 'inv1', 'd2'));
    const f = db('u0');
    const b = writeBatch(f);
    b.delete(doc(f, 'users', 'u6', 'notifications', 'invite_inv1'));
    b.delete(doc(f, 'inviteLocks', 'u0_u6'));
    b.delete(doc(f, 'invites', 'inv1'));
    await assertSucceeds(b.commit());
    await assertSucceeds(sendInvite('u0', 'u6', 'inv2', 'd2'));
  });

  test('davet sorguları yalnızca taraflara açık', async () => {
    await assertSucceeds(sendInvite('u0', 'u8', 'inv1', 'd2'));
    await assertSucceeds(getDocs(query(collection(db('u8'), 'invites'), where('receiverId', '==', 'u8'))));
    await assertFails(getDocs(query(collection(db('u9'), 'invites'), where('receiverId', '==', 'u8'))));
    await assertFails(getDoc(doc(db('u9'), 'invites', 'inv1')));
  });
});

describe('maçı kaydet ve sil', () => {
  test('6 davetliyle maçı kaydet tek batch’te geçer (kural sınırı)', async () => {
    const guests = ['u1', 'u2', 'u3', 'u4', 'u5', 'u6'];
    await seed(async (f) => {
      for (const [i, g] of guests.entries()) {
        await setDoc(doc(f, 'friendships', pair('u0', g)), { userIds: pair('u0', g).split('_'), inviteId: `v${i}`, createdAt: new Date() });
        await setDoc(doc(f, 'invites', `v${i}`), { ...inviteData('u0', g, 'gk'), status: 'accepted', createdAt: new Date(), respondedAt: new Date(), appliedToDraft: true });
      }
    });
    const f = db('u0');
    const b = writeBatch(f);
    const a = doc(f, 'appointments', 'new1');
    b.set(a, { ownerId: 'u0', memberIds: ['u0', ...guests], ...draft, durationMinutes: 60,
      isSample: false, imageAsset: null, createdAt: serverTimestamp() });
    for (const [i, g] of guests.entries()) {
      b.update(doc(f, 'invites', `v${i}`), { appointmentId: 'new1' });
      b.set(doc(f, 'users', g, 'notifications', 'match_new1'),
        { type: 'matchSaved', relatedId: 'new1', isRead: false, createdAt: serverTimestamp() });
    }
    b.set(doc(f, 'drafts', 'u0'), { ...draft, players: [], matchTime: null });
    await assertSucceeds(b.commit());
    await assertSucceeds(getDoc(doc(db('u4'), 'appointments', 'new1')));

    // Sil: randevu + bağlantıları kaldır.
    const d = writeBatch(f);
    d.delete(a);
    for (const [i] of guests.entries()) d.update(doc(f, 'invites', `v${i}`), { appointmentId: null });
    await assertSucceeds(d.commit());
  });

  test('arkadaş olmayan üye randevuya eklenemez; davetli silemez', async () => {
    const f = db('u0');
    await assertFails(setDoc(doc(f, 'appointments', 'x'), { ownerId: 'u0', memberIds: ['u0', 'u9'], ...draft,
      durationMinutes: 60, isSample: false, imageAsset: null, createdAt: serverTimestamp() }));
    await assertSucceeds(setDoc(doc(f, 'appointments', 'y'), { ownerId: 'u0', memberIds: ['u0'], ...draft,
      durationMinutes: 60, isSample: false, imageAsset: null, createdAt: serverTimestamp() }));
    await assertFails(deleteDoc(doc(db('u1'), 'appointments', 'y')));
  });
});

describe('sohbet', () => {
  test('arkadaş olmayana mesaj reddedilir, arkadaşa geçer (+ msg_ bildirimi)', async () => {
    const send = (from, to) => {
      const f = db(from);
      const cid = pair(from, to);
      const b = writeBatch(f);
      b.set(doc(f, 'chats', cid), { userIds: cid.split('_'),
        lastMessage: { text: 'Selam', senderId: from, createdAt: serverTimestamp() }, updatedAt: serverTimestamp() });
      b.set(doc(collection(f, 'chats', cid, 'messages')), { senderId: from, text: 'Selam', createdAt: serverTimestamp() });
      b.set(doc(f, 'users', to, 'notifications', `msg_${cid}`),
        { type: 'message', relatedId: cid, isRead: false, createdAt: serverTimestamp() });
      return b.commit();
    };
    await assertFails(send('u0', 'u9'));
    await seed((f) => setDoc(doc(f, 'friendships', 'u0_u2'), { userIds: ['u0', 'u2'], inviteId: 'o1', createdAt: new Date() }));
    await assertSucceeds(send('u0', 'u2'));
    await assertSucceeds(send('u2', 'u0'));
    await assertFails(getDocs(collection(db('u9'), 'chats', 'u0_u2', 'messages')));
  });

  test('henüz belgesi olmayan sohbetin mesajları üyeye okunabilir', async () => {
    await assertSucceeds(getDocs(collection(db('u0'), 'chats', 'u0_u5', 'messages')));
  });
});

describe('kişisel veri (KVKK)', () => {
  test('kayıt: profil + iletişim + telefon dizini; telefon tekil', async () => {
    await assertSucceeds(signUpBatch('n1', '5550001122'));
    // Aynı telefonla ikinci kayıt: dizin belgesi var → reddedilir.
    await assertFails(signUpBatch('n2', '5550001122'));
    await assertSucceeds(signUpBatch('n2', '5550001133'));
  });

  test('profil e-posta / telefon taşıyamaz; iletişim yalnızca sahibine açık', async () => {
    const f = db('n1');
    const b = writeBatch(f);
    b.set(doc(f, 'users', 'n1'), { ...user('n1'), email: 'n1@7v7.app', createdAt: serverTimestamp() });
    b.set(doc(f, 'users', 'n1', 'private', 'contact'),
      { email: 'n1@7v7.app', phone: '', phoneNormalized: '5550001144', createdAt: serverTimestamp() });
    b.set(doc(f, 'phoneIndex', '5550001144'), { uid: 'n1' });
    await assertFails(b.commit());

    await assertSucceeds(signUpBatch('n1', '5550001144'));
    await assertFails(updateDoc(doc(f, 'users', 'n1'), { phone: '0555' }));
    await assertSucceeds(updateDoc(doc(f, 'users', 'n1'), { 'settings.themeMode': 'dark' }));
    await assertSucceeds(getDoc(doc(f, 'users', 'n1', 'private', 'contact')));
    await assertFails(getDoc(doc(db('u0'), 'users', 'n1', 'private', 'contact')));
    await assertFails(getDocs(collection(db('u0'), 'users', 'n1', 'private')));
    await assertFails(updateDoc(doc(f, 'users', 'n1', 'private', 'contact'), { email: 'x@7v7.app' }));
  });

  test('telefon dizini kimseye okunmaz (oturumsuz / başka kullanıcı)', async () => {
    await assertSucceeds(signUpBatch('n1', '5550001155'));
    await assertFails(getDoc(doc(anon(), 'phoneIndex', '5550001155')));
    await assertFails(getDoc(doc(db('u0'), 'phoneIndex', '5550001155')));
    await assertFails(getDocs(collection(anon(), 'phoneIndex')));
    await assertFails(getDocs(collection(db('u0'), 'phoneIndex')));
    await assertSucceeds(getDoc(doc(db('n1'), 'phoneIndex', '5550001155')));
  });
});

describe('hesap silme', () => {
  // u0 → u2 kabul edilmiş (arkadaş, u0'ın randevusunda davetli), u0 → u4 bekleyen,
  // u2 sohbeti; u2 hesabını siler.
  async function world() {
    await seed(async (f) => {
      await setDoc(doc(f, 'users', 'u2', 'private', 'contact'),
        { email: 'u2@7v7.app', phone: '', phoneNormalized: '5550002222', createdAt: new Date() });
      await setDoc(doc(f, 'phoneIndex', '5550002222'), { uid: 'u2' });
      await setDoc(doc(f, 'friendships', 'u0_u2'), { userIds: ['u0', 'u2'], inviteId: 'a', createdAt: new Date() });
      await setDoc(doc(f, 'invites', 'a'), { ...inviteData('u0', 'u2', 'm2'), status: 'accepted',
        createdAt: new Date(), respondedAt: new Date(), appliedToDraft: true, appointmentId: 'm1' });
      await setDoc(doc(f, 'invites', 'p'), { ...inviteData('u2', 'u4', 'gk'), createdAt: new Date() });
      await setDoc(doc(f, 'inviteLocks', 'u2_u4'), { inviteId: 'p', state: 'pending' });
      await setDoc(doc(f, 'users', 'u4', 'notifications', 'invite_p'),
        { type: 'invite', relatedId: 'p', isRead: false, createdAt: new Date() });
      await setDoc(doc(f, 'appointments', 'm1'), { ownerId: 'u0', memberIds: ['u0', 'u2'], ...draft,
        durationMinutes: 60, isSample: false, imageAsset: null, createdAt: new Date() });
      await setDoc(doc(f, 'chats', 'u0_u2'), { userIds: ['u0', 'u2'], lastMessage: null, updatedAt: new Date() });
      await setDoc(doc(f, 'chats', 'u0_u2', 'messages', 'x'), { senderId: 'u2', text: 'selam', createdAt: new Date() });
      await setDoc(doc(f, 'users', 'u2', 'notifications', 'resp_a'),
        { type: 'inviteAccepted', relatedId: 'a', isRead: false, createdAt: new Date() });
      // u2'nin başkalarına bıraktıkları: u0'da resp_a (u2 kabul etti), msg_u0_u2, match_m3.
      await setDoc(doc(f, 'users', 'u0', 'notifications', 'resp_a'),
        { type: 'inviteAccepted', relatedId: 'a', isRead: false, createdAt: new Date() });
      await setDoc(doc(f, 'users', 'u0', 'notifications', 'msg_u0_u2'),
        { type: 'message', relatedId: 'u0_u2', isRead: false, createdAt: new Date() });
      await setDoc(doc(f, 'appointments', 'm3'), { ownerId: 'u2', memberIds: ['u2', 'u0'], ...draft,
        durationMinutes: 60, isSample: false, imageAsset: null, createdAt: new Date() });
      await setDoc(doc(f, 'users', 'u0', 'notifications', 'match_m3'),
        { type: 'matchSaved', relatedId: 'm3', isRead: false, createdAt: new Date() });
    });
  }

  test('profil silinmeden ilişkiler silinemez (normal kullanım korunur)', async () => {
    await world();
    const f = db('u2');
    await assertFails(deleteDoc(doc(f, 'friendships', 'u0_u2')));
    await assertFails(deleteDoc(doc(f, 'invites', 'a')));
    await assertFails(deleteDoc(doc(f, 'chats', 'u0_u2', 'messages', 'x')));
    await assertFails(deleteDoc(doc(f, 'chats', 'u0_u2')));
    await assertFails(updateDoc(doc(f, 'appointments', 'm1'), { memberIds: ['u0'] }));
    await assertFails(deleteDoc(doc(f, 'users', 'u0', 'notifications', 'msg_u0_u2')));
    await assertFails(deleteDoc(doc(f, 'users', 'u0', 'notifications', 'resp_a')));
  });

  test('uygulamadaki sırayla tüm veriler silinir', async () => {
    await world();
    const f = db('u2');
    // 2) bekleyen davetin alıcıdaki bildirimi (davet hâlâ var).
    await assertSucceeds(deleteDoc(doc(f, 'users', 'u4', 'notifications', 'invite_p')));
    // 3) profil.
    await assertSucceeds(deleteDoc(doc(f, 'users', 'u2')));
    // 4a) başkalarına bıraktığı bildirimler (biri zaten yok: yine geçer).
    const n = writeBatch(f);
    n.delete(doc(f, 'users', 'u0', 'notifications', 'resp_a'));
    n.delete(doc(f, 'users', 'u0', 'notifications', 'msg_u0_u2'));
    n.delete(doc(f, 'users', 'u0', 'notifications', 'match_m3'));
    n.delete(doc(f, 'users', 'u3', 'notifications', 'msg_u2_u3'));
    await assertSucceeds(n.commit());
    // Başkasının, kendisiyle ilgisiz bildirimi silinemez.
    await assertFails(deleteDoc(doc(f, 'users', 'u0', 'notifications', 'msg_u0_u5')));
    await assertFails(deleteDoc(doc(f, 'users', 'u4', 'notifications', 'resp_a')));
    // 4b) ilişkiler.
    const b = writeBatch(f);
    b.delete(doc(f, 'appointments', 'm3'));
    b.update(doc(f, 'appointments', 'm1'), { memberIds: ['u0'] });
    for (const [id, lid] of [['a', 'u0_u2'], ['p', 'u2_u4']]) {
      b.delete(doc(f, 'inviteLocks', lid));
      b.delete(doc(f, 'invites', id));
    }
    b.delete(doc(f, 'friendships', 'u0_u2'));
    b.delete(doc(f, 'chats', 'u0_u2', 'messages', 'x'));
    b.delete(doc(f, 'chats', 'u0_u2'));
    await assertSucceeds(b.commit());
    // 5) kendi belgeleri.
    const c = writeBatch(f);
    c.delete(doc(f, 'users', 'u2', 'notifications', 'resp_a'));
    c.delete(doc(f, 'drafts', 'u2'));
    c.delete(doc(f, 'phoneIndex', '5550002222'));
    c.delete(doc(f, 'users', 'u2', 'private', 'contact'));
    await assertSucceeds(c.commit());

    const o = db('u0');
    assert.equal((await getDocs(collection(o, 'chats', 'u0_u2', 'messages'))).size, 0);
    assert.deepEqual((await getDoc(doc(o, 'appointments', 'm1'))).data().memberIds, ['u0']);
    assert.equal((await getDoc(doc(o, 'friendships', 'u0_u2'))).exists(), false);
    assert.equal((await getDocs(collection(o, 'users', 'u0', 'notifications'))).size, 0);
  });

  test('silinen davetli başkasını randevudan çıkaramaz; taraf olmayan silemez', async () => {
    await world();
    await seed((f) => setDoc(doc(f, 'appointments', 'm2'), { ownerId: 'u0', memberIds: ['u0', 'u2', 'u3'],
      ...draft, durationMinutes: 60, isSample: false, imageAsset: null, createdAt: new Date() }));
    const f = db('u2');
    await assertSucceeds(deleteDoc(doc(f, 'users', 'u2')));
    await assertFails(updateDoc(doc(f, 'appointments', 'm2'), { memberIds: ['u0'] }));
    await assertFails(updateDoc(doc(f, 'appointments', 'm2'), { memberIds: ['u0', 'u3'], stadium: 'X' }));
    await assertSucceeds(updateDoc(doc(f, 'appointments', 'm2'), { memberIds: ['u0', 'u3'] }));
    // u9 profilini silse de başkalarının ilişkilerine dokunamaz.
    const g = db('u9');
    await assertSucceeds(deleteDoc(doc(g, 'users', 'u9')));
    await assertFails(deleteDoc(doc(g, 'friendships', 'u0_u2')));
    await assertFails(deleteDoc(doc(g, 'invites', 'a')));
    await assertFails(deleteDoc(doc(g, 'chats', 'u0_u2', 'messages', 'x')));
    await assertFails(deleteDoc(doc(g, 'inviteLocks', 'u2_u4')));
    // Silinen kullanıcıya davet gönderilemez.
    await assertFails(sendInvite('u0', 'u2', 'z', 'gk'));
  });
});
