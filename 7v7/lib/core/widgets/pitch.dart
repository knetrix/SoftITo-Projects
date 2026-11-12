import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../utils/formation.dart';
import 'bib.dart';
import 'pitch_painter.dart';
import 'pressable.dart';

enum SlotState { filled, empty, waiting, offer }

/// Sahadaki bir mevkinin görünümü.
class PitchSlot {
  const PitchSlot({
    required this.slot,
    required this.number,
    required this.state,
    required this.label,
    this.semanticLabel,
  });

  final Slot slot;
  final int number;
  final SlotState state;

  /// Dolu: oyuncunun adı; boş: mevki adı; bekliyor: "{ad} bekliyor";
  /// teklif: "Senin yerin".
  final String label;
  final String? semanticLabel;
}

/// Saha bileşeni (§2.8). [onTap] verilirse mevkiler düğmedir.
class PitchView extends StatelessWidget {
  const PitchView({
    super.key,
    required this.formationId,
    required this.slots,
    this.height = 340,
    this.onTap,
    this.overlay,
    this.semanticLabel,
  });

  final String? formationId;
  final List<PitchSlot> slots;
  final double height;
  final ValueChanged<String>? onTap;

  /// Diziliş yokken saha içindeki içerik (`pitch-empty`).
  final Widget? overlay;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: height,
          child: LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth, h = box.maxHeight;
            return Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(painter: PitchPainter(pitch: c.pitch)),
                  ),
                ),
                if (formationId != null)
                  for (final s in slots)
                    _positioned(s, w, h),
                if (overlay != null) Positioned.fill(child: overlay!),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _positioned(PitchSlot s, double w, double h) {
    final xy = slotXY(formationId!, s.slot);
    final cx = w * xy.x / 100, cy = h * xy.y / 100;
    const sw = 92.0, sh = 68.0;
    final child = PitchSlotButton(slot: s);
    return Positioned(
      left: cx - sw / 2,
      top: cy - sh / 2,
      width: sw,
      height: sh,
      child: onTap == null
          ? Semantics(label: s.semanticLabel, child: ExcludeSemantics(child: child))
          : Pressable(
              scale: .95,
              semanticLabel: s.semanticLabel,
              onTap: () => onTap!(s.slot.id),
              child: ExcludeSemantics(child: child),
            ),
    );
  }
}

/// Mevki düğmesi: üstte yelek 40×44, altta isim etiketi (12/700, 2×8, köşe 10).
class PitchSlotButton extends StatelessWidget {
  const PitchSlotButton({super.key, required this.slot});
  final PitchSlot slot;

  @override
  Widget build(BuildContext context) {
    final gk = slot.slot.line == Line.gk;
    final kind = switch (slot.state) {
      SlotState.filled => gk ? BibKind.gk : BibKind.onPitch,
      SlotState.offer => BibKind.offer,
      _ => BibKind.empty,
    };
    final (Color bg, Color fg, bool ring) = switch (slot.state) {
      SlotState.filled => (AppColors.white, AppColors.kitInk, false),
      SlotState.offer => (AppColors.white, AppColors.kitGreen, true),
      _ => (AppColors.slotLabelOff, AppColors.white, false),
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Bib(kind: kind, number: '${slot.number}'),
        const SizedBox(height: 2),
        Container(
          constraints: const BoxConstraints(maxWidth: 92),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: ring
                ? const [BoxShadow(color: AppColors.kitInk, spreadRadius: 2)]
                : null,
          ),
          child: Text(
            slot.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: AppTextStyles.s(12, 700, color: fg),
          ),
        ),
      ],
    );
  }
}
