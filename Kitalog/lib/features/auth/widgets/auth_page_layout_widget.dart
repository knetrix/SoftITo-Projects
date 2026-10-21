import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import 'auth_header_widget.dart';

/// Kayıt ve Giriş ekranlarının ortak iskeleti (başlık + kaydırılabilir form alanı).
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spaceXl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxFormWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthHeaderWidget(title: title),
                  const SizedBox(height: AppSizes.spaceXl),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
