import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'leaderboard_widget.dart';

class TournamentCardWidget extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback onToggleJoin;

  const TournamentCardWidget({
    super.key,
    required this.tournament,
    required this.onToggleJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 10),
            Text(
              tournament.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 14),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events_rounded, color: AppColors.pointsGold, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tournament.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 14, color: AppColors.textMuted(context)),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.participantCount} ${AppStrings.participants}',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.stars_rounded, size: 14, color: AppColors.pointsGold),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.rewardPoints} ${AppStrings.pointsLabel}',
                    style: const TextStyle(fontSize: 12, color: AppColors.pointsGold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => _showLeaderboard(context),
          icon: const Icon(Icons.format_list_numbered_rounded, size: 16),
          label: Text(AppStrings.leaderboard, style: const TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onToggleJoin,
          style: ElevatedButton.styleFrom(
            backgroundColor: tournament.isJoined ? AppColors.accent : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(tournament.isJoined ? AppStrings.joined : AppStrings.joinTournament),
        ),
      ],
    );
  }

  void _showLeaderboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => LeaderboardWidget(tournament: tournament),
    );
  }
}
