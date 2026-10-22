import 'package:flutter/material.dart';
import '../controllers/community_controller.dart';
import '../../../core/constants/app_colors.dart';

class CommunityFeedItemWidget extends StatelessWidget {
  final CommunityFeedItem item;

  const CommunityFeedItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 12),
          _buildBody(context),
          _buildStreakBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
      child: Text(
        item.author.substring(0, 1),
        style: TextStyle(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary(context)),
              children: [
                TextSpan(text: item.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: ' '),
                TextSpan(
                  text: item.action,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                item.habit,
                style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${item.timeAgo}',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.streakFire.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 14, color: AppColors.streakFire),
          const SizedBox(width: 2),
          Text(
            '${item.streak}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.streakFire),
          ),
        ],
      ),
    );
  }
}
