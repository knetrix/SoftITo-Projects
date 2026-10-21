import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_sizes.dart';

/// Yerel açılış ekranıyla aynı logo (`assets/icon/splash_logo.png`).
class SplashLogoWidget extends StatelessWidget {
  const SplashLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.splashLogo,
      width: AppSizes.splashLogo * 2,
      height: AppSizes.splashLogo * 2,
      excludeFromSemantics: true,
    );
  }
}
