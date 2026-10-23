// Örnek: Finansal Hedef Detay Ekranı (goals feature)
//
// Gerçek projede bu dosya parçalara ayrılır:
//   lib/features/goals/models/goal_model.dart
//   lib/features/goals/models/goal_step_model.dart
//   lib/features/goals/controllers/goal_detail_controller.dart
//   lib/features/goals/views/goal_detail_view.dart
//   lib/features/goals/widgets/goal_progress_card.dart
//   lib/features/goals/widgets/goal_step_tile.dart
// Burada okunabilirlik için tek dosyada gösterilmiştir. Kalıcılık (LocalStorageService)
// sadeleştirmek için çıkarılmıştır; bkz. references/state_flow.md.

import 'package:flutter/material.dart';

import 'package:money_habit_tracker/core/extensions/context_extensions.dart';
import 'package:money_habit_tracker/core/extensions/money_extensions.dart';

/// Örnek Model 1: Hedefe Para Ekleme Adımı (immutable, kuruş bazlı)
@immutable
class GoalStepModel {
  final String id;
  final int amount; // kuruş
  final DateTime date;
  final String? note;

  const GoalStepModel({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  factory GoalStepModel.fromJson(Map<String, dynamic> json) {
    return GoalStepModel(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'date': date.toIso8601String(), 'note': note};
  }
}

/// Örnek Model 2: Finansal Hedef (türetilmiş değerler getter, JSON'a yazılmaz)
@immutable
class GoalModel {
  final String id;
  final String title;
  final int targetAmount; // kuruş
  final List<GoalStepModel> steps;

  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.steps = const [],
  });

  int get savedAmount => steps.fold(0, (sum, s) => sum + s.amount);

  double get progress =>
      targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isReached => savedAmount >= targetAmount;

  GoalModel copyWith({
    String? id,
    String? title,
    int? targetAmount,
    List<GoalStepModel>? steps,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      steps: steps ?? this.steps,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      targetAmount: json['targetAmount'] as int? ?? 0,
      steps: (json['steps'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(GoalStepModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}

/// Örnek Controller: ValueNotifier tabanlı hafif durum yöneticisi
class GoalDetailController {
  final ValueNotifier<GoalModel> state;

  GoalDetailController(GoalModel goal) : state = ValueNotifier<GoalModel>(goal);

  void addStep(int amount, {String? note}) {
    final step = GoalStepModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      date: DateTime.now(),
      note: note,
    );
    // Yeni liste referansı -> ValueListenableBuilder tetiklenir
    state.value = state.value.copyWith(steps: [step, ...state.value.steps]);
  }

  void dispose() {
    state.dispose();
  }
}

/// Örnek View: Ağır setState yerine ValueListenableBuilder ile reaktif görünüm
class GoalDetailSampleScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailSampleScreen({super.key, required this.goal});

  @override
  State<GoalDetailSampleScreen> createState() => _GoalDetailSampleScreenState();
}

class _GoalDetailSampleScreenState extends State<GoalDetailSampleScreen> {
  late final GoalDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GoalDetailController(widget.goal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GoalModel>(
      valueListenable: _controller.state,
      builder: (context, goal, _) {
        return Scaffold(
          appBar: AppBar(title: Text(goal.title)),
          floatingActionButton: FloatingActionButton.extended(
            // Gerçek projede tutar BottomSheet formundan gelir (toKurus ile)
            onPressed: () => _controller.addStep(5000),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.goalAddMoney),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GoalProgressCard(goal: goal),
              const SizedBox(height: 16),
              for (final step in goal.steps) GoalStepTile(step: step),
            ],
          ),
        );
      },
    );
  }
}

/// Modüler Alt Widget 1: İlerleme Kartı (build 40 satırı geçmez, renkler temadan)
class GoalProgressCard extends StatelessWidget {
  final GoalModel goal;

  const GoalProgressCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final percent = (goal.progress * 100).toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${goal.savedAmount.toCurrency(localeCode)} / '
              '${goal.targetAmount.toCurrency(localeCode)}',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: goal.progress, minHeight: 12),
            const SizedBox(height: 8),
            Text(
              goal.isReached ? context.l10n.goalReached : '%$percent',
              style: context.textStyles.labelLarge?.copyWith(
                color: goal.isReached ? context.colors.tertiary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modüler Alt Widget 2: İlerleme Adımı Satırı
class GoalStepTile extends StatelessWidget {
  final GoalStepModel step;

  const GoalStepTile({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return ListTile(
      leading: Icon(Icons.savings_outlined, color: context.colors.primary),
      title: Text('+${step.amount.toCurrency(localeCode)}'),
      subtitle: step.note == null ? null : Text(step.note!),
    );
  }
}
