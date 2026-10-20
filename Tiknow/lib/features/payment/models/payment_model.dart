import 'package:flutter/foundation.dart';

enum PaymentState { initial, processing, success, failure }

/// Test ödeme kartı (gerçek ödeme YOK, hiçbir yere gönderilmez).
@immutable
class PaymentModel {
  const PaymentModel({
    required this.cardNumber,
    required this.holderName,
    required this.expiry,
    required this.cvv,
  });

  final String cardNumber;
  final String holderName;
  final String expiry; // AA/YY
  final String cvv;

  /// Test kuralı: `0000` ile biten kartlar reddedilir.
  bool get isDeclinedTestCard =>
      cardNumber.replaceAll(RegExp(r'[\s-]'), '').endsWith('0000');
}
