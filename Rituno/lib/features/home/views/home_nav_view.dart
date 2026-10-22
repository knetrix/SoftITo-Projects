import 'package:flutter/material.dart';
import '../../habits/controllers/habits_controller.dart';
import '../../habits/views/habits_view.dart';
import '../../statistics/controllers/statistics_controller.dart';
import '../../statistics/views/statistics_view.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/views/community_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/views/profile_view.dart';
import '../../auth/models/user_model.dart';
import '../../../core/constants/app_strings.dart';

class HomeNavView extends StatefulWidget {
  final HabitsController habitsController;
  final StatisticsController statsController;
  final CommunityController communityController;
  final ProfileController profileController;
  final VoidCallback onLogout;

  const HomeNavView({
    super.key,
    required this.habitsController,
    required this.statsController,
    required this.communityController,
    required this.profileController,
    required this.onLogout,
  });

  @override
  State<HomeNavView> createState() => _HomeNavViewState();
}

class _HomeNavViewState extends State<HomeNavView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.profileController.languageNotifier,
      builder: (context, lang, _) {
        AppStrings.setLanguage(lang);
        return ValueListenableBuilder<UserModel?>(
          valueListenable: widget.profileController.userNotifier,
          builder: (context, user, _) {
            final userId = user?.id ?? 'guest_user';
            final points = user?.totalPoints ?? 0;

            return Scaffold(
              body: _buildTabViews(userId, points),
              bottomNavigationBar: _buildBottomNav(),
            );
          },
        );
      },
    );
  }

  Widget _buildTabViews(String userId, int points) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        HabitsView(
          habitsController: widget.habitsController,
          totalUserPoints: points,
        ),
        StatisticsView(
          statsController: widget.statsController,
          habitsController: widget.habitsController,
          userId: userId,
          totalPoints: points,
        ),
        CommunityView(
          communityController: widget.communityController,
        ),
        ProfileView(
          profileController: widget.profileController,
          onLogout: widget.onLogout,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.check_circle_outline_rounded),
          activeIcon: const Icon(Icons.check_circle_rounded),
          label: AppStrings.tabHabits,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.insights_outlined),
          activeIcon: const Icon(Icons.insights_rounded),
          label: AppStrings.tabStats,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.groups_outlined),
          activeIcon: const Icon(Icons.groups_rounded),
          label: AppStrings.tabCommunity,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
          label: AppStrings.tabProfile,
        ),
      ],
    );
  }
}
