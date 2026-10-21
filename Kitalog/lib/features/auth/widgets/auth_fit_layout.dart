import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Form kartını ve altındaki süs kitabını yerleştirir. Kitap yalnızca kartın
/// altında tamamına yer varsa çizilir; yoksa (hata mesajları, klavye, küçük
/// ekran, büyük yazı) hiç çizilmez ve kart tek başına ortalanır. Böylece kitap
/// hiçbir durumda yarım görünmez ya da kartın üstüne binmez. Karar her
/// yerleşimde tek adımda verilir (ölçüp yeniden çizme, titreme yok).
///
/// Kaydırılabilir alanın içinde kullanılır: içerik ekrana sığmazsa yüksekliği
/// kart kadar olur ve sayfa kayar.
class AuthFitLayout extends MultiChildRenderObjectWidget {
  AuthFitLayout({
    super.key,
    required this.viewportHeight,
    required this.topInset,
    required Widget card,
    required Widget book,
  }) : super(children: [card, book]);

  /// Görünür alanın yüksekliği (klavye açıksa klavyenin üstü).
  final double viewportHeight;

  /// Üstteki sistem çubuğu boşluğu; kart bunun altında kalır.
  final double topInset;

  @override
  RenderAuthFitLayout createRenderObject(BuildContext context) =>
      RenderAuthFitLayout(viewportHeight: viewportHeight, topInset: topInset);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderAuthFitLayout renderObject,
  ) {
    renderObject
      ..viewportHeight = viewportHeight
      ..topInset = topInset;
  }
}

class _FitParentData extends ContainerBoxParentData<RenderBox> {}

class RenderAuthFitLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FitParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FitParentData> {
  RenderAuthFitLayout({required this._viewportHeight, required this._topInset});

  double _viewportHeight;
  set viewportHeight(double value) {
    if (value == _viewportHeight) return;
    _viewportHeight = value;
    markNeedsLayout();
  }

  double _topInset;
  set topInset(double value) {
    if (value == _topInset) return;
    _topInset = value;
    markNeedsLayout();
  }

  /// Son yerleşimde kitap çizildi mi (testler ve hata ayıklama için).
  bool get showsBook => _showBook;
  bool _showBook = false;

  RenderBox get _card => firstChild!;
  RenderBox get _book => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FitParentData) {
      child.parentData = _FitParentData();
    }
  }

  /// Kitap sığıyor mu ve toplam yükseklik (yerleşim ve kuru ölçüm ortak).
  (bool, double) _resolve(double cardHeight, double bookHeight) {
    final showBook = cardHeight + bookHeight <= _viewportHeight - _topInset;
    final content = showBook ? _viewportHeight : _topInset + cardHeight;
    return (showBook, content < _viewportHeight ? _viewportHeight : content);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final card = _card.getDryLayout(BoxConstraints(maxWidth: width));
    final book = _book.getDryLayout(BoxConstraints.tightFor(width: width));
    return constraints.constrain(
      Size(width, _resolve(card.height, book.height).$2),
    );
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    _card.layout(BoxConstraints(maxWidth: width), parentUsesSize: true);
    _book.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
    final cardHeight = _card.size.height;
    final bookHeight = _book.size.height;
    final (showBook, height) = _resolve(cardHeight, bookHeight);
    _showBook = showBook;
    size = constraints.constrain(Size(width, height));
    // Kart, kitabın (çizilmiyorsa ekranın) üstünde kalan alanda ortalanır.
    final space = size.height - _topInset - (_showBook ? bookHeight : 0);
    final cardTop =
        _topInset + ((space - cardHeight) / 2).clamp(0.0, double.infinity);
    (_card.parentData! as _FitParentData).offset = Offset(
      (width - _card.size.width) / 2,
      cardTop,
    );
    (_book.parentData! as _FitParentData).offset = Offset(
      0,
      size.height - bookHeight,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_showBook) {
      context.paintChild(
        _book,
        (_book.parentData! as _FitParentData).offset + offset,
      );
    }
    context.paintChild(
      _card,
      (_card.parentData! as _FitParentData).offset + offset,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final data = _card.parentData! as _FitParentData;
    return result.addWithPaintOffset(
      offset: data.offset,
      position: position,
      hitTest: (result, transformed) =>
          _card.hitTest(result, position: transformed),
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) => visitor(_card);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _card.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _card.getMaxIntrinsicWidth(height);
}
