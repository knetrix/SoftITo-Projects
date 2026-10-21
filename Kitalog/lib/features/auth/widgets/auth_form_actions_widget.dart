import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';

/// Kayıt/Giriş formlarının alt kısmı: ana buton + diğer ekrana geçiş bağlantısı.
class AuthFormActionsWidget extends StatelessWidget {
  const AuthFormActionsWidget({
    super.key,
    required this.isLoading,
    required this.submitLabel,
    required this.linkLabel,
    required this.onSubmit,
    required this.onLinkTap,
  });

  final bool isLoading;
  final String submitLabel;
  final String linkLabel;
  final VoidCallback onSubmit;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSizes.spaceM),
        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          child: Text(submitLabel),
        ),
        const SizedBox(height: AppSizes.spaceS),
        TextButton(
          onPressed: isLoading ? null : onLinkTap,
          child: Text(linkLabel),
        ),
      ],
    );
  }
}
