import 'package:flutter/widgets.dart';

/// Phosphor Icons — yalnızca Fill ağırlığı (§2.6).
///
/// `phosphor_flutter` paketinin Fill fontu kullanılır; paketin `PhosphorIconData`
/// sınıfı güncel Flutter'da (`IconData` final) derlenmediği için kod noktaları
/// burada düz `IconData` sabitleri olarak tanımlanır.
abstract final class PhosphorIconsFill {
  static const IconData bell = IconData(0xe0ce, fontFamily: _f, fontPackage: _p);
  static const IconData calendarCheck = IconData(0xe712, fontFamily: _f, fontPackage: _p);
  static const IconData caretLeft = IconData(0xe138, fontFamily: _f, fontPackage: _p);
  static const IconData caretRight = IconData(0xe13a, fontFamily: _f, fontPackage: _p);
  static const IconData chatCircleDots = IconData(0xe16c, fontFamily: _f, fontPackage: _p);
  static const IconData chatsCircle = IconData(0xe17e, fontFamily: _f, fontPackage: _p);
  static const IconData check = IconData(0xe182, fontFamily: _f, fontPackage: _p);
  static const IconData checkCircle = IconData(0xe184, fontFamily: _f, fontPackage: _p);
  static const IconData clock = IconData(0xe19a, fontFamily: _f, fontPackage: _p);
  static const IconData envelope = IconData(0xe214, fontFamily: _f, fontPackage: _p);
  static const IconData eye = IconData(0xe220, fontFamily: _f, fontPackage: _p);
  static const IconData eyeSlash = IconData(0xe224, fontFamily: _f, fontPackage: _p);
  static const IconData hourglass = IconData(0xe2b2, fontFamily: _f, fontPackage: _p);
  static const IconData magnifyingGlass = IconData(0xe30c, fontFamily: _f, fontPackage: _p);
  static const IconData mapPin = IconData(0xe316, fontFamily: _f, fontPackage: _p);
  static const IconData paperPlaneRight = IconData(0xe396, fontFamily: _f, fontPackage: _p);
  static const IconData phone = IconData(0xe3b8, fontFamily: _f, fontPackage: _p);
  static const IconData plus = IconData(0xe3d4, fontFamily: _f, fontPackage: _p);
  static const IconData signOut = IconData(0xe42a, fontFamily: _f, fontPackage: _p);
  static const IconData soccerBall = IconData(0xe716, fontFamily: _f, fontPackage: _p);
  static const IconData strategy = IconData(0xea3a, fontFamily: _f, fontPackage: _p);
  static const IconData trash = IconData(0xe4a6, fontFamily: _f, fontPackage: _p);
  static const IconData userCircle = IconData(0xe4c4, fontFamily: _f, fontPackage: _p);
  static const IconData userPlus = IconData(0xe4d0, fontFamily: _f, fontPackage: _p);
  static const IconData usersThree = IconData(0xe68e, fontFamily: _f, fontPackage: _p);
  static const IconData warningCircle = IconData(0xe4e2, fontFamily: _f, fontPackage: _p);
  static const IconData x = IconData(0xe4f6, fontFamily: _f, fontPackage: _p);

  static const _f = 'PhosphorFill';
  static const _p = 'phosphor_flutter';
}
