import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/extensions/context_extensions.dart';

class AuthErrorBannerWidget extends StatelessWidget {
  const AuthErrorBannerWidget({super.key, required this.error});

  final AuthError error;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      AuthError.invalidCredentials => context.l10n.errorInvalidCredentials,
      AuthError.wrongCurrentPassword => context.l10n.errorWrongCurrentPassword,
      AuthError.recoveryMismatch => context.l10n.errorRecoveryMismatch,
      AuthError.tooManyAttempts => context.l10n.errorTooManyAttempts(AuthController.recoveryLockout.inSeconds),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spaceM),
        decoration: BoxDecoration(
          color: context.colors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: context.colors.error),
            const SizedBox(width: AppSizes.spaceS),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
