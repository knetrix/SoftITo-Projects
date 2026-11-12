import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Toast (§2.9): koyu kutu, 52 min, köşe 16, 6/20 iç boşluk, varsa "Geri al";
/// 6 sn görünür. Alt menülü ekranlarda alttan 112, diğerlerinde 28.
class AppToast {
  AppToast._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static OverlayEntry? _entry;
  static Timer? _timer;

  /// Alt menü görünüyor mu (router ayarlar)? Görünürken toast yukarıda durur.
  static bool Function() tabBarVisible = () => false;

  static void show(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    BuildContext? context,
  }) {
    final overlay = navigatorKey.currentState?.overlay ??
        (context != null ? Overlay.maybeOf(context, rootOverlay: true) : null);
    if (overlay == null) return;
    hide();
    _entry = OverlayEntry(
      builder: (ctx) => _ToastView(
        message: message,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                hide();
                onAction();
              },
        bottom: tabBarVisible() ? 112 : 28,
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(const Duration(seconds: 6), hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    required this.message,
    required this.bottom,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double bottom;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final reduce = mq.disableAnimations;
    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottom + (mq.viewInsets.bottom > 0 ? mq.viewInsets.bottom - 20 : 0),
      child: Center(
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedSlide(
            offset: _shown || reduce ? Offset.zero : const Offset(0, .15),
            duration: const Duration(milliseconds: 160),
            curve: const Cubic(.2, .8, .2, 1),
            child: Semantics(
              liveRegion: true,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 52,
                    maxWidth: mq.size.width * .92,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.toastBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTextStyles.body(400, color: AppColors.white),
                        ),
                      ),
                      if (widget.actionLabel != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onAction,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 44),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: Text(
                              widget.actionLabel!,
                              style: AppTextStyles.body(700,
                                  color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
