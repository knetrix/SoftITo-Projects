import 'package:flutter/material.dart';
import '../controllers/habits_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class HabitFilterChipsWidget extends StatelessWidget {
  final HabitFilter currentFilter;
  final ValueChanged<HabitFilter> onFilterSelected;

  const HabitFilterChipsWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, HabitFilter.today, AppStrings.filterToday),
          const SizedBox(width: 8),
          _buildChip(context, HabitFilter.all, AppStrings.filterAll),
          const SizedBox(width: 8),
          _buildChip(context, HabitFilter.completed, AppStrings.filterCompleted),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, HabitFilter filter, String label) {
    final isSelected = currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.chipUnselectedBg(context),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary(context),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.cardBorder(context),
      ),
    );
  }
}
