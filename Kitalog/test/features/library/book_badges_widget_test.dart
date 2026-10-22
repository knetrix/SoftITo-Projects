import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/digital_edition_model.dart';
import 'package:kitalog/core/models/digital_source.dart';
import 'package:kitalog/core/models/loan_model.dart';
import 'package:kitalog/features/library/widgets/book_badges_widget.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_dependencies.dart';

const _edition = DigitalEditionModel(source: DigitalSource.gutenberg, sourceId: '84', languageCode: 'en');

BookModel _book({required bool owned, bool digital = false, bool lent = false}) => BookModel(
  id: 'b',
  title: 'Kitap',
  isOwned: owned,
  digitalEdition: digital ? _edition : null,
  loan: lent ? LoanModel(borrowerName: 'Ali', lentAt: DateTime(2026)) : null,
  addedAt: DateTime(2026),
);

Future<List<String>> _labels(WidgetTester tester, BookModel book) async {
  final deps = await createTestDependencies();
  await pumpScreen(tester, deps, Scaffold(body: BookBadgesWidget(book: book)));
  return [for (final t in tester.widgetList<Text>(find.byType(Text))) t.data!];
}

void main() {
  testWidgets('yalnızca fiziksel: "Fiziksel"', (tester) async {
    expect(await _labels(tester, _book(owned: true)), ['Fiziksel']);
  });

  testWidgets('fiziksel + dijital: "Fiziksel" ve "Dijital"', (tester) async {
    expect(await _labels(tester, _book(owned: true, digital: true)), ['Fiziksel', 'Dijital']);
  });

  testWidgets('yalnızca dijital: sadece "Dijital"', (tester) async {
    expect(await _labels(tester, _book(owned: false, digital: true)), ['Dijital']);
  });

  testWidgets('fiziksel kopya ödünçteyse "Fiziksel" yerine "Ödünçte"; dijital korunur', (tester) async {
    expect(await _labels(tester, _book(owned: true, digital: true, lent: true)), ['Ödünçte', 'Dijital']);
  });

  testWidgets('fiziksel kopyası olmayan kitapta eski ödünç kaydı rozet üretmez', (tester) async {
    expect(await _labels(tester, _book(owned: false, digital: true, lent: true)), ['Dijital']);
    expect(await _labels(tester, _book(owned: false)), isEmpty);
  });
}
