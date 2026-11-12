// Ekran testleri için ortak düzen: seed verisinden (test/emulator_seed/firestore_seed.json)
// modeller, Firebase'e dokunmayan sahte provider'lar, Archivo + Phosphor
// fontları, tema/dil ve görüntü boyutu.
import 'dart:convert';
import 'dart:io';

import 'package:app_7v7/app/theme/app_colors.dart';
import 'package:app_7v7/app/theme/app_theme.dart';
import 'package:app_7v7/app/theme/theme_controller.dart';
import 'package:app_7v7/core/utils/time_format.dart';
import 'package:app_7v7/core/widgets/app_icons.dart';
import 'package:app_7v7/core/widgets/app_tab_bar.dart';
import 'package:app_7v7/l10n/app_localizations.dart';
import 'package:app_7v7/models/contact_model.dart';
import 'package:app_7v7/models/appointment_model.dart';
import 'package:app_7v7/models/chat_model.dart';
import 'package:app_7v7/models/draft_model.dart';
import 'package:app_7v7/models/invite_model.dart';
import 'package:app_7v7/models/message_model.dart';
import 'package:app_7v7/models/notification_model.dart';
import 'package:app_7v7/models/player_model.dart';
import 'package:app_7v7/models/user_model.dart';
import 'package:app_7v7/services/appointment_service.dart';
import 'package:app_7v7/services/chat_service.dart';
import 'package:app_7v7/services/draft_service.dart';
import 'package:app_7v7/services/firebase_providers.dart';
import 'package:app_7v7/services/invite_service.dart';
import 'package:app_7v7/services/notification_service.dart';
import 'package:app_7v7/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Testlerde sabit "şimdi" (golden'lar çalıştırma saatine bağlı olmasın):
/// seed zamanları buna göre üretilir ve uygulamanın saati buna ayarlanır.
final DateTime fixtureNow = DateTime(2026, 11, 12, 17, 30);

DateTime _ago(Object? m) =>
    fixtureNow.subtract(Duration(minutes: (m as num? ?? 0).toInt()));

List<PlayerModel> _players(Object? raw) => [
  for (final p in (raw as List? ?? const []))
    PlayerModel(
      slot: p['slot'] as String,
      firstName: p['firstName'] as String,
      lastName: (p['lastName'] ?? '') as String,
    ),
];

/// Seed verisi, model olarak.
class Fixture {
  Fixture._(this.raw);
  final Map<String, dynamic> raw;

  static Fixture load() => Fixture._(
    jsonDecode(File('test/emulator_seed/firestore_seed.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  late final Map<String, UserModel> users = {
    for (final e in (raw['users'] as Map<String, dynamic>).entries)
      e.key: UserModel(
        uid: e.key,
        firstName: e.value['firstName'] as String,
        lastName: e.value['lastName'] as String,
        city: (e.value['city'] ?? '') as String,
        position: (e.value['position'] ?? '') as String,
      ),
  };

  DraftModel draft(String uid) {
    final m =
        (raw['drafts'] as Map<String, dynamic>)[uid] as Map<String, dynamic>?;
    if (m == null) return DraftModel.empty;
    return DraftModel(
      formation: m['formation'] as String?,
      city: m['city'] as String?,
      district: m['district'] as String?,
      stadium: m['stadium'] as String?,
      matchTime: m['matchTime'] as String?,
      players: PlayerModel.mapFrom(_players(m['players'])),
    );
  }

  late final List<AppointmentModel> appointments = [
    for (final e in (raw['appointments'] as Map<String, dynamic>).entries)
      AppointmentModel(
        id: e.key,
        ownerId: e.value['ownerId'] as String,
        memberIds: List<String>.from(e.value['memberIds'] as List),
        formation: e.value['formation'] as String,
        city: e.value['city'] as String,
        district: e.value['district'] as String,
        stadium: e.value['stadium'] as String,
        matchTime: e.value['matchTime'] as String,
        players: _players(e.value['players']),
        isSample: (e.value['isSample'] ?? false) as bool,
        imageAsset: e.value['imageAsset'] as String?,
        createdAt: _ago(e.value['createdMinutesAgo']),
      ),
  ];

  late final List<InviteModel> invites = [
    for (final e in (raw['invites'] as Map<String, dynamic>).entries)
      InviteModel(
        id: e.key,
        senderId: e.value['senderId'] as String,
        receiverId: e.value['receiverId'] as String,
        formation: e.value['formation'] as String,
        city: e.value['city'] as String,
        district: e.value['district'] as String,
        stadium: e.value['stadium'] as String,
        matchTime: e.value['matchTime'] as String,
        players: _players(e.value['players']),
        offeredSlot: e.value['offeredSlot'] as String,
        status: InviteStatus.values.byName(e.value['status'] as String),
        appointmentId: e.value['appointmentId'] as String?,
        appliedToDraft: (e.value['appliedToDraft'] ?? false) as bool,
        createdAt: _ago(e.value['createdMinutesAgo']),
      ),
  ];

  late final Map<String, List<MessageModel>> messages = {
    for (final e in (raw['chats'] as Map<String, dynamic>).entries)
      e.key: [
        for (final m in e.value['messages'] as List)
          MessageModel(
            id: m['id'] as String,
            senderId: m['senderId'] as String,
            text: m['text'] as String,
            createdAt: _ago(m['createdMinutesAgo']),
          ),
      ],
  };

  late final List<ChatModel> chats = [
    for (final e in (raw['chats'] as Map<String, dynamic>).entries)
      () {
        final last = messages[e.key]!.last;
        return ChatModel(
          id: e.key,
          userIds: List<String>.from(e.value['userIds'] as List),
          lastText: last.text,
          lastSenderId: last.senderId,
          lastAt: last.createdAt,
          updatedAt: last.createdAt,
        );
      }(),
  ]..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));

