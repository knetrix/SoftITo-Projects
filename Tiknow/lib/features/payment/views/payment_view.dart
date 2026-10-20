import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/utils/money_formatter.dart';
import '../../rental_map/models/vehicle_model.dart';
import '../../rental_packages/models/rental_package_model.dart';
import '../controllers/payment_controller.dart';
import '../models/payment_model.dart';
import '../widgets/card_form_widget.dart';
import '../widgets/payment_summary_widget.dart';

/// Test ödeme ekranı (gerçek ödeme YOK). Başarılı ödemede `true` ile kapanır;
/// aktif kiralamayı çağıran taraf başlatır.
class PaymentView extends StatefulWidget {
  const PaymentView({super.key, required this.vehicle, required this.plan});

  final VehicleModel vehicle;
  final RentalPlan plan;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late final PaymentController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pay(PaymentModel card) async {
    final ok = await _controller.pay(card);
    if (!ok) return;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop(true);
  }

  String _submitLabel(BuildContext context) {
    final package = widget.plan.package;
    if (package == null) return context.tr('start_rental');
    return context.tr(
      'pay_amount',
      args: {'price': MoneyFormatter.format(package.price)},
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        return PopScope(
          canPop: state != PaymentState.processing,
          child: Scaffold(
            appBar: AppBar(title: Text(context.tr('payment'))),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PaymentSummaryWidget(
                    vehicle: widget.vehicle,
                    plan: widget.plan,
                  ),
                  const SizedBox(height: 16),
                  _StatusBanner(controller: _controller),
                  CardFormWidget(
                    state: _controller.state,
                    submitLabel: _submitLabel(context),
                    onSubmit: _pay,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaymentState>(
      valueListenable: controller.state,
      builder: (context, state, _) {
        final scheme = context.colors;
        final (text, color, icon) = switch (state) {
          PaymentState.success => (
              context.tr('payment_success'),
              scheme.primary,
              Icons.check_circle,
            ),
          PaymentState.failure => (
              context.tr(controller.errorKey.value ?? 'err_payment_declined'),
              scheme.error,
              Icons.error_outline,
            ),
          PaymentState.processing => (
              context.tr('payment_processing'),
              scheme.onSurfaceVariant,
              Icons.hourglass_top,
            ),
          PaymentState.initial => (
              context.tr('payment_test_note'),
              scheme.onSurfaceVariant,
              Icons.info_outline,
            ),
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: context.textStyles.bodyMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
