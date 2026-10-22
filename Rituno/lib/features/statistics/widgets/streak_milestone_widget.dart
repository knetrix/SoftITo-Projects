import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class StreakMilestoneWidget extends StatelessWidget {
  final int streak;

  const StreakMilestoneWidget({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.streakBadges,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBadge(context, '3 ${AppStrings.dayUnit}', Icons.looks_3_rounded, streak >= 3),
              _buildBadge(context, '7 ${AppStrings.dayUnit}', Icons.looks_one_rounded, streak >= 7),
              _buildBadge(context, '14 ${AppStrings.dayUnit}', Icons.whatshot_rounded, streak >= 14),
              _buildBadge(context, '30 ${AppStrings.dayUnit}', Icons.workspace_premium_rounded, streak >= 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, IconData icon, bool unlocked) {
    final muted = AppColors.textMuted(context);

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.streakFire.withValues(alpha: 0.15)
                : AppColors.chipUnselectedBg(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? AppColors.streakFire : AppColors.cardBorder(context),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? AppColors.streakFire : muted,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
            color: unlocked ? AppColors.textPrimary(context) : muted,
          ),
        ),
      ],
    );
  }
}
