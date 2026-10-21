import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_theme.dart';

/// Giriş / Kayıt kartının ortalanmış başlığı: ikon rozeti ile "Kitalog" yazısı,
/// slogan, ince süs çizgisi ve sayfa başlığı ("Giriş Yap" / "Kayıt Ol").
class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const _Wordmark(),
          const SizedBox(height: AppSizes.spaceS),
          Text(
            context.l10n.authTagline,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSizes.spaceM),
          const _Ornament(),
          const SizedBox(height: AppSizes.spaceM),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.brandTitle,
          ),
        ],
      ),
    );
  }
}

/// İkon rozeti ve kehribar geçişli "Kitalog" yazısı.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      header: true,
      label: context.l10n.appName,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.spaceM,
          children: [
            const _IconBadge(),
            Flexible(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    colors.primary,
                    colors.onPrimaryContainer,
                    colors.primary,
                  ],
                ).createShader(bounds),
                child: Text(
                  context.l10n.appName,
                  style: context.textTheme.brandWordmark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Işıklı, yuvarlak rozet içinde uygulama ikonu.
class _IconBadge extends StatelessWidget {
  const _IconBadge();

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(AppSizes.spaceS),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: 0.14),
        border: Border.all(color: primary.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: AppSizes.spaceL,
          ),
        ],
      ),
      child: Icon(
        Icons.auto_stories_rounded,
        size: AppSizes.iconM,
        color: primary,
      ),
    );
  }
}

/// Başlığı formdan ayıran ince çizgi ve ortadaki küçük baklava.
class _Ornament extends StatelessWidget {
  const _Ornament();

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: AppSizes.spaceXxl,
      height: 1,
      color: context.colors.primary.withValues(alpha: 0.5),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSizes.spaceS,
      children: [
        line,
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 6,
            height: 6,
            color: context.colors.primary.withValues(alpha: 0.8),
          ),
        ),
        line,
      ],
    );
  }
}
