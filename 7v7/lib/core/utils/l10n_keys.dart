import '../../l10n/app_localizations.dart';
import 'formation.dart';

/// Servis ve doğrulayıcıların döndürdüğü ARB anahtarlarını metne çevirir.
String errorText(AppLocalizations l, String key) => switch (key) {
      'eName' => l.eName,
      'eEmail' => l.eEmail,
      'ePassword' => l.ePassword,
      'ePwlen' => l.ePwlen,
      'eNoacct' => l.eNoacct,
      'eWrongpw' => l.eWrongpw,
      'eExists' => l.eExists,
      'ePhoneExists' => l.ePhoneExists,
      'eFirst' => l.eFirst,
      'eLast' => l.eLast,
      'ePhone' => l.ePhone,
      'eTerms' => l.eTerms,
      'eKvkk' => l.eKvkk,
      'ePfirst' => l.ePfirst,
      'eMsg' => l.eMsg,
      _ => l.eGeneric,
    };

/// Çizginin yerelleştirilmiş adı.
String lineName(AppLocalizations l, Line line) => switch (line) {
      Line.gk => l.posGk,
      Line.def => l.posDef,
      Line.mid => l.posMid,
      Line.att => l.posAtt,
    };

/// Mevki adı ("Defans 2", "Orta Saha").
String posName(AppLocalizations l, String? formation, String slotId) =>
    positionName(slotInfo(formation, slotId), (x) => lineName(l, x));

/// "X dk önce" metni.
String agoText(AppLocalizations l, ({String key, int n}) a) => switch (a.key) {
      'agoM' => l.agoM('${a.n}'),
      'agoH' => l.agoH('${a.n}'),
      'agoD' => l.agoD('${a.n}'),
      _ => l.justNow,
    };
