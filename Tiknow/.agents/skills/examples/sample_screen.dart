import 'package:flutter/material.dart';

/// Tiknow - Örnek Feature Model: İmmutable Aktif Kiralama Modeli
@immutable
class RentalSampleModel {
  final int includedMinutes;
  final int includedKm;
  final int usedMinutes;
  final int usedKm;
  final double extraPerMinute; // Aşım: TL/dk
  final double extraPerKm; // Aşım: TL/km
  final double extrasFee; // Kullanıcının sonradan eklediği süre/km ücretleri

  const RentalSampleModel({
    required this.includedMinutes,
    required this.includedKm,
    required this.usedMinutes,
    required this.usedKm,
    required this.extraPerMinute,
    required this.extraPerKm,
    this.extrasFee = 0,
  });

  /// Saf fiyat fonksiyonu: aşım ücreti + eklemeler (test edilebilir).
  double get overageFee {
    final overMin = (usedMinutes - includedMinutes).clamp(0, 1 << 31);
    final overKm = (usedKm - includedKm).clamp(0, 1 << 31);
    return overMin * extraPerMinute + overKm * extraPerKm;
  }

  double get totalExtraFee => overageFee + extrasFee;

  RentalSampleModel copyWith({
    int? includedMinutes,
    int? includedKm,
    int? usedMinutes,
    int? usedKm,
    double? extraPerMinute,
    double? extraPerKm,
    double? extrasFee,
  }) {
    return RentalSampleModel(
      includedMinutes: includedMinutes ?? this.includedMinutes,
      includedKm: includedKm ?? this.includedKm,
      usedMinutes: usedMinutes ?? this.usedMinutes,
      usedKm: usedKm ?? this.usedKm,
      extraPerMinute: extraPerMinute ?? this.extraPerMinute,
      extraPerKm: extraPerKm ?? this.extraPerKm,
      extrasFee: extrasFee ?? this.extrasFee,
    );
  }

  factory RentalSampleModel.fromJson(Map<String, dynamic> json) {
    return RentalSampleModel(
      includedMinutes: json['includedMinutes'] as int? ?? 60,
      includedKm: json['includedKm'] as int? ?? 30,
      usedMinutes: json['usedMinutes'] as int? ?? 0,
      usedKm: json['usedKm'] as int? ?? 0,
      extraPerMinute: (json['extraPerMinute'] as num?)?.toDouble() ?? 2.9,
      extraPerKm: (json['extraPerKm'] as num?)?.toDouble() ?? 2.9,
      extrasFee: (json['extrasFee'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'includedMinutes': includedMinutes,
      'includedKm': includedKm,
      'usedMinutes': usedMinutes,
      'usedKm': usedKm,
      'extraPerMinute': extraPerMinute,
      'extraPerKm': extraPerKm,
      'extrasFee': extrasFee,
    };
  }
}

/// Tiknow - Örnek Feature Controller: ValueNotifier tabanlı hafif durum yöneticisi
class RentalSampleController {
  final ValueNotifier<RentalSampleModel> state =
      ValueNotifier<RentalSampleModel>(
    const RentalSampleModel(
      includedMinutes: 60,
      includedKm: 30,
      usedMinutes: 20,
      usedKm: 8,
      extraPerMinute: 2.9,
      extraPerKm: 2.9,
    ),
  );

  void simulateDrive({int minutes = 10, int km = 5}) {
    final s = state.value;
    state.value = s.copyWith(
      usedMinutes: s.usedMinutes + minutes,
      usedKm: s.usedKm + km,
    );
  }

  /// Süre/km ekleme: hak artar, ücret bitişte ekstra olarak toplanır.
  void addKm(int km, double pricePerKm) {
    final s = state.value;
    state.value = s.copyWith(
      includedKm: s.includedKm + km,
      extrasFee: s.extrasFee + km * pricePerKm,
    );
  }

  void dispose() {
    state.dispose();
  }
}

/// Tiknow - Örnek CustomPainter: Kullanım Çubuğu (Harici Paketsiz)
class UsageBarPainter extends CustomPainter {
  final double ratio; // 0..1 (taşarsa 1'e kırpılır)
  final Color fillColor;
  final Color trackColor;

  const UsageBarPainter({
    required this.ratio,
    required this.fillColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, radius);
    canvas.drawRRect(track, Paint()..color = trackColor);

    final fillWidth = size.width * ratio.clamp(0.0, 1.0);
    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      radius,
    );
    canvas.drawRRect(fill, Paint()..color = fillColor);
  }

  @override
  bool shouldRepaint(covariant UsageBarPainter oldDelegate) {
    return oldDelegate.ratio != ratio ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.trackColor != trackColor;
  }
}

/// Tiknow - Örnek Feature View
/// Not: Gerçek projede metinler context.tr('key') ile, renkler tema üzerinden gelir.
class RentalSampleScreen extends StatefulWidget {
  const RentalSampleScreen({super.key});

  @override
  State<RentalSampleScreen> createState() => _RentalSampleScreenState();
}

class _RentalSampleScreenState extends State<RentalSampleScreen> {
  late final RentalSampleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RentalSampleController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tiknow - Aktif Kiralama')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<RentalSampleModel>(
            valueListenable: _controller.state,
            builder: (context, s, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Süre: ${s.usedMinutes}/${s.includedMinutes} dk'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 10,
                    child: CustomPaint(
                      painter: UsageBarPainter(
                        ratio: s.usedMinutes / s.includedMinutes,
                        fillColor: scheme.primary,
                        trackColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Km: ${s.usedKm}/${s.includedKm} km'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 10,
                    child: CustomPaint(
                      painter: UsageBarPainter(
                        ratio: s.usedKm / s.includedKm,
                        fillColor: scheme.primary,
                        trackColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Ekstra Ücret: ${s.totalExtraFee.toStringAsFixed(2)} TL'),
                  const Spacer(),
                  FilledButton(
                    onPressed: _controller.simulateDrive,
                    child: const Text('Sürüşü İlerlet'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _controller.addKm(10, 2.9),
                    child: const Text('+10 Km Ekle'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
