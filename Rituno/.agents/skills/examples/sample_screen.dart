import 'package:flutter/material.dart';

/// Örnek Feature Model: Rutino İmmutable Alışkanlık Modeli
@immutable
class HabitItemModel {
  final String id;
  final String title;
  final int streakCount;
  final bool isCompletedToday;

  const HabitItemModel({
    required this.id,
    required this.title,
    this.streakCount = 0,
    this.isCompletedToday = false,
  });

  HabitItemModel copyWith({
    String? id,
    String? title,
    int? streakCount,
    bool? isCompletedToday,
  }) {
    return HabitItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      streakCount: streakCount ?? this.streakCount,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
    );
  }

  factory HabitItemModel.fromJson(Map<String, dynamic> json) {
    return HabitItemModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      streakCount: json['streakCount'] as int? ?? 0,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'streakCount': streakCount,
      'isCompletedToday': isCompletedToday,
    };
  }
}

/// Örnek Feature State Modeli
@immutable
class HabitListState {
  final List<HabitItemModel> habits;
  final int totalPoints;
  final bool isLoading;

  const HabitListState({
    this.habits = const [],
    this.totalPoints = 0,
    this.isLoading = false,
  });

  HabitListState copyWith({
    List<HabitItemModel>? habits,
    int? totalPoints,
    bool? isLoading,
  }) {
    return HabitListState(
      habits: habits ?? this.habits,
      totalPoints: totalPoints ?? this.totalPoints,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Örnek Feature Controller: Rutino standartlarında ValueNotifier tabanlı hafif durum yöneticisi
class HabitTrackerController {
  final ValueNotifier<HabitListState> state = ValueNotifier<HabitListState>(
    const HabitListState(
      habits: [
        HabitItemModel(id: '1', title: 'Kitap Oku (20 Sayfa)', streakCount: 5, isCompletedToday: false),
        HabitItemModel(id: '2', title: '2 Litre Su İç', streakCount: 12, isCompletedToday: true),
        HabitItemModel(id: '3', title: 'Günlük Kod Yaz', streakCount: 3, isCompletedToday: false),
      ],
      totalPoints: 240,
    ),
  );

  void toggleHabit(String habitId) {
    int pointsDiff = 0;
    final updatedHabits = state.value.habits.map((habit) {
      if (habit.id == habitId) {
        final willComplete = !habit.isCompletedToday;
        pointsDiff += willComplete ? 10 : -10;
        return habit.copyWith(
          isCompletedToday: willComplete,
          streakCount: willComplete
              ? habit.streakCount + 1
              : (habit.streakCount > 0 ? habit.streakCount - 1 : 0),
        );
      }
      return habit;
    }).toList();

    state.value = state.value.copyWith(
      habits: updatedHabits,
      totalPoints: (state.value.totalPoints + pointsDiff).clamp(0, 999999),
    );
  }

  void addHabit(String title) {
    if (title.trim().isEmpty) return;
    final newHabit = HabitItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    state.value = state.value.copyWith(
      habits: [...state.value.habits, newHabit],
    );
  }

  void dispose() {
    state.dispose();
  }
}

/// Örnek Feature View: Ağır setState yerine ValueListenableBuilder ile reaktif görünüm
class HabitTrackerSampleScreen extends StatefulWidget {
  const HabitTrackerSampleScreen({super.key});

  @override
  State<HabitTrackerSampleScreen> createState() =>
      _HabitTrackerSampleScreenState();
}

class _HabitTrackerSampleScreenState extends State<HabitTrackerSampleScreen> {
  late final HabitTrackerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HabitTrackerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutino - Alışkanlıklar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<HabitListState>(
            valueListenable: _controller.state,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HabitStatsHeaderWidget(
                    totalHabits: state.habits.length,
                    completedCount: state.habits.where((h) => h.isCompletedToday).length,
                    totalPoints: state.totalPoints,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.habits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final habit = state.habits[index];
                        return HabitItemCardWidget(
                          habit: habit,
                          onToggle: () => _controller.toggleHabit(habit.id),
                        );
                      },
                    ),
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

/// Modüler Alt Widget 1: Üst İstatistik ve Puan Kartı (build metodu 40 satırı geçmez)
class HabitStatsHeaderWidget extends StatelessWidget {
  final int totalHabits;
  final int completedCount;
  final int totalPoints;

  const HabitStatsHeaderWidget({
    super.key,
    required this.totalHabits,
    required this.completedCount,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('Tamamlanan', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('$completedCount / $totalHabits', style: theme.textTheme.titleLarge),
              ],
            ),
            Column(
              children: [
                Text('Puan', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text('$totalPoints P', style: theme.textTheme.titleLarge?.copyWith(color: Colors.amberAccent)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Modüler Alt Widget 2: Alışkanlık Satır Kartı (build metodu 40 satırı geçmez)
class HabitItemCardWidget extends StatelessWidget {
  final HabitItemModel habit;
  final VoidCallback onToggle;

  const HabitItemCardWidget({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: habit.isCompletedToday ? 0 : 2,
      child: ListTile(
        leading: Icon(
          Icons.local_fire_department,
          color: habit.streakCount > 0 ? Colors.deepOrangeAccent : Colors.grey,
        ),
        title: Text(
          habit.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${habit.streakCount} Günlük Seri'),
        trailing: IconButton(
          icon: Icon(
            habit.isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habit.isCompletedToday ? Colors.greenAccent : null,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
