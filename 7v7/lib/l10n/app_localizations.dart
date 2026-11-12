import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @scrWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin'**
  String get scrWelcome;

  /// No description provided for @scrSignin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş'**
  String get scrSignin;

  /// No description provided for @scrSignup.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get scrSignup;

  /// No description provided for @scrTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takım Kur'**
  String get scrTeam;

  /// No description provided for @scrAppointments.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get scrAppointments;

  /// No description provided for @scrAppointmentDetail.
  ///
  /// In tr, this message translates to:
  /// **'Randevu ayrıntısı'**
  String get scrAppointmentDetail;

  /// No description provided for @scrProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get scrProfile;

  /// No description provided for @scrSocial.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet ve Arkadaşlar'**
  String get scrSocial;

  /// No description provided for @scrChat.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlaşma'**
  String get scrChat;

  /// No description provided for @scrNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get scrNotifications;

  /// No description provided for @signedIn.
  ///
  /// In tr, this message translates to:
  /// **'{name} olarak giriş yapıldı'**
  String signedIn(String name);

  /// No description provided for @signedOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapıldı'**
  String get signedOut;

  /// No description provided for @eName.
  ///
  /// In tr, this message translates to:
  /// **'En az 2 karakter gir.'**
  String get eName;

  /// No description provided for @eEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi yaz.'**
  String get eEmail;

  /// No description provided for @ePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni yaz.'**
  String get ePassword;

  /// No description provided for @ePwlen.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter kullan.'**
  String get ePwlen;

  /// No description provided for @eNoacct.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-postayla kayıtlı hesap yok.'**
  String get eNoacct;

  /// No description provided for @eWrongpw.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yanlış. Tekrar dene ya da şifreni yenile.'**
  String get eWrongpw;

  /// No description provided for @eExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-postayla zaten bir hesap var. Giriş yap.'**
  String get eExists;

  /// No description provided for @ePhoneExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu telefon numarasıyla zaten bir hesap var. Giriş yap.'**
  String get ePhoneExists;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In tr, this message translates to:
  /// **'Açık mod'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık mod'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @onbH.
  ///
  /// In tr, this message translates to:
  /// **'Yedi kişilik kadronu sahaya diz.'**
  String get onbH;

  /// No description provided for @onbP.
  ///
  /// In tr, this message translates to:
  /// **'Dizilişi seç, yelekleri dağıt, sahayı ve saati ayarla.'**
  String get onbP;

  /// No description provided for @onbF1.
  ///
  /// In tr, this message translates to:
  /// **'5 diziliş, kaleci her zaman sabit'**
  String get onbF1;

  /// No description provided for @onbF2.
  ///
  /// In tr, this message translates to:
  /// **'81 ilde örnek saha ve saat seçimi'**
  String get onbF2;

  /// No description provided for @onbF3.
  ///
  /// In tr, this message translates to:
  /// **'Takım arkadaşlarınla sohbet'**
  String get onbF3;

  /// No description provided for @onbStart.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get onbStart;

  /// No description provided for @onbHave.
  ///
  /// In tr, this message translates to:
  /// **'Hesabım var, giriş yap'**
  String get onbHave;

  /// No description provided for @imgWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Sahada yığılmış file yelekler, en üstte turuncu kaleci yeleği ve yanında top'**
  String get imgWelcome;

  /// No description provided for @imgSignin.
  ///
  /// In tr, this message translates to:
  /// **'Katlanmış yeşil ve turuncu yelekler, yanında antrenman hunileri'**
  String get imgSignin;

  /// No description provided for @imgPitch.
  ///
  /// In tr, this message translates to:
  /// **'Halı sahanın örnek görseli'**
  String get imgPitch;

  /// No description provided for @imgEmptyAppts.
  ///
  /// In tr, this message translates to:
  /// **'Boş halı sahada kalenin önünde duran top'**
  String get imgEmptyAppts;

  /// No description provided for @imgEmptyChats.
  ///
  /// In tr, this message translates to:
  /// **'Saha kenarındaki bankta su şişeleri ve katlanmış turuncu yelek'**
  String get imgEmptyChats;

  /// No description provided for @onbArt.
  ///
  /// In tr, this message translates to:
  /// **'2-3-1 dizilişinde sahaya dizilmiş yedi numaralı yelek'**
  String get onbArt;

  /// No description provided for @siH.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get siH;

  /// No description provided for @siP.
  ///
  /// In tr, this message translates to:
  /// **'Kadronu kaldığın yerden kurmaya devam et.'**
  String get siP;

  /// No description provided for @fPw.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get fPw;

  /// No description provided for @showPw.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi göster'**
  String get showPw;

  /// No description provided for @hidePw.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi gizle'**
  String get hidePw;

  /// No description provided for @forgot.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgot;

  /// No description provided for @siBtn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get siBtn;

  /// No description provided for @siBusy.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yapılıyor…'**
  String get siBusy;

  /// No description provided for @noAcct.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAcct;

  /// No description provided for @toSignup.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get toSignup;

  /// No description provided for @fpH.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni yenile'**
  String get fpH;

  /// No description provided for @fpP.
  ///
  /// In tr, this message translates to:
  /// **'Hesabının e-posta adresini yaz, şifre yenileme bağlantısını gönderelim.'**
  String get fpP;

  /// No description provided for @fEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get fEmail;

  /// No description provided for @fNewpw.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get fNewpw;

  /// No description provided for @fpBtn.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı gönder'**
  String get fpBtn;

  /// No description provided for @fpBusy.
  ///
  /// In tr, this message translates to:
  /// **'Gönderiliyor…'**
  String get fpBusy;

  /// No description provided for @suH.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get suH;

  /// No description provided for @suP.
  ///
  /// In tr, this message translates to:
  /// **'Kadronu kurmak için birkaç bilgi yeter.'**
  String get suP;

  /// No description provided for @fFirst.
  ///
  /// In tr, this message translates to:
  /// **'Ad'**
  String get fFirst;

  /// No description provided for @fLast.
  ///
  /// In tr, this message translates to:
  /// **'Soyad'**
  String get fLast;

  /// No description provided for @fPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası'**
  String get fPhone;

  /// No description provided for @pwHint.
  ///
  /// In tr, this message translates to:
  /// **'En az 8 karakter'**
  String get pwHint;

  /// No description provided for @suBtn.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get suBtn;

  /// No description provided for @suBusy.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturuluyor…'**
  String get suBusy;

  /// No description provided for @agreeTermsA.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Sözleşmesi'**
  String get agreeTermsA;

  /// No description provided for @agreeKvkkA.
  ///
  /// In tr, this message translates to:
  /// **'KVKK Aydınlatma Metni'**
  String get agreeKvkkA;

  /// No description provided for @agreeSuffix.
  ///
  /// In tr, this message translates to:
  /// **'okudum ve anladım.'**
  String get agreeSuffix;

  /// No description provided for @chkTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Sözleşmesini okudum ve anladım'**
  String get chkTerms;

  /// No description provided for @chkKvkk.
  ///
  /// In tr, this message translates to:
  /// **'KVKK metnini okudum ve anladım'**
  String get chkKvkk;

  /// No description provided for @eFirst.
  ///
  /// In tr, this message translates to:
  /// **'Adını yaz.'**
  String get eFirst;

  /// No description provided for @eLast.
  ///
  /// In tr, this message translates to:
  /// **'Soyadını yaz.'**
  String get eLast;

  /// No description provided for @ePhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numaranı 05XX XXX XX XX biçiminde yaz.'**
  String get ePhone;

  /// No description provided for @eTerms.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için sözleşmeyi onayla.'**
  String get eTerms;

  /// No description provided for @eKvkk.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için KVKK metnini onayla.'**
  String get eKvkk;

  /// No description provided for @hasAcct.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı?'**
  String get hasAcct;

  /// No description provided for @toSignin.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get toSignin;

  /// No description provided for @accountCreated.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluşturuldu. Şimdi giriş yap.'**
  String get accountCreated;

  /// No description provided for @legalNote.
  ///
  /// In tr, this message translates to:
  /// **'Örnek metin. Yayından önce hukuk uzmanı tarafından hazırlanacak.'**
  String get legalNote;

  /// No description provided for @termsP1.
  ///
  /// In tr, this message translates to:
  /// **'7v7, halı saha takımı ve maç organizasyonu kurmana yardım eden bir uygulamadır. Bu sürüm bir prototiptir.'**
  String get termsP1;

  /// No description provided for @termsP2.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamada gösterilen saha adları örnektir. Bu sürümde gerçek rezervasyon ya da ödeme yapılmaz.'**
  String get termsP2;

  /// No description provided for @termsP3.
  ///
  /// In tr, this message translates to:
  /// **'Başka kullanıcılara saygılı davranmayı ve sohbetlerde hakaret içeren içerik paylaşmamayı kabul edersin.'**
  String get termsP3;

  /// No description provided for @kvkkP1.
  ///
  /// In tr, this message translates to:
  /// **'Ad, soyad, e-posta ve telefon bilgin hesabını oluşturmak için kullanılır.'**
  String get kvkkP1;

  /// No description provided for @kvkkP2.
  ///
  /// In tr, this message translates to:
  /// **'Bu prototipte bilgilerin yalnızca uygulamanın çalışması için Firebase\'de saklanır.'**
  String get kvkkP2;

  /// No description provided for @kvkkP3.
  ///
  /// In tr, this message translates to:
  /// **'Verilerinin silinmesini istediğin an talep edebilirsin.'**
  String get kvkkP3;

  /// No description provided for @legalOk.
  ///
  /// In tr, this message translates to:
  /// **'Okudum, onaylıyorum'**
  String get legalOk;

  /// No description provided for @tabTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takım Kur'**
  String get tabTeam;

  /// No description provided for @tabAppts.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get tabAppts;

  /// No description provided for @tabProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @tabSocial.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet'**
  String get tabSocial;

  /// No description provided for @notifBtn.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifBtn;

  /// No description provided for @notifUnread.
  ///
  /// In tr, this message translates to:
  /// **'{n} okunmamış'**
  String notifUnread(String n);

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @locCity.
  ///
  /// In tr, this message translates to:
  /// **'İl'**
  String get locCity;

  /// No description provided for @locDistrict.
  ///
  /// In tr, this message translates to:
  /// **'İlçe'**
  String get locDistrict;

  /// No description provided for @locStadium.
  ///
  /// In tr, this message translates to:
  /// **'Saha'**
  String get locStadium;

  /// No description provided for @pick.
  ///
  /// In tr, this message translates to:
  /// **'Seç'**
  String get pick;

  /// No description provided for @required.
  ///
  /// In tr, this message translates to:
  /// **'Gerekli'**
  String get required;

  /// No description provided for @matchTime.
  ///
  /// In tr, this message translates to:
  /// **'Maç saati'**
  String get matchTime;

  /// No description provided for @oneHour.
  ///
  /// In tr, this message translates to:
  /// **'1 saat'**
  String get oneHour;

  /// No description provided for @squad.
  ///
  /// In tr, this message translates to:
  /// **'Kadro'**
  String get squad;

  /// No description provided for @squadN.
  ///
  /// In tr, this message translates to:
  /// **'{n}/7 oyuncu'**
  String squadN(String n);

  /// No description provided for @formationBtn.
  ///
  /// In tr, this message translates to:
  /// **'Diziliş {f}'**
  String formationBtn(String f);

  /// No description provided for @formationNone.
  ///
  /// In tr, this message translates to:
  /// **'Diziliş seç'**
  String get formationNone;

  /// No description provided for @saveTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takımı kaydet'**
  String get saveTeam;

  /// No description provided for @pickFormationFirst.
  ///
  /// In tr, this message translates to:
  /// **'Kadroyu dizmek için önce diziliş seç.'**
  String get pickFormationFirst;

  /// No description provided for @missing.
  ///
  /// In tr, this message translates to:
  /// **'Eksik:'**
  String get missing;

  /// No description provided for @mFormation.
  ///
  /// In tr, this message translates to:
  /// **'diziliş'**
  String get mFormation;

  /// No description provided for @mPlayers.
  ///
  /// In tr, this message translates to:
  /// **'{n} oyuncu'**
  String mPlayers(String n);

  /// No description provided for @mCity.
  ///
  /// In tr, this message translates to:
  /// **'il'**
  String get mCity;

  /// No description provided for @mDistrict.
  ///
  /// In tr, this message translates to:
  /// **'ilçe'**
  String get mDistrict;

  /// No description provided for @mStadium.
  ///
  /// In tr, this message translates to:
  /// **'saha'**
  String get mStadium;

  /// No description provided for @mTime.
  ///
  /// In tr, this message translates to:
  /// **'maç saati'**
  String get mTime;

  /// No description provided for @posGk.
  ///
  /// In tr, this message translates to:
  /// **'Kaleci'**
  String get posGk;

  /// No description provided for @posDef.
  ///
  /// In tr, this message translates to:
  /// **'Defans'**
  String get posDef;

  /// No description provided for @posMid.
  ///
  /// In tr, this message translates to:
  /// **'Orta Saha'**
  String get posMid;

  /// No description provided for @posAtt.
  ///
  /// In tr, this message translates to:
  /// **'Hücum'**
  String get posAtt;

  /// No description provided for @addPlayerTo.
  ///
  /// In tr, this message translates to:
  /// **'{pos} mevkisine oyuncu ekle'**
  String addPlayerTo(String pos);

  /// No description provided for @editPlayer.
  ///
  /// In tr, this message translates to:
  /// **'{name}, {pos}. Düzenle'**
  String editPlayer(String name, String pos);

  /// No description provided for @fpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Diziliş seç'**
  String get fpTitle;

  /// No description provided for @fpSub.
  ///
  /// In tr, this message translates to:
  /// **'Kaleci her dizilişte sabit. Toplam 7 oyuncu.'**
  String get fpSub;

  /// No description provided for @fdD.
  ///
  /// In tr, this message translates to:
  /// **'{n} defans'**
  String fdD(String n);

  /// No description provided for @fdM.
  ///
  /// In tr, this message translates to:
  /// **'{n} orta saha'**
  String fdM(String n);

  /// No description provided for @fdA.
  ///
  /// In tr, this message translates to:
  /// **'{n} hücum'**
  String fdA(String n);

  /// No description provided for @movedOne.
  ///
  /// In tr, this message translates to:
  /// **'{name} yeni dizilişte {pos} mevkisine geçti'**
  String movedOne(String name, String pos);

  /// No description provided for @movedMany.
  ///
  /// In tr, this message translates to:
  /// **'Yeni dizilişte yer değiştirenler: {names}'**
  String movedMany(String names);

  /// No description provided for @formationSet.
  ///
  /// In tr, this message translates to:
  /// **'Diziliş {f} olarak ayarlandı'**
  String formationSet(String f);

  /// No description provided for @fLastOpt.
  ///
  /// In tr, this message translates to:
  /// **'Soyad (isteğe bağlı)'**
  String get fLastOpt;

  /// No description provided for @ppSave.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncuyu kaydet'**
  String get ppSave;

  /// No description provided for @ppRemove.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncuyu çıkar'**
  String get ppRemove;

  /// No description provided for @ePfirst.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncunun adını yaz.'**
  String get ePfirst;

  /// No description provided for @eDup.
  ///
  /// In tr, this message translates to:
  /// **'{name} zaten {pos} mevkisinde. Aynı kişiyi iki mevkiye yazamazsın, farklı bir oyuncu gir.'**
  String eDup(String name, String pos);

  /// No description provided for @playerSaved.
  ///
  /// In tr, this message translates to:
  /// **'{name}, {pos} mevkisine eklendi'**
  String playerSaved(String name, String pos);

  /// No description provided for @playerUpdated.
  ///
  /// In tr, this message translates to:
  /// **'{name} güncellendi'**
  String playerUpdated(String name);

  /// No description provided for @playerRemoved.
  ///
  /// In tr, this message translates to:
  /// **'{name} kadrodan çıkarıldı'**
  String playerRemoved(String name);

  /// No description provided for @cpTitle.
  ///
  /// In tr, this message translates to:
  /// **'İl seç'**
  String get cpTitle;

  /// No description provided for @cpSearch.
  ///
  /// In tr, this message translates to:
  /// **'İl ara'**
  String get cpSearch;

  /// No description provided for @cpSub.
  ///
  /// In tr, this message translates to:
  /// **'Türkiye\'nin 81 ili'**
  String get cpSub;

  /// No description provided for @noCity.
  ///
  /// In tr, this message translates to:
  /// **'\"{q}\" ile eşleşen il yok.'**
  String noCity(String q);

  /// No description provided for @cityChanged.
  ///
  /// In tr, this message translates to:
  /// **'İl değişti. İlçe ve sahayı yeniden seç.'**
  String get cityChanged;

  /// No description provided for @dpTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlçe seç'**
  String get dpTitle;

  /// No description provided for @dpNeed.
  ///
  /// In tr, this message translates to:
  /// **'İlçeleri görmek için önce il seç.'**
  String get dpNeed;

  /// No description provided for @dpSample.
  ///
  /// In tr, this message translates to:
  /// **'Örnek ilçe listesi'**
  String get dpSample;

  /// No description provided for @spTitle.
  ///
  /// In tr, this message translates to:
  /// **'Halı saha seç'**
  String get spTitle;

  /// No description provided for @spNeed.
  ///
  /// In tr, this message translates to:
  /// **'Sahaları görmek için önce ilçe seç.'**
  String get spNeed;

  /// No description provided for @spSample.
  ///
  /// In tr, this message translates to:
  /// **'Örnek saha adları. Gerçek rezervasyon yapılmaz.'**
  String get spSample;

  /// No description provided for @tpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maç saati seç'**
  String get tpTitle;

  /// No description provided for @tpSub.
  ///
  /// In tr, this message translates to:
  /// **'Her maç 1 saat sürer.'**
  String get tpSub;

  /// No description provided for @savedAppt.
  ///
  /// In tr, this message translates to:
  /// **'Randevu kaydedildi'**
  String get savedAppt;

  /// No description provided for @apH.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım'**
  String get apH;

  /// No description provided for @sampleTag.
  ///
  /// In tr, this message translates to:
  /// **'Örnek'**
  String get sampleTag;

  /// No description provided for @guestTag.
  ///
  /// In tr, this message translates to:
  /// **'Davetli'**
  String get guestTag;

  /// No description provided for @buildingTag.
  ///
  /// In tr, this message translates to:
  /// **'Kadro kuruluyor'**
  String get buildingTag;

  /// No description provided for @organizer.
  ///
  /// In tr, this message translates to:
  /// **'Organizatör'**
  String get organizer;

  /// No description provided for @nSaved.
  ///
  /// In tr, this message translates to:
  /// **'{name} maçı kaydetti, saat {time}'**
  String nSaved(String name, String time);

  /// No description provided for @newMatch.
  ///
  /// In tr, this message translates to:
  /// **'Yeni maç kur'**
  String get newMatch;

  /// No description provided for @apSearch.
  ///
  /// In tr, this message translates to:
  /// **'Saha, ilçe veya oyuncu ara'**
  String get apSearch;

  /// No description provided for @fAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get fAll;

  /// No description provided for @fDay.
  ///
  /// In tr, this message translates to:
  /// **'Gündüz'**
  String get fDay;

  /// No description provided for @fEve.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get fEve;

  /// No description provided for @nAppts.
  ///
  /// In tr, this message translates to:
  /// **'{n} randevu'**
  String nAppts(String n);

  /// No description provided for @playersN.
  ///
  /// In tr, this message translates to:
  /// **'{n} oyuncu'**
  String playersN(String n);

  /// No description provided for @apEmptyT.
  ///
  /// In tr, this message translates to:
  /// **'Henüz randevu yok'**
  String get apEmptyT;

  /// No description provided for @apEmptyD.
  ///
  /// In tr, this message translates to:
  /// **'Takım Kur ekranında kadroyu, sahayı ve saati seç, yeşil tikle kaydet.'**
  String get apEmptyD;

  /// No description provided for @apEmptyBtn.
  ///
  /// In tr, this message translates to:
  /// **'Takım kur'**
  String get apEmptyBtn;

  /// No description provided for @apNone.
  ///
  /// In tr, this message translates to:
  /// **'Bu aramayla eşleşen randevu yok.'**
  String get apNone;

  /// No description provided for @clearSearch.
  ///
  /// In tr, this message translates to:
  /// **'Aramayı temizle'**
  String get clearSearch;

  /// No description provided for @detTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get detTime;

  /// No description provided for @detDur.
  ///
  /// In tr, this message translates to:
  /// **'Süre'**
  String get detDur;

  /// No description provided for @detForm.
  ///
  /// In tr, this message translates to:
  /// **'Diziliş'**
  String get detForm;

  /// No description provided for @reuseBtn.
  ///
  /// In tr, this message translates to:
  /// **'Kadroyu Takım Kur\'a aktar'**
  String get reuseBtn;

  /// No description provided for @delAppt.
  ///
  /// In tr, this message translates to:
  /// **'Randevuyu sil'**
  String get delAppt;

  /// No description provided for @deletedAppt.
  ///
  /// In tr, this message translates to:
  /// **'{name} randevusu silindi'**
  String deletedAppt(String name);

  /// No description provided for @reused.
  ///
  /// In tr, this message translates to:
  /// **'Kadro Takım Kur ekranına aktarıldı'**
  String get reused;

  /// No description provided for @detNoneT.
  ///
  /// In tr, this message translates to:
  /// **'Randevu seçilmedi'**
  String get detNoneT;

  /// No description provided for @detNoneD.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım listesinden bir randevu aç.'**
  String get detNoneD;

  /// No description provided for @detNoneBtn.
  ///
  /// In tr, this message translates to:
  /// **'Randevularım\'a git'**
  String get detNoneBtn;

  /// No description provided for @soFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş Ekle'**
  String get soFriends;

  /// No description provided for @soChats.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet'**
  String get soChats;

  /// No description provided for @userSearch.
  ///
  /// In tr, this message translates to:
  /// **'İsim ara'**
  String get userSearch;

  /// No description provided for @reqSend.
  ///
  /// In tr, this message translates to:
  /// **'İstek yolla'**
  String get reqSend;

  /// No description provided for @reqSentBtn.
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderildi'**
  String get reqSentBtn;

  /// No description provided for @reqSent.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine istek gönderildi'**
  String reqSent(String name);

  /// No description provided for @friendsYes.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşsınız'**
  String get friendsYes;

  /// No description provided for @msgUser.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile mesajlaş'**
  String msgUser(String name);

  /// No description provided for @noUsers.
  ///
  /// In tr, this message translates to:
  /// **'\"{q}\" adında örnek kullanıcı yok.'**
  String noUsers(String q);

  /// No description provided for @chatsEmptyT.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sohbet yok'**
  String get chatsEmptyT;

  /// No description provided for @chatsEmptyD.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş Ekle\'den birine mesaj göndererek başla.'**
  String get chatsEmptyD;

  /// No description provided for @chatsEmptyBtn.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş bul'**
  String get chatsEmptyBtn;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @you.
  ///
  /// In tr, this message translates to:
  /// **'Sen:'**
  String get you;

  /// No description provided for @chatNote.
  ///
  /// In tr, this message translates to:
  /// **'Örnek sohbet. Mesajları yalnızca ikiniz görürsünüz.'**
  String get chatNote;

  /// No description provided for @msgPh.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj yaz'**
  String get msgPh;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @msgBtn.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get msgBtn;

  /// No description provided for @eMsg.
  ///
  /// In tr, this message translates to:
  /// **'Önce bir mesaj yaz.'**
  String get eMsg;

  /// No description provided for @chatFirst.
  ///
  /// In tr, this message translates to:
  /// **'İlk mesajı yaz. Maç saatini ya da sahayı paylaşabilirsin.'**
  String get chatFirst;

  /// No description provided for @chatNoneT.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet seçilmedi'**
  String get chatNoneT;

  /// No description provided for @chatNoneD.
  ///
  /// In tr, this message translates to:
  /// **'Sohbet listesinden birini aç.'**
  String get chatNoneD;

  /// No description provided for @chatNoneBtn.
  ///
  /// In tr, this message translates to:
  /// **'Sohbetlere dön'**
  String get chatNoneBtn;

  /// No description provided for @noH.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get noH;

  /// No description provided for @markAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü okundu say'**
  String get markAll;

  /// No description provided for @sampleNotifs.
  ///
  /// In tr, this message translates to:
  /// **'Örnek bildirimler'**
  String get sampleNotifs;

  /// No description provided for @newTag.
  ///
  /// In tr, this message translates to:
  /// **'Yeni'**
  String get newTag;

  /// No description provided for @nRequest.
  ///
  /// In tr, this message translates to:
  /// **'{name} sana arkadaşlık isteği gönderdi'**
  String nRequest(String name);

  /// No description provided for @nAccepted.
  ///
  /// In tr, this message translates to:
  /// **'{name} arkadaşlık isteğini kabul etti'**
  String nAccepted(String name);

  /// No description provided for @nReminder.
  ///
  /// In tr, this message translates to:
  /// **'Maç hatırlatması, saat {time}'**
  String nReminder(String time);

  /// No description provided for @nMessage.
  ///
  /// In tr, this message translates to:
  /// **'{name} yeni mesaj gönderdi'**
  String nMessage(String name);

  /// No description provided for @noEmptyT.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim yok'**
  String get noEmptyT;

  /// No description provided for @noEmptyD.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaşlık istekleri, maç hatırlatmaları ve mesajlar burada görünür.'**
  String get noEmptyD;

  /// No description provided for @apptGone.
  ///
  /// In tr, this message translates to:
  /// **'Bu randevu silinmiş'**
  String get apptGone;

  /// No description provided for @allRead.
  ///
  /// In tr, this message translates to:
  /// **'Tüm bildirimler okundu'**
  String get allRead;

  /// No description provided for @agoM.
  ///
  /// In tr, this message translates to:
  /// **'{n} dk önce'**
  String agoM(String n);

  /// No description provided for @agoH.
  ///
  /// In tr, this message translates to:
  /// **'{n} sa önce'**
  String agoH(String n);

  /// No description provided for @agoD.
  ///
  /// In tr, this message translates to:
  /// **'{n} gün önce'**
  String agoD(String n);

  /// No description provided for @justNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get justNow;

  /// No description provided for @scrInvite.
  ///
  /// In tr, this message translates to:
  /// **'Maç daveti'**
  String get scrInvite;

  /// No description provided for @invTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisini maça davet et'**
  String invTitle(String name);

  /// No description provided for @invNeedMatch.
  ///
  /// In tr, this message translates to:
  /// **'Davet göndermek için önce Takım Kur ekranında diziliş, il, ilçe, saha ve saati seç.'**
  String get invNeedMatch;

  /// No description provided for @invFull.
  ///
  /// In tr, this message translates to:
  /// **'Kadronda teklif edilecek boş mevki yok. Takım Kur ekranında bir mevkiyi boşalt.'**
  String get invFull;

  /// No description provided for @goTeam.
  ///
  /// In tr, this message translates to:
  /// **'Takım Kur\'a git'**
  String get goTeam;

  /// No description provided for @invOfferPick.
  ///
  /// In tr, this message translates to:
  /// **'Teklif edilecek mevki'**
  String get invOfferPick;

  /// No description provided for @invSend.
  ///
  /// In tr, this message translates to:
  /// **'Daveti gönder'**
  String get invSend;

  /// No description provided for @invSent.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine {pos} teklifiyle davet gönderildi'**
  String invSent(String name, String pos);

  /// No description provided for @invWithdrawn.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine gönderilen davet geri çekildi'**
  String invWithdrawn(String name);

  /// No description provided for @invFriend.
  ///
  /// In tr, this message translates to:
  /// **'Maça davet et'**
  String get invFriend;

  /// No description provided for @invSentBtn.
  ///
  /// In tr, this message translates to:
  /// **'Davet gönderildi'**
  String get invSentBtn;

  /// No description provided for @invTo.
  ///
  /// In tr, this message translates to:
  /// **'kişisine davet gönderdin'**
  String get invTo;

  /// No description provided for @invSenderPending.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisinin yanıtı bekleniyor'**
  String invSenderPending(String name);

  /// No description provided for @invSenderAccepted.
  ///
  /// In tr, this message translates to:
  /// **'{name} kabul etti, {pos} mevkisine yazıldı'**
  String invSenderAccepted(String name, String pos);

  /// No description provided for @invSenderRejected.
  ///
  /// In tr, this message translates to:
  /// **'{name} daveti reddetti'**
  String invSenderRejected(String name);

  /// No description provided for @invOffered.
  ///
  /// In tr, this message translates to:
  /// **'{pos} teklif edildi'**
  String invOffered(String pos);

  /// No description provided for @invRefused.
  ///
  /// In tr, this message translates to:
  /// **'Daveti reddetti'**
  String get invRefused;

  /// No description provided for @invView.
  ///
  /// In tr, this message translates to:
  /// **'Daveti gör'**
  String get invView;

  /// No description provided for @waiting.
  ///
  /// In tr, this message translates to:
  /// **'{name} bekliyor'**
  String waiting(String name);

  /// No description provided for @slotWaiting.
  ///
  /// In tr, this message translates to:
  /// **'{pos}, {name} kişisinin yanıtı bekleniyor'**
  String slotWaiting(String name, String pos);

  /// No description provided for @nWaiting.
  ///
  /// In tr, this message translates to:
  /// **'{n} davet bekliyor'**
  String nWaiting(String n);

  /// No description provided for @waitText.
  ///
  /// In tr, this message translates to:
  /// **'{name} kişisine bu mevki için davet gönderildi. Yanıt bekleniyor.'**
  String waitText(String name);

  /// No description provided for @withdraw.
  ///
  /// In tr, this message translates to:
  /// **'Daveti geri çek'**
  String get withdraw;

  /// No description provided for @inInvites.
  ///
  /// In tr, this message translates to:
  /// **'Gelen davetler'**
  String get inInvites;

  /// No description provided for @inInvLine.
  ///
  /// In tr, this message translates to:
  /// **'{pos} teklif ediyor'**
  String inInvLine(String pos);

  /// No description provided for @invH.
  ///
  /// In tr, this message translates to:
  /// **'Maç daveti'**
  String get invH;

  /// No description provided for @invFrom.
  ///
  /// In tr, this message translates to:
  /// **'seni maçına davet ediyor'**
  String get invFrom;

  /// No description provided for @invOfferLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sana teklif edilen mevki'**
  String get invOfferLabel;

  /// No description provided for @invOfferDone.
  ///
  /// In tr, this message translates to:
  /// **'Adın bu mevkiye yazıldı'**
  String get invOfferDone;

  /// No description provided for @offerYou.
  ///
  /// In tr, this message translates to:
  /// **'Senin yerin'**
  String get offerYou;

  /// No description provided for @emptySlot.
  ///
  /// In tr, this message translates to:
  /// **'Boş'**
  String get emptySlot;

  /// No description provided for @offerRow.
  ///
  /// In tr, this message translates to:
  /// **'Boş, sana teklif edildi'**
  String get offerRow;

  /// No description provided for @invAccept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul et'**
  String get invAccept;

  /// No description provided for @invReject.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get invReject;

  /// No description provided for @invChat.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile sohbet et'**
  String invChat(String name);

  /// No description provided for @invAcceptedT.
  ///
  /// In tr, this message translates to:
  /// **'Davet kabul edildi. Adın {pos} mevkisine yazıldı.'**
  String invAcceptedT(String pos);

  /// No description provided for @invRejectedT.
  ///
  /// In tr, this message translates to:
  /// **'Davet reddedildi. {name} kişisine ret bildirimi gönderildi.'**
  String invRejectedT(String name);

  /// No description provided for @invStatusAcc.
  ///
  /// In tr, this message translates to:
  /// **'Kabul ettin. {name} ile artık arkadaşsınız.'**
  String invStatusAcc(String name);

  /// No description provided for @invStatusRej.
  ///
  /// In tr, this message translates to:
  /// **'Reddettin. {name} kişisine ret bildirimi gitti.'**
  String invStatusRej(String name);

  /// No description provided for @invRejQ.
  ///
  /// In tr, this message translates to:
  /// **'Daveti reddetmek istiyor musun?'**
  String get invRejQ;

  /// No description provided for @invRejD.
  ///
  /// In tr, this message translates to:
  /// **'Daveti gönderen kişiye ret bildirimi gidecek ve mevki onun kadrosunda yeniden boşalacak.'**
  String get invRejD;

  /// No description provided for @invRejYes.
  ///
  /// In tr, this message translates to:
  /// **'Evet, reddet'**
  String get invRejYes;

  /// No description provided for @invNoneT.
  ///
  /// In tr, this message translates to:
  /// **'Davet seçilmedi'**
  String get invNoneT;

  /// No description provided for @invNoneD.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlerden ya da Arkadaş Ekle listesinden bir davet aç.'**
  String get invNoneD;

  /// No description provided for @nInvite.
  ///
  /// In tr, this message translates to:
  /// **'{name} seni maçına davet etti'**
  String nInvite(String name);

  /// No description provided for @nInviteSub.
  ///
  /// In tr, this message translates to:
  /// **'{pos} teklif ediyor, {place}'**
  String nInviteSub(String place, String pos);

  /// No description provided for @nInvAcc.
  ///
  /// In tr, this message translates to:
  /// **'{name} davetini kabul etti'**
  String nInvAcc(String name);

  /// No description provided for @nInvAccSub.
  ///
  /// In tr, this message translates to:
  /// **'{pos} mevkisine yazıldı'**
  String nInvAccSub(String pos);

  /// No description provided for @nInvRej.
  ///
  /// In tr, this message translates to:
  /// **'{name} davetini reddetti'**
  String nInvRej(String name);

  /// No description provided for @nInvRejSub.
  ///
  /// In tr, this message translates to:
  /// **'{pos} yeniden boş'**
  String nInvRejSub(String pos);

  /// No description provided for @inviteGone.
  ///
  /// In tr, this message translates to:
  /// **'Bu davet artık yok'**
  String get inviteGone;

  /// No description provided for @prH.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get prH;

  /// No description provided for @prPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon'**
  String get prPhone;

  /// No description provided for @prEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi'**
  String get prEmail;

  /// No description provided for @prAppts.
  ///
  /// In tr, this message translates to:
  /// **'Randevu'**
  String get prAppts;

  /// No description provided for @prFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş'**
  String get prFriends;

  /// No description provided for @prLook.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get prLook;

  /// No description provided for @prAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get prAccount;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  /// No description provided for @noPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefon eklenmedi'**
  String get noPhone;

  /// No description provided for @fpSent.
  ///
  /// In tr, this message translates to:
  /// **'Şifre yenileme bağlantısı e-postana gönderildi.'**
  String get fpSent;

  /// No description provided for @eGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir sorun oluştu. Tekrar dene.'**
  String get eGeneric;

  /// Dil seçicide Türkçe (kendi dilinde, çevrilmez)
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get langTr;

  /// Dil seçicide İngilizce (kendi dilinde, çevrilmez)
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @delAcct.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get delAcct;

  /// No description provided for @delH.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını sil'**
  String get delH;

  /// No description provided for @delP.
  ///
  /// In tr, this message translates to:
  /// **'Profilin, iletişim bilgilerin, randevuların, davetlerin, arkadaşlıkların ve mesajların kalıcı olarak silinir. Bu işlem geri alınamaz. Onaylamak için şifreni yaz.'**
  String get delP;

  /// No description provided for @delBtn.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı kalıcı olarak sil'**
  String get delBtn;

  /// No description provided for @delBusy.
  ///
  /// In tr, this message translates to:
  /// **'Siliniyor…'**
  String get delBusy;

  /// No description provided for @accountDeleted.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silindi.'**
  String get accountDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
