import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/context_extensions.dart';
import 'auth_background_widget.dart';
import 'auth_fit_layout.dart';
import 'auth_header_widget.dart';

/// Kayıt ve Giriş ekranlarının ortak iskeleti: animasyonlu arka plan üzerinde,
/// okunabilirlik için yarı saydam kart içinde başlık ve form; yer varsa altında
/// kitap. Kitap hiçbir durumda yarım görünmez; form ne kitabın ne de açık
/// klavyenin üstüne biner ve her zaman kaydırılarak tamamına ulaşılır.
class AuthPageLayoutWidget extends StatelessWidget {
  const AuthPageLayoutWidget({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Klavye ekranı küçültmez; arka plan yerinde kalır. Kart ve altındaki kitap
    // `AuthFitLayout` ile yerleşir: kitap yalnızca tamamına yer varsa çizilir;
    // yoksa (hata mesajları, klavye, küçük ekran, büyük yazı) kart tek başına
    // ortalanır ve sığmazsa sayfa kayar. Odaklanılan alan klavyenin üstünde
    // tutulur.
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AuthBackgroundWidget(
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: EdgeInsets.only(bottom: keyboard),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: AuthFitLayout(
                viewportHeight: constraints.maxHeight - keyboard,
                topInset: media.padding.top,
                card: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceL,
                    vertical: AppSizes.spaceS,
                  ),
                  child: _FormCard(title: title, child: child),
                ),
                book: AuthBookWidget(screen: constraints.biggest),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
      child: Card(
        color: context.colors.surfaceContainer.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceXl,
            AppSizes.spaceL,
            AppSizes.spaceXl,
            AppSizes.spaceS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthHeaderWidget(title: title),
              const SizedBox(height: AppSizes.spaceL),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
