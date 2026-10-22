import 'package:flutter/material.dart';

import '../../../core/controllers/notification_controller.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/notification_target_model.dart';
import '../../../core/routing/app_routes.dart';
import '../controllers/home_shell_controller.dart';
import '../models/home_shell_model.dart';
import '../widgets/home_navigation_bar_widget.dart';

/// NavigationBar + sağ üst Ayarlar butonu. Oturum açıkken uygulamanın kökü
/// olduğu için dokunulan bildirimin hedefini burada açar. Sekme sayfaları rota katmanından
/// (`AppRoutes`) verilir; böylece feature'lar birbirinin view'ını import etmez.
class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key, required this.pages, this.initialIndex = 0});

  final List<Widget> pages;
  final int initialIndex;

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  late final HomeShellController _controller = HomeShellController(
    tabCount: widget.pages.length,
    initialIndex: widget.initialIndex,
  );

  /// Okuma Durumu sekmesinin sırası (okunan kitap yokken günlük hatırlatma buraya açılır).
  static const int _readingStatusTab = 1;

  NotificationController? _notifications;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_notifications != null) return;
    _notifications = AppScope.of(context).notificationController..pendingTarget.addListener(_openPendingTarget);
    // Uygulama bildirime dokunularak açıldıysa istek ana kabuk kurulmadan gelmiştir.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingTarget());
  }

  /// Dokunulan bildirimin hedefini açar: iade hatırlatmasında Kitap Detay, okuma
  /// hatırlatmasında dijital sürümü varsa Okuyucu (geri gelince Kitap Detay), yoksa
  /// Kitap Detay; okunan kitap yoksa Okuma Durumu sekmesi. Kitap silindiyse yok sayılır.
  void _openPendingTarget() {
    final notifications = _notifications;
    if (!mounted || notifications == null || notifications.pendingTarget.value == null) return;
    final target = notifications.takePendingTarget()!;
    final navigator = Navigator.of(context);
    if (target.kind == NotificationTargetKind.readingStatus) {
      final shell = ModalRoute.of(context);
      navigator.popUntil((route) => route == shell);
      _controller.selectTab(_readingStatusTab);
      return;
    }
    final book = AppScope.of(context).libraryController.bookById(target.bookId!);
    if (book == null) return;
    navigator.pushNamed(AppRoutes.bookDetail, arguments: book.id);
    if (target.kind == NotificationTargetKind.read && book.hasDigitalEdition) {
      navigator.pushNamed(AppRoutes.reader, arguments: book.id);
    }
  }

  @override
  void dispose() {
    _notifications?.pendingTarget.removeListener(_openPendingTarget);
    _controller.dispose();
    super.dispose();
  }

  String _title(BuildContext context, int index) {
    final l10n = context.l10n;
    return switch (index) {
      0 => l10n.libraryTitle,
      1 => l10n.readingStatusTitle,
      2 => l10n.loansTitle,
      _ => l10n.readingGoalTitle,
    };
  }

  /// Ödünç sekmesinin rozetinde gösterilen, iade günü geçmiş ödünç sayısı.
  static int _overdueCount(List<BookModel> books) {
    final now = DateTime.now();
    return books.where((b) => b.isLent && b.loan!.isOverdue(now)).length;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeShellModel>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_title(context, state.selectedIndex)),
            actions: [
              IconButton(
                tooltip: context.l10n.settingsTitle,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.settings),
              ),
            ],
          ),
          body: IndexedStack(
            index: state.selectedIndex,
            children: widget.pages,
          ),
          bottomNavigationBar: ValueListenableBuilder<List<BookModel>>(
            valueListenable: AppScope.of(context).libraryController.books,
            builder: (context, books, _) => HomeNavigationBarWidget(
              selectedIndex: state.selectedIndex,
              onSelected: _controller.selectTab,
              overdueLoanCount: _overdueCount(books),
            ),
          ),
        );
      },
    );
  }
}
