import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class EmptyHabitWidget extends StatelessWidget {
  final VoidCallback onAddPressed;

  const EmptyHabitWidget({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 20),
            _buildText(context),
            const SizedBox(height: 24),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.calendar_today_rounded,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Text(
      AppStrings.habitEmptyState,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: AppColors.textSecondary(context),
        height: 1.5,
      ),
    );
  }

  Widget _buildButton() {
    return ElevatedButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add, size: 20),
      label: Text(AppStrings.addHabit),
    );
  }
}
