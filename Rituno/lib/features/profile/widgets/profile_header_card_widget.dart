import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class ProfileHeaderCardWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditPressed;

  const ProfileHeaderCardWidget({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildCardDecoration(context),
      child: Column(
        children: [
          _buildAvatarAndRank(context),
          const SizedBox(height: 14),
          _buildUserInfo(context),
          const SizedBox(height: 14),
          _buildEditButton(context),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return BoxDecoration(
      color: isDark ? AppColors.darkCard : Colors.white,
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
          isDark ? AppColors.darkCard : Colors.white,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.lightCardBorder,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarAndRank(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.pointsGold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${user.totalPoints} P',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onEditPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.isDark(context) ? Colors.white : AppColors.primary,
        side: BorderSide(
          color: AppColors.isDark(context)
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: Text(AppStrings.editProfile, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
