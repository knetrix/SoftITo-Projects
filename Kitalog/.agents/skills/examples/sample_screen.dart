// Kitalog – Örnek Feature Ekranı (Yıllık Okuma Hedefi)
//
// Bu dosya ajan için referans örnektir; gerçek projede model, controller, view ve
// widget'lar ayrı dosyalara bölünür (bkz. SKILL.md Adım 1):
//   lib/features/reading_goal/models/reading_goal_model.dart
//   lib/features/reading_goal/controllers/reading_goal_controller.dart
//   lib/features/reading_goal/views/reading_goal_view.dart
//   lib/features/reading_goal/widgets/goal_progress_card_widget.dart
//   lib/features/reading_goal/widgets/goal_target_stepper_widget.dart
//
// Kullanılan ARB anahtarları (app_tr.arb / app_en.arb):
//   readingGoalTitle, goalProgress(finished, target), goalRemaining(count), goalTarget(target)

import 'package:flutter/material.dart';

import 'package:kitalog/core/extensions/context_extensions.dart';

/// Örnek Feature Model: İmmutable Yıllık Okuma Hedefi State'i
@immutable
class ReadingGoalModel {
  final int year;
  final int targetBookCount;
  final int finishedBookCount;

  const ReadingGoalModel({
    required this.year,
    required this.targetBookCount,
    required this.finishedBookCount,
  });

  /// Hesaplanan değerler saklanmaz, getter olarak türetilir.
  double get progress => targetBookCount > 0
      ? (finishedBookCount / targetBookCount).clamp(0.0, 1.0)
      : 0.0;

  int get remaining =>
      (targetBookCount - finishedBookCount).clamp(0, targetBookCount);

  ReadingGoalModel copyWith({
    int? year,
    int? targetBookCount,
    int? finishedBookCount,
  }) {
    return ReadingGoalModel(
      year: year ?? this.year,
      targetBookCount: targetBookCount ?? this.targetBookCount,
      finishedBookCount: finishedBookCount ?? this.finishedBookCount,
    );
  }

  factory ReadingGoalModel.fromJson(Map<String, dynamic> json) {
    return ReadingGoalModel(
      year: json['year'] as int? ?? DateTime.now().year,
      targetBookCount: json['targetBookCount'] as int? ?? 12,
      // Biten kitap sayısı saklanmaz; BookModel.finishedAt üzerinden hesaplanır.
      finishedBookCount: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'year': year, 'targetBookCount': targetBookCount};
  }
}

/// Örnek Feature Controller: ValueNotifier tabanlı hafif durum yöneticisi.
/// Gerçek projede GoalRepository constructor ile alınır ve her değişiklik kalıcı kaydedilir.
class ReadingGoalController {
  static const int minTarget = 1;
  static const int maxTarget = 365;

  final ValueNotifier<ReadingGoalModel> state;

  ReadingGoalController({required int finishedBookCount})
      : state = ValueNotifier<ReadingGoalModel>(
          ReadingGoalModel(
            year: DateTime.now().year,
            targetBookCount: 24,
            finishedBookCount: finishedBookCount,
          ),
        );

  void changeTarget(int delta) {
    final next =
        (state.value.targetBookCount + delta).clamp(minTarget, maxTarget);
    state.value = state.value.copyWith(targetBookCount: next);
  }

  void dispose() {
    state.dispose();
  }
}

/// Örnek Feature View: Ağır setState yerine ValueListenableBuilder ile reaktif görünüm.
/// StatefulWidget sadece controller yaşam döngüsü için kullanılır.
class ReadingGoalSampleScreen extends StatefulWidget {
  const ReadingGoalSampleScreen({super.key});

  @override
  State<ReadingGoalSampleScreen> createState() =>
      _ReadingGoalSampleScreenState();
}

class _ReadingGoalSampleScreenState extends State<ReadingGoalSampleScreen> {
  late final ReadingGoalController _controller;

  @override
  void initState() {
    super.initState();
    // Gerçek projede değer AppScope.of(context).libraryController'dan hesaplanır.
    _controller = ReadingGoalController(finishedBookCount: 9);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.readingGoalTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ValueListenableBuilder<ReadingGoalModel>(
            valueListenable: _controller.state,
            builder: (context, goal, _) {
              return Column(
                children: [
                  GoalProgressCardWidget(
                    finished: goal.finishedBookCount,
                    target: goal.targetBookCount,
                    remaining: goal.remaining,
                    progress: goal.progress,
                  ),
                  const SizedBox(height: 24),
                  GoalTargetStepperWidget(
                    target: goal.targetBookCount,
                    onIncrement: () => _controller.changeTarget(1),
                    onDecrement: () => _controller.changeTarget(-1),
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

/// Modüler Alt Widget 1: Hedef İlerleme Kartı (build 40 satırı geçmez, const destekler).
/// Renk ve stiller temadan gelir; metinler ARB'den okunur.
class GoalProgressCardWidget extends StatelessWidget {
  final int finished;
  final int target;
  final int remaining;
  final double progress;

  const GoalProgressCardWidget({
    super.key,
    required this.finished,
    required this.target,
    required this.remaining,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              context.l10n.goalProgress(finished, target),
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress, minHeight: 12),
            const SizedBox(height: 12),
            Text(
              context.l10n.goalRemaining(remaining),
              style: context.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Modüler Alt Widget 2: Hedef Kitap Sayısı Ayarlayıcı
class GoalTargetStepperWidget extends StatelessWidget {
  final int target;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const GoalTargetStepperWidget({
    super.key,
    required this.target,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 16),
        Text(
          context.l10n.goalTarget(target),
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(width: 16),
        IconButton.filled(
          onPressed: onIncrement,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