  List<NotificationModel> notifications(String uid) => [
    for (final n
        in ((raw['notifications'] as Map<String, dynamic>)[uid] as List? ??
            const []))
      NotificationModel(
        id: n['id'] as String,
        type: NotificationType.values.byName(n['type'] as String),
        relatedId: n['relatedId'] as String,
        isRead: n['isRead'] as bool,
        createdAt: _ago(n['createdMinutesAgo']),
      ),
  ]..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  Set<String> friendsOf(String uid) => {
    for (final f in (raw['friendships'] as Map<String, dynamic>).values)
      for (final u in List<String>.from(f['userIds'] as List))
        if (u != uid && (f['userIds'] as List).contains(uid)) u,
  };
}

/// Firestore'a dokunmayan taslak denetleyicisi.
class FakeDraft extends DraftController {
  FakeDraft(this.initial);
  final DraftModel initial;
  @override
  DraftModel build() => initial;
  @override
  void update(DraftModel d) => state = d;
  @override
  Future<void> flush() async {}
}

/// Oturum açmış [uid] için tüm veri provider'larını seed verisiyle ezer.
Future<List<Override>> overridesFor(
  Fixture f, {
  String uid = 'u0',
  bool dark = false,
  String locale = 'tr',
  DraftModel? draft,
  bool emptyAccount = false,
}) async {
  SharedPreferences.setMockInitialValues({
    'themeMode': dark ? 'dark' : 'light',
    'locale': locale,
    'onboardingSeen': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final u = f.users[uid]!;
  // Ayarlar denetleyicisi girişte kullanıcının kendi temasını/dilini uygular.
  final me = UserModel(
    uid: u.uid,
    firstName: u.firstName,
    lastName: u.lastName,
    city: u.city,
    position: u.position,
    themeMode: dark ? 'dark' : 'light',
    locale: locale,
  );
  final appts = emptyAccount
      ? const <AppointmentModel>[]
      : f.appointments.where((a) => a.memberIds.contains(uid)).toList();
  final invites = emptyAccount ? const <InviteModel>[] : f.invites;
  final notifs = emptyAccount
      ? const <NotificationModel>[]
      : f.notifications(uid);
  final chats = emptyAccount
      ? const <ChatModel>[]
      : f.chats.where((c) => c.userIds.contains(uid)).toList();
  return [
    sharedPrefsProvider.overrideWithValue(prefs),
    uidProvider.overrideWithValue(uid),
    currentUserProvider.overrideWith((ref) => Stream.value(me)),
    myContactProvider.overrideWith(
      (ref) => Stream.value(
        ContactModel(
          email: (f.raw['users'] as Map<String, dynamic>)[uid]['email'] as String,
          phone: ((f.raw['users'] as Map<String, dynamic>)[uid]['phone'] ?? '') as String,
        ),
      ),
    ),
    allUsersProvider.overrideWith(
      (ref) => Stream.value(f.users.values.toList()),
    ),
    myAppointmentsProvider.overrideWith((ref) => Stream.value(appts)),
    incomingInvitesProvider.overrideWith(
      (ref) => Stream.value(invites.where((v) => v.receiverId == uid).toList()),
    ),
    outgoingInvitesProvider.overrideWith(
      (ref) => Stream.value(invites.where((v) => v.senderId == uid).toList()),
    ),
    friendsProvider.overrideWith(
      (ref) => Stream.value(emptyAccount ? <String>{} : f.friendsOf(uid)),
    ),
    myChatsProvider.overrideWith((ref) => Stream.value(chats)),
    notificationsProvider.overrideWith((ref) => Stream.value(notifs)),
    appointmentProvider.overrideWith(
      (ref, id) => Stream.value(appts.where((a) => a.id == id).firstOrNull),
    ),
    inviteProvider.overrideWith(
      (ref, id) => Stream.value(invites.where((v) => v.id == id).firstOrNull),
    ),
    messagesProvider.overrideWith(
      (ref, id) => Stream.value(f.messages[id] ?? const <MessageModel>[]),
    ),
    draftProvider.overrideWith(
      () =>
          FakeDraft(draft ?? (emptyAccount ? DraftModel.empty : f.draft(uid))),
    ),
  ];
}

bool _fontsLoaded = false;

/// Uygulamanın saatini [fixtureNow]'a sabitler.
void freezeClock() => clockNow = () => fixtureNow;

/// Archivo ve Phosphor Fill fontlarını test motoruna yükler.
Future<void> loadFonts() async {
  if (_fontsLoaded) return;
  final archivo = FontLoader('Archivo')
    ..addFont(rootBundle.load('assets/fonts/Archivo[wdth,wght].ttf'));
  await archivo.load();
  final phosphor = FontLoader('packages/phosphor_flutter/PhosphorFill')
    ..addFont(
      rootBundle.load('packages/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf'),
    );
  await phosphor.load();
  _fontsLoaded = true;
}

/// Görüntü boyutu + güvenli alan (üst 59, alt 34 — referans iPhone 15).
void setPhone(
  WidgetTester t,
  Size size, {
  EdgeInsets safe = const EdgeInsets.only(top: 59, bottom: 34),
}) {
  t.view.physicalSize = size * 2;
  t.view.devicePixelRatio = 2;
  t.view.padding = FakeViewPadding(top: safe.top * 2, bottom: safe.bottom * 2);
  t.view.viewPadding = FakeViewPadding(
    top: safe.top * 2,
    bottom: safe.bottom * 2,
  );
  addTearDown(t.view.reset);
}

/// Ekranı tema, dil ve (sekme ekranıysa) alt menüyle sarar.
Widget wrap(
  Widget screen, {
  bool dark = false,
  String locale = 'tr',
  int? tab,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: tab == null
        ? screen
        : Builder(
            builder: (context) {
              final l = AppLocalizations.of(context);
              return Scaffold(
                backgroundColor: context.c.bg,
                body: screen,
                bottomNavigationBar: AppTabBar(
                  index: tab,
                  onTap: (_) {},
                  items: [
                    TabItem(PhosphorIconsFill.usersThree, l.tabTeam),
                    TabItem(PhosphorIconsFill.calendarCheck, l.tabAppts),
                    TabItem(PhosphorIconsFill.userCircle, l.tabProfile),
                    TabItem(PhosphorIconsFill.chatsCircle, l.tabSocial),
                  ],
                ),
              );
            },
          ),
  );
}

/// Ekranı pompalar, akışların ilk değerini ve görselleri bekler.
Future<void> pumpScreen(
  WidgetTester t,
  Widget screen, {
  required List<Override> overrides,
  bool dark = false,
  String locale = 'tr',
  int? tab,
}) async {
  await t.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: wrap(screen, dark: dark, locale: locale, tab: tab),
    ),
  );
  await t.pump();
  await t.pump();
  await t.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await t.pump(const Duration(milliseconds: 300));
}
