import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';

/// Detay ekranındaki bölümler için ortak başlıklı kart.
class SectionCardWidget extends StatelessWidget {
  const SectionCardWidget({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ortalanır; düğme (varsa) sağda durur ve başlığın ortasını kaydırmaz.
            SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: trailing == null
                          ? 0
                          : kMinInteractiveDimension,
                    ),
                    child: Text(
                      title,
                      style: context.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (trailing != null)
                    Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceM),
            child,
          ],
        ),
      ),
    );
  }
}
