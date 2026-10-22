import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HabitStatsBannerWidget extends StatelessWidget {
  final int total;
  final int completed;
  final int points;

  const HabitStatsBannerWidget({
    super.key,
    required this.total,
    required this.completed,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (completed / total * 100).round() : 0;
    final isDark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
            AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, AppStrings.targetLabel, '$completed / $total', Icons.check_circle_outline),
          _buildDivider(context),
          _buildStatItem(context, AppStrings.successRateLabel, '%$percent', Icons.trending_up_rounded),
          _buildDivider(context),
          _buildStatItem(context, AppStrings.pointsLabel, '$points', Icons.bolt_rounded, isPoints: true),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.isDark(context)
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.lightCardBorder,
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isPoints = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPoints ? AppColors.pointsGold : AppColors.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isPoints ? AppColors.pointsGold : AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
