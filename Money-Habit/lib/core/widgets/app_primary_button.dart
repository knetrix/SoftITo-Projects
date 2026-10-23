import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isOutlined;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: AppSizes.buttonHeight,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (isOutlined) {
      if (icon != null) {
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
        );
      }
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
