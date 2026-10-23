import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../auth/models/avatar_model.dart';
import '../../auth/models/user_model.dart';

class UserAvatarWidget extends StatelessWidget {
  final UserModel? user;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const UserAvatarWidget({
    super.key,
    required this.user,
    this.radius = AppSizes.avatarSm,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = user?.avatar;
    final email = user?.email ?? '';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

    Widget avatarContent;

    if (avatar != null && avatar.type == AvatarType.preset) {
      avatarContent = CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(avatar.value),
        backgroundColor: AppColors.darkSurface,
      );
    } else if (avatar != null && avatar.type == AvatarType.file && !kIsWeb) {
      final file = File(avatar.value);
      if (file.existsSync()) {
        avatarContent = CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: AppColors.darkSurface,
        );
      } else {
        avatarContent = _buildInitialFallback(context, initial);
      }
    } else {
      avatarContent = _buildInitialFallback(context, initial);
    }

    if (!showEditBadge && onTap == null) {
      return avatarContent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          if (showEditBadge)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.p4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialFallback(BuildContext context, String initial) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}
