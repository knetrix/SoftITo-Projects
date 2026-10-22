import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class StatsSummaryCardsWidget extends StatelessWidget {
  final int totalHabits;
  final int highestStreak;
  final int totalCompletions;
  final int totalPoints;

  const StatsSummaryCardsWidget({
    super.key,
    required this.totalHabits,
    required this.highestStreak,
    required this.totalCompletions,
    required this.totalPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            context,
            AppStrings.highestStreak,
            '$highestStreak ${AppStrings.dayUnit}',
            Icons.local_fire_department,
            AppColors.streakFire,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCard(
            context,
            AppStrings.totalCheckmarks,
            '$totalCompletions',
            Icons.check_circle_rounded,
            AppColors.accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildCard(
            context,
            AppStrings.pointsLabel,
            '$totalPoints',
            Icons.military_tech_rounded,
            AppColors.pointsGold,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }
}
