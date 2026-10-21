import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../controllers/splash_controller.dart';
import '../models/splash_model.dart';
import '../widgets/splash_logo_widget.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key, this.minDuration});

  /// Testlerde bekleme süresini kısaltmak için.
  final Duration? minDuration;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  SplashController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final scope = AppScope.of(context);
    _controller = SplashController(
      auth: scope.authController,
      library: scope.libraryController,
      minDuration: widget.minDuration ?? const Duration(milliseconds: 700),
    )..state.addListener(_onStateChanged);
    _controller!.start();
  }

  void _onStateChanged() {
    final destination = _controller!.state.value.destination;
    if (destination != null && mounted) {
      Navigator.of(context).pushReplacementNamed(destination);
    }
  }

  @override
  void dispose() {
    _controller?.state.removeListener(_onStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Yerel açılış ekranıyla aynı zemin (koyu mürekkep) kullanılır.
      backgroundColor: AppColors.inkBlack,
      body: Center(
        child: ValueListenableBuilder<SplashModel>(
          valueListenable: _controller!.state,
          builder: (context, state, _) {
            if (!state.isFailure) return const SplashLogoWidget();
            return EmptyStateView(
              icon: Icons.error_outline,
              title: context.l10n.splashError,
              action: FilledButton(
                onPressed: _controller!.start,
                child: Text(context.l10n.commonRetry),
              ),
            );
          },
        ),
      ),
    );
  }
}
