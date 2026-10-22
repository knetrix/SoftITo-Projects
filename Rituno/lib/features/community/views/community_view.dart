import 'package:flutter/material.dart';
import '../controllers/community_controller.dart';
import '../models/tournament_model.dart';
import '../widgets/tournament_card_widget.dart';
import '../widgets/community_feed_item_widget.dart';
import '../../../core/constants/app_strings.dart';

class CommunityView extends StatelessWidget {
  final CommunityController communityController;

  const CommunityView({
    super.key,
    required this.communityController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.communityTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(AppStrings.activeTournaments),
              const SizedBox(height: 10),
              _buildTournamentsSection(),
              const SizedBox(height: 24),
              _buildSectionTitle(AppStrings.communityFeed),
              const SizedBox(height: 10),
              _buildFeedSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTournamentsSection() {
    return ValueListenableBuilder<List<TournamentModel>>(
      valueListenable: communityController.tournamentsNotifier,
      builder: (context, tournaments, _) {
        if (tournaments.isEmpty) {
          return Center(child: Text(AppStrings.noTournaments));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tournaments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (ctx, index) {
            final tour = tournaments[index];
            return TournamentCardWidget(
              tournament: tour,
              onToggleJoin: () => communityController.toggleJoinTournament(tour.id),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedSection() {
    final items = communityController.feedItems;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        return CommunityFeedItemWidget(item: items[index]);
      },
    );
  }
}
