import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../controllers/challenge_controller.dart';
import '../models/challenge_model.dart';
import '../widgets/challenge_header_card.dart';
import '../widgets/challenge_task_tile.dart';

class ChallengeView extends StatefulWidget {
  final LocalStorageService storage;
  final ChallengeController? controller;

  const ChallengeView({
    super.key,
    required this.storage,
    this.controller,
  });

  @override
  State<ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends State<ChallengeView> {
  late final ChallengeController _controller;
  late final bool _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _internalController = false;
    } else {
      _controller = ChallengeController(widget.storage);
      _internalController = true;
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showCompletionDialog() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.challengeCompletedTitle),
        content: Text(l10n.challengeCompletedMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _controller.restartChallenge();
            },
            child: Text(l10n.challengeRestartButton),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCompleteToday() async {
    final success = await _controller.completeToday(DateTime.now());
    if (success && mounted) {
      if (_controller.state.value?.isCompleted == true) {
        _showCompletionDialog();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.challengeTitle),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<ChallengeModel?>(
          valueListenable: _controller.state,
          builder: (context, challenge, _) {
            if (challenge == null) {
              return EmptyStateWidget(
                icon: Icons.emoji_events_outlined,
                message: l10n.challengeStartPrompt,
                actionLabel: l10n.challengeStartButton,
                onAction: () => _controller.startChallenge(),
              );
            }

            final currentDay = _controller.todayDayNumber(now);

            return ListView(
              padding: const EdgeInsets.all(AppSizes.p16),
              children: [
                ChallengeHeaderCard(
                  challenge: challenge,
                  currentDay: currentDay,
                ),
                if (challenge.isCompleted) ...[
                  const SizedBox(height: AppSizes.spaceMd),
                  Card(
                    color: AppColors.success.withValues(alpha: 0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p16),
                      child: Column(
                        children: [
                          Text(
                            l10n.challengeCompletedTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSizes.spaceSm),
                          Text(
                            l10n.challengeCompletedMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSizes.spaceMd),
                          AppPrimaryButton(
                            label: l10n.challengeRestartButton,
                            onPressed: () => _controller.restartChallenge(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.spaceMd),
                for (final task in challenge.tasks)
                  ChallengeTaskTile(
                    task: task,
                    status: _controller.getTaskStatus(task, now),
                    onComplete: _handleCompleteToday,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
