import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/extensions/context_extensions.dart';
import '../controllers/add_book_controller.dart';
import '../controllers/cover_picker.dart';
import '../models/add_book_model.dart';
import '../widgets/add_book_body_widget.dart';

class AddBookView extends StatefulWidget {
  const AddBookView({super.key, this.coverPicker});

  /// Testte sahte seçici verilebilir; yoksa galeri / kamera (`image_picker`).
  final CoverPicker? coverPicker;

  @override
  State<AddBookView> createState() => _AddBookViewState();
}

class _AddBookViewState extends State<AddBookView> {
  AddBookController? _controller;
  late final CoverPicker _coverPicker = widget.coverPicker ?? ImagePickerCoverPicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _controller ??= AddBookController(
      library: scope.libraryController,
      search: scope.bookSearchRepository,
    )..state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = _controller!.state.value;
    if (!mounted) return;
    if (state.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.addBookSaved)),
      );
      Navigator.of(context).pop(true);
    } else if (state.error == AddBookError.duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.addBookErrorDuplicate)),
      );
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
    final controller = _controller!;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addBookTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spaceL),
          child: ValueListenableBuilder<AddBookModel>(
            valueListenable: controller.state,
            builder: (context, state, _) => AddBookBodyWidget(
              state: state,
              onModeChanged: controller.setMode,
              onSearch: controller.search,
              onRetry: controller.retry,
              onSelect: controller.selectResult,
              onSave: controller.save,
              coverPicker: _coverPicker,
              customGenres: AppScope.of(context).libraryController.customGenres,
              onCreateGenre: controller.createGenre,
            ),
          ),
        ),
      ),
    );
  }
}
