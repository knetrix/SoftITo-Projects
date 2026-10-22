import 'package:flutter/material.dart';
import '../models/tournament_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class LeaderboardWidget extends StatelessWidget {
  final TournamentModel tournament;

  const LeaderboardWidget({
    super.key,
    required this.tournament,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDragHandle(context),
              const SizedBox(height: 12),
              Text(
                tournament.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.tournamentLeaderboard,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildList(context, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.cardBorder(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ScrollController scrollController) {
    final list = tournament.leaderboard;
    if (list.isEmpty) {
      return Center(
        child: Text(
          AppStrings.noLeaderboardData,
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = list[index];
        final rank = row['rank'] as int? ?? (index + 1);
        final name = row['name'] as String? ?? 'Kullanıcı';
        final streak = row['streak'] as int? ?? 0;
        final points = row['points'] as int? ?? 0;

        return _buildLeaderboardTile(context, rank, name, streak, points);
      },
    );
  }

  Widget _buildLeaderboardTile(BuildContext context, int rank, String name, int streak, int points) {
    Color rankColor = AppColors.textMuted(context);
    if (rank == 1) rankColor = AppColors.pointsGold;
    if (rank == 2) rankColor = const Color(0xFF94A3B8);
    if (rank == 3) rankColor = const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: rankColor.withValues(alpha: 0.2),
            child: Text(
              '$rank',
              style: TextStyle(color: rankColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          Text(
            '$streak ${AppStrings.dayUnit}',
            style: const TextStyle(fontSize: 12, color: AppColors.streakFire, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 14),
          Text(
            '$points P',
            style: const TextStyle(fontSize: 12, color: AppColors.pointsGold, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
