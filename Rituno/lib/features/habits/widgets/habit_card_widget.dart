import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HabitCardWidget extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = habit.isCompletedToday;
    final isDark = AppColors.isDark(context);

    final cardBg = isDone
        ? (isDark ? AppColors.darkCard.withValues(alpha: 0.5) : const Color(0xFFF1F5F9))
        : (isDark ? AppColors.darkCard : Colors.white);

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) async => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: Card(
        color: cardBg,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildLeadingStreak(context),
                const SizedBox(width: 14),
                _buildTitleAndCategory(context, theme, isDone),
                _buildActionButtons(context, isDone),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: AppColors.error),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteHabitConfirm),
        content: Text(AppStrings.deleteHabitMessage(habit.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingStreak(BuildContext context) {
    final hasStreak = habit.streakCount > 0;
    final muted = AppColors.textMuted(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: hasStreak
            ? AppColors.streakFire.withValues(alpha: 0.15)
            : AppColors.chipUnselectedBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasStreak
              ? AppColors.streakFire.withValues(alpha: 0.4)
              : AppColors.cardBorder(context),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: hasStreak ? AppColors.streakFire : muted,
          ),
          Text(
            '${habit.streakCount}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: hasStreak ? AppColors.streakFire : muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndCategory(BuildContext context, ThemeData theme, bool isDone) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone ? AppColors.textMuted(context) : AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                habit.category,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
              ),
              if (habit.reminderTime != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.alarm, size: 12, color: AppColors.textMuted(context)),
                const SizedBox(width: 2),
                Text(
                  habit.reminderTime!,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDone) {
    return IconButton(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? AppColors.accent : Colors.transparent,
          border: Border.all(
            color: isDone ? AppColors.accent : AppColors.cardBorder(context),
            width: 2,
          ),
        ),
        child: isDone ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
      ),
      onPressed: onToggle,
    );
  }
}
