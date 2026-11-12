// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get scrWelcome => 'Hoş geldin';

  @override
  String get scrSignin => 'Giriş';

  @override
  String get scrSignup => 'Hesap oluştur';

  @override
  String get scrTeam => 'Takım Kur';

  @override
  String get scrAppointments => 'Randevularım';

  @override
  String get scrAppointmentDetail => 'Randevu ayrıntısı';

  @override
  String get scrProfile => 'Profil';

  @override
  String get scrSocial => 'Sohbet ve Arkadaşlar';

  @override
  String get scrChat => 'Mesajlaşma';

  @override
  String get scrNotifications => 'Bildirimler';

  @override
  String signedIn(String name) {
    return '$name olarak giriş yapıldı';
  }

  @override
  String get signedOut => 'Çıkış yapıldı';

  @override
  String get eName => 'En az 2 karakter gir.';

  @override
  String get eEmail => 'Geçerli bir e-posta adresi yaz.';

  @override
  String get ePassword => 'Şifreni yaz.';

  @override
  String get ePwlen => 'En az 8 karakter kullan.';

  @override
  String get eNoacct => 'Bu e-postayla kayıtlı hesap yok.';

  @override
  String get eWrongpw => 'Şifre yanlış. Tekrar dene ya da şifreni yenile.';

  @override
  String get eExists => 'Bu e-postayla zaten bir hesap var. Giriş yap.';

  @override
  String get ePhoneExists =>
      'Bu telefon numarasıyla zaten bir hesap var. Giriş yap.';

  @override
  String get undo => 'Geri al';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Açık mod';

  @override
  String get dark => 'Karanlık mod';

  @override
  String get language => 'Dil';

  @override
  String get onbH => 'Yedi kişilik kadronu sahaya diz.';

  @override
  String get onbP => 'Dizilişi seç, yelekleri dağıt, sahayı ve saati ayarla.';

  @override
  String get onbF1 => '5 diziliş, kaleci her zaman sabit';

  @override
  String get onbF2 => '81 ilde örnek saha ve saat seçimi';

  @override
  String get onbF3 => 'Takım arkadaşlarınla sohbet';

  @override
  String get onbStart => 'Başla';

  @override
  String get onbHave => 'Hesabım var, giriş yap';

  @override
  String get imgWelcome =>
      'Sahada yığılmış file yelekler, en üstte turuncu kaleci yeleği ve yanında top';

  @override
  String get imgSignin =>
      'Katlanmış yeşil ve turuncu yelekler, yanında antrenman hunileri';

  @override
  String get imgPitch => 'Halı sahanın örnek görseli';

  @override
  String get imgEmptyAppts => 'Boş halı sahada kalenin önünde duran top';

  @override
  String get imgEmptyChats =>
      'Saha kenarındaki bankta su şişeleri ve katlanmış turuncu yelek';

  @override
  String get onbArt => '2-3-1 dizilişinde sahaya dizilmiş yedi numaralı yelek';

  @override
  String get siH => 'Giriş yap';

  @override
  String get siP => 'Kadronu kaldığın yerden kurmaya devam et.';

  @override
  String get fPw => 'Şifre';

  @override
  String get showPw => 'Şifreyi göster';

  @override
  String get hidePw => 'Şifreyi gizle';

  @override
  String get forgot => 'Şifremi unuttum';

  @override
  String get siBtn => 'Giriş yap';

  @override
  String get siBusy => 'Giriş yapılıyor…';

  @override
  String get noAcct => 'Hesabın yok mu?';

  @override
  String get toSignup => 'Hesap oluştur';

  @override
  String get fpH => 'Şifreni yenile';

  @override
  String get fpP =>
      'Hesabının e-posta adresini yaz, şifre yenileme bağlantısını gönderelim.';

  @override
  String get fEmail => 'E-posta';

  @override
  String get fNewpw => 'Yeni şifre';

  @override
  String get fpBtn => 'Bağlantıyı gönder';

  @override
  String get fpBusy => 'Gönderiliyor…';

  @override
  String get suH => 'Hesap oluştur';

  @override
  String get suP => 'Kadronu kurmak için birkaç bilgi yeter.';

  @override
  String get fFirst => 'Ad';

  @override
  String get fLast => 'Soyad';

  @override
  String get fPhone => 'Telefon numarası';

  @override
  String get pwHint => 'En az 8 karakter';

  @override
  String get suBtn => 'Hesap oluştur';

  @override
  String get suBusy => 'Hesap oluşturuluyor…';

  @override
  String get agreeTermsA => 'Kullanıcı Sözleşmesi';

  @override
  String get agreeKvkkA => 'KVKK Aydınlatma Metni';

  @override
  String get agreeSuffix => 'okudum ve anladım.';

  @override
  String get chkTerms => 'Kullanıcı Sözleşmesini okudum ve anladım';

  @override
  String get chkKvkk => 'KVKK metnini okudum ve anladım';

  @override
  String get eFirst => 'Adını yaz.';

  @override
  String get eLast => 'Soyadını yaz.';

  @override
  String get ePhone => 'Telefon numaranı 05XX XXX XX XX biçiminde yaz.';

  @override
  String get eTerms => 'Devam etmek için sözleşmeyi onayla.';

  @override
  String get eKvkk => 'Devam etmek için KVKK metnini onayla.';

  @override
  String get hasAcct => 'Zaten hesabın var mı?';

  @override
  String get toSignin => 'Giriş yap';

  @override
  String get accountCreated => 'Hesap oluşturuldu. Şimdi giriş yap.';

  @override
  String get legalNote =>
      'Örnek metin. Yayından önce hukuk uzmanı tarafından hazırlanacak.';

  @override
  String get termsP1 =>
      '7v7, halı saha takımı ve maç organizasyonu kurmana yardım eden bir uygulamadır. Bu sürüm bir prototiptir.';

  @override
  String get termsP2 =>
      'Uygulamada gösterilen saha adları örnektir. Bu sürümde gerçek rezervasyon ya da ödeme yapılmaz.';

  @override
  String get termsP3 =>
      'Başka kullanıcılara saygılı davranmayı ve sohbetlerde hakaret içeren içerik paylaşmamayı kabul edersin.';

  @override
  String get kvkkP1 =>
      'Ad, soyad, e-posta ve telefon bilgin hesabını oluşturmak için kullanılır.';

  @override
  String get kvkkP2 =>
      'Bu prototipte bilgilerin yalnızca uygulamanın çalışması için Firebase\'de saklanır.';

  @override
  String get kvkkP3 =>
      'Verilerinin silinmesini istediğin an talep edebilirsin.';

  @override
  String get legalOk => 'Okudum, onaylıyorum';

  @override
  String get tabTeam => 'Takım Kur';

  @override
  String get tabAppts => 'Randevularım';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabSocial => 'Sohbet';

  @override
  String get notifBtn => 'Bildirimler';

  @override
  String notifUnread(String n) {
    return '$n okunmamış';
  }

  @override
  String get back => 'Geri';

  @override
  String get locCity => 'İl';

  @override
  String get locDistrict => 'İlçe';

  @override
  String get locStadium => 'Saha';

  @override
  String get pick => 'Seç';

  @override
  String get required => 'Gerekli';

  @override
  String get matchTime => 'Maç saati';

  @override
  String get oneHour => '1 saat';

  @override
  String get squad => 'Kadro';

  @override
  String squadN(String n) {
    return '$n/7 oyuncu';
  }

  @override
  String formationBtn(String f) {
    return 'Diziliş $f';
  }

  @override
  String get formationNone => 'Diziliş seç';

  @override
  String get saveTeam => 'Takımı kaydet';

  @override
  String get pickFormationFirst => 'Kadroyu dizmek için önce diziliş seç.';

  @override
  String get missing => 'Eksik:';

  @override
  String get mFormation => 'diziliş';

  @override
  String mPlayers(String n) {
    return '$n oyuncu';
  }

  @override
  String get mCity => 'il';

  @override
  String get mDistrict => 'ilçe';

  @override
  String get mStadium => 'saha';

  @override
  String get mTime => 'maç saati';

  @override
  String get posGk => 'Kaleci';

  @override
  String get posDef => 'Defans';

  @override
  String get posMid => 'Orta Saha';

  @override
  String get posAtt => 'Hücum';

  @override
  String addPlayerTo(String pos) {
    return '$pos mevkisine oyuncu ekle';
  }

  @override
  String editPlayer(String name, String pos) {
    return '$name, $pos. Düzenle';
  }

  @override
  String get fpTitle => 'Diziliş seç';

  @override
  String get fpSub => 'Kaleci her dizilişte sabit. Toplam 7 oyuncu.';

  @override
  String fdD(String n) {
    return '$n defans';
  }

  @override
  String fdM(String n) {
    return '$n orta saha';
  }

  @override
  String fdA(String n) {
    return '$n hücum';
  }

  @override
  String movedOne(String name, String pos) {
    return '$name yeni dizilişte $pos mevkisine geçti';
  }

  @override
  String movedMany(String names) {
    return 'Yeni dizilişte yer değiştirenler: $names';
  }

  @override
  String formationSet(String f) {
    return 'Diziliş $f olarak ayarlandı';
  }

  @override
  String get fLastOpt => 'Soyad (isteğe bağlı)';

  @override
  String get ppSave => 'Oyuncuyu kaydet';

  @override
  String get ppRemove => 'Oyuncuyu çıkar';

  @override
  String get ePfirst => 'Oyuncunun adını yaz.';

  @override
  String eDup(String name, String pos) {
    return '$name zaten $pos mevkisinde. Aynı kişiyi iki mevkiye yazamazsın, farklı bir oyuncu gir.';
  }

  @override
  String playerSaved(String name, String pos) {
    return '$name, $pos mevkisine eklendi';
  }

  @override
  String playerUpdated(String name) {
    return '$name güncellendi';
  }

  @override
  String playerRemoved(String name) {
    return '$name kadrodan çıkarıldı';
  }

  @override
  String get cpTitle => 'İl seç';

  @override
  String get cpSearch => 'İl ara';

  @override
  String get cpSub => 'Türkiye\'nin 81 ili';

  @override
  String noCity(String q) {
    return '\"$q\" ile eşleşen il yok.';
  }

  @override
  String get cityChanged => 'İl değişti. İlçe ve sahayı yeniden seç.';

  @override
  String get dpTitle => 'İlçe seç';

  @override
  String get dpNeed => 'İlçeleri görmek için önce il seç.';

  @override
  String get dpSample => 'Örnek ilçe listesi';

  @override
  String get spTitle => 'Halı saha seç';

  @override
  String get spNeed => 'Sahaları görmek için önce ilçe seç.';

  @override
  String get spSample => 'Örnek saha adları. Gerçek rezervasyon yapılmaz.';

  @override
  String get tpTitle => 'Maç saati seç';

  @override
  String get tpSub => 'Her maç 1 saat sürer.';

  @override
  String get savedAppt => 'Randevu kaydedildi';

  @override
  String get apH => 'Randevularım';

  @override
  String get sampleTag => 'Örnek';

  @override
  String get guestTag => 'Davetli';

  @override
  String get buildingTag => 'Kadro kuruluyor';

  @override
  String get organizer => 'Organizatör';

  @override
  String nSaved(String name, String time) {
    return '$name maçı kaydetti, saat $time';
  }

  @override
  String get newMatch => 'Yeni maç kur';

  @override
  String get apSearch => 'Saha, ilçe veya oyuncu ara';

  @override
  String get fAll => 'Tümü';

  @override
  String get fDay => 'Gündüz';

  @override
  String get fEve => 'Akşam';

  @override
  String nAppts(String n) {
    return '$n randevu';
  }

  @override
  String playersN(String n) {
    return '$n oyuncu';
  }

  @override
  String get apEmptyT => 'Henüz randevu yok';

  @override
  String get apEmptyD =>
      'Takım Kur ekranında kadroyu, sahayı ve saati seç, yeşil tikle kaydet.';

  @override
  String get apEmptyBtn => 'Takım kur';

  @override
  String get apNone => 'Bu aramayla eşleşen randevu yok.';

  @override
  String get clearSearch => 'Aramayı temizle';

  @override
  String get detTime => 'Saat';

  @override
  String get detDur => 'Süre';

  @override
  String get detForm => 'Diziliş';

  @override
  String get reuseBtn => 'Kadroyu Takım Kur\'a aktar';

  @override
  String get delAppt => 'Randevuyu sil';

  @override
  String deletedAppt(String name) {
    return '$name randevusu silindi';
  }

  @override
  String get reused => 'Kadro Takım Kur ekranına aktarıldı';

  @override
  String get detNoneT => 'Randevu seçilmedi';

  @override
  String get detNoneD => 'Randevularım listesinden bir randevu aç.';

  @override
  String get detNoneBtn => 'Randevularım\'a git';

  @override
  String get soFriends => 'Arkadaş Ekle';

  @override
  String get soChats => 'Sohbet';

  @override
  String get userSearch => 'İsim ara';

  @override
  String get reqSend => 'İstek yolla';

  @override
  String get reqSentBtn => 'İstek gönderildi';

  @override
  String reqSent(String name) {
    return '$name kişisine istek gönderildi';
  }

  @override
  String get friendsYes => 'Arkadaşsınız';

  @override
  String msgUser(String name) {
    return '$name ile mesajlaş';
  }

  @override
  String noUsers(String q) {
    return '\"$q\" adında örnek kullanıcı yok.';
  }

  @override
  String get chatsEmptyT => 'Henüz sohbet yok';

  @override
  String get chatsEmptyD => 'Arkadaş Ekle\'den birine mesaj göndererek başla.';

  @override
  String get chatsEmptyBtn => 'Arkadaş bul';

  @override
  String get yesterday => 'Dün';

  @override
  String get you => 'Sen:';

  @override
  String get chatNote => 'Örnek sohbet. Mesajları yalnızca ikiniz görürsünüz.';

  @override
  String get msgPh => 'Mesaj yaz';

  @override
  String get send => 'Gönder';

  @override
  String get msgBtn => 'Mesaj';

  @override
  String get eMsg => 'Önce bir mesaj yaz.';

  @override
  String get chatFirst =>
      'İlk mesajı yaz. Maç saatini ya da sahayı paylaşabilirsin.';

  @override
  String get chatNoneT => 'Sohbet seçilmedi';

  @override
  String get chatNoneD => 'Sohbet listesinden birini aç.';

  @override
  String get chatNoneBtn => 'Sohbetlere dön';

  @override
  String get noH => 'Bildirimler';

  @override
  String get markAll => 'Tümünü okundu say';

  @override
  String get sampleNotifs => 'Örnek bildirimler';

  @override
  String get newTag => 'Yeni';

  @override
  String nRequest(String name) {
    return '$name sana arkadaşlık isteği gönderdi';
  }

  @override
  String nAccepted(String name) {
    return '$name arkadaşlık isteğini kabul etti';
  }

  @override
  String nReminder(String time) {
    return 'Maç hatırlatması, saat $time';
  }

  @override
  String nMessage(String name) {
    return '$name yeni mesaj gönderdi';
  }

  @override
  String get noEmptyT => 'Bildirim yok';

  @override
  String get noEmptyD =>
      'Arkadaşlık istekleri, maç hatırlatmaları ve mesajlar burada görünür.';

  @override
  String get apptGone => 'Bu randevu silinmiş';

  @override
  String get allRead => 'Tüm bildirimler okundu';

  @override
  String agoM(String n) {
    return '$n dk önce';
  }

  @override
  String agoH(String n) {
    return '$n sa önce';
  }

  @override
  String agoD(String n) {
    return '$n gün önce';
  }

  @override
  String get justNow => 'Şimdi';

  @override
  String get scrInvite => 'Maç daveti';

  @override
  String invTitle(String name) {
    return '$name kişisini maça davet et';
  }

  @override
  String get invNeedMatch =>
      'Davet göndermek için önce Takım Kur ekranında diziliş, il, ilçe, saha ve saati seç.';

  @override
  String get invFull =>
      'Kadronda teklif edilecek boş mevki yok. Takım Kur ekranında bir mevkiyi boşalt.';

  @override
  String get goTeam => 'Takım Kur\'a git';

  @override
  String get invOfferPick => 'Teklif edilecek mevki';

  @override
  String get invSend => 'Daveti gönder';

  @override
  String invSent(String name, String pos) {
    return '$name kişisine $pos teklifiyle davet gönderildi';
  }

  @override
  String invWithdrawn(String name) {
    return '$name kişisine gönderilen davet geri çekildi';
  }

  @override
  String get invFriend => 'Maça davet et';

  @override
  String get invSentBtn => 'Davet gönderildi';

  @override
  String get invTo => 'kişisine davet gönderdin';

  @override
  String invSenderPending(String name) {
    return '$name kişisinin yanıtı bekleniyor';
  }

  @override
  String invSenderAccepted(String name, String pos) {
    return '$name kabul etti, $pos mevkisine yazıldı';
  }

  @override
  String invSenderRejected(String name) {
    return '$name daveti reddetti';
  }

  @override
  String invOffered(String pos) {
    return '$pos teklif edildi';
  }

  @override
  String get invRefused => 'Daveti reddetti';

  @override
  String get invView => 'Daveti gör';

  @override
  String waiting(String name) {
    return '$name bekliyor';
  }

  @override
  String slotWaiting(String name, String pos) {
    return '$pos, $name kişisinin yanıtı bekleniyor';
  }

  @override
  String nWaiting(String n) {
    return '$n davet bekliyor';
  }

  @override
  String waitText(String name) {
    return '$name kişisine bu mevki için davet gönderildi. Yanıt bekleniyor.';
  }

  @override
  String get withdraw => 'Daveti geri çek';

  @override
  String get inInvites => 'Gelen davetler';

  @override
  String inInvLine(String pos) {
    return '$pos teklif ediyor';
  }

  @override
  String get invH => 'Maç daveti';

  @override
  String get invFrom => 'seni maçına davet ediyor';

  @override
  String get invOfferLabel => 'Sana teklif edilen mevki';

  @override
  String get invOfferDone => 'Adın bu mevkiye yazıldı';

  @override
  String get offerYou => 'Senin yerin';

  @override
  String get emptySlot => 'Boş';

  @override
  String get offerRow => 'Boş, sana teklif edildi';

  @override
  String get invAccept => 'Kabul et';

  @override
  String get invReject => 'Reddet';

  @override
  String invChat(String name) {
    return '$name ile sohbet et';
  }

  @override
  String invAcceptedT(String pos) {
    return 'Davet kabul edildi. Adın $pos mevkisine yazıldı.';
  }

  @override
  String invRejectedT(String name) {
    return 'Davet reddedildi. $name kişisine ret bildirimi gönderildi.';
  }

  @override
  String invStatusAcc(String name) {
    return 'Kabul ettin. $name ile artık arkadaşsınız.';
  }

  @override
  String invStatusRej(String name) {
    return 'Reddettin. $name kişisine ret bildirimi gitti.';
  }

  @override
  String get invRejQ => 'Daveti reddetmek istiyor musun?';

  @override
  String get invRejD =>
      'Daveti gönderen kişiye ret bildirimi gidecek ve mevki onun kadrosunda yeniden boşalacak.';

  @override
  String get invRejYes => 'Evet, reddet';

  @override
  String get invNoneT => 'Davet seçilmedi';

  @override
  String get invNoneD =>
      'Bildirimlerden ya da Arkadaş Ekle listesinden bir davet aç.';

  @override
  String nInvite(String name) {
    return '$name seni maçına davet etti';
  }

  @override
  String nInviteSub(String place, String pos) {
    return '$pos teklif ediyor, $place';
  }

  @override
  String nInvAcc(String name) {
    return '$name davetini kabul etti';
  }

  @override
  String nInvAccSub(String pos) {
    return '$pos mevkisine yazıldı';
  }

  @override
  String nInvRej(String name) {
    return '$name davetini reddetti';
  }

  @override
  String nInvRejSub(String pos) {
    return '$pos yeniden boş';
  }

  @override
  String get inviteGone => 'Bu davet artık yok';

  @override
  String get prH => 'Profil';

  @override
  String get prPhone => 'Telefon';

  @override
  String get prEmail => 'E-posta adresi';

  @override
  String get prAppts => 'Randevu';

  @override
  String get prFriends => 'Arkadaş';

  @override
  String get prLook => 'Görünüm';

  @override
  String get prAccount => 'Hesap';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get noPhone => 'Telefon eklenmedi';

  @override
  String get fpSent => 'Şifre yenileme bağlantısı e-postana gönderildi.';

  @override
  String get eGeneric => 'Bir sorun oluştu. Tekrar dene.';

  @override
  String get langTr => 'Türkçe';

  @override
  String get langEn => 'English';

  @override
  String get delAcct => 'Hesabı sil';

  @override
  String get delH => 'Hesabını sil';

  @override
  String get delP =>
      'Profilin, iletişim bilgilerin, randevuların, davetlerin, arkadaşlıkların ve mesajların kalıcı olarak silinir. Bu işlem geri alınamaz. Onaylamak için şifreni yaz.';

  @override
  String get delBtn => 'Hesabı kalıcı olarak sil';

  @override
  String get delBusy => 'Siliniyor…';

  @override
  String get accountDeleted => 'Hesabın silindi.';
}
