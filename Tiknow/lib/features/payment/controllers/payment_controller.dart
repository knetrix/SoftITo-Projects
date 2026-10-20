import 'package:flutter/foundation.dart';

import '../models/payment_model.dart';

/// Test ödeme akışı: initial -> processing -> success | failure.
/// Gerçek ödeme YOKTUR; kart bilgisi hiçbir yere gönderilmez/saklanmaz.
class PaymentController {
  PaymentController({this.processingDelay = const Duration(seconds: 2)});

  final Duration processingDelay;
  final ValueNotifier<PaymentState> state =
      ValueNotifier<PaymentState>(PaymentState.initial);

  /// Başarısızlıkta gösterilecek hata anahtarı.
  final ValueNotifier<String?> errorKey = ValueNotifier<String?>(null);

  Future<bool> pay(PaymentModel card) async {
    if (state.value == PaymentState.processing) return false;
    errorKey.value = null;
    state.value = PaymentState.processing;
    await Future<void>.delayed(processingDelay);

    if (card.isDeclinedTestCard) {
      errorKey.value = 'err_payment_declined';
      state.value = PaymentState.failure;
      return false;
    }
    state.value = PaymentState.success;
    return true;
  }

  void dispose() {
    state.dispose();
    errorKey.dispose();
  }
}
