import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class WeeklyBarChartWidget extends StatelessWidget {
  final List<double> weeklyRates;

  const WeeklyBarChartWidget({
    super.key,
    required this.weeklyRates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(context),
          const SizedBox(height: 20),
          _buildChartBars(context),
        ],
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.weeklyOverview,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          AppStrings.last7Days,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartBars(BuildContext context) {
    final labels = AppStrings.dayLabels;
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final rate = (index < weeklyRates.length) ? weeklyRates[index] : 0.0;
          final label = labels[index % labels.length];
          return _buildBarColumn(context, label, rate);
        }),
      ),
    );
  }

  Widget _buildBarColumn(BuildContext context, String day, double rate) {
    final barHeight = (rate * 85).clamp(8.0, 85.0);
    final isFull = rate >= 0.99;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${(rate * 100).round()}%',
          style: TextStyle(fontSize: 10, color: AppColors.textMuted(context), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          width: 18,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFull
                  ? [AppColors.accent, AppColors.secondary]
                  : [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
