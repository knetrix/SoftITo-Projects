import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tiknow/core/constants/app_strings.dart';

void main() {
  test('TR ve EN anahtar kümeleri aynı', () {
    expect(AppStrings.en.keys.toSet(), AppStrings.tr.keys.toSet());
  });

  test('çeviri değerleri boş değil ve yer tutucular iki dilde aynı', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final key in AppStrings.tr.keys) {
      final tr = AppStrings.tr[key]!;
      final en = AppStrings.en[key]!;
      expect(tr.trim(), isNotEmpty, reason: key);
      expect(en.trim(), isNotEmpty, reason: key);
      expect(
        placeholder.allMatches(tr).map((m) => m.group(1)).toSet(),
        placeholder.allMatches(en).map((m) => m.group(1)).toSet(),
        reason: 'yer tutucular: $key',
      );
    }
  });

  test('kodda geçen tüm sabit anahtarlar tanımlı', () {
    final used = <String>{};
    final pattern = RegExp(
      r"""(?:tr\(|titleKey: |subtitleKey: |labelKey: |nameKey: )\s*'([a-z][a-z_0-9]*)'""",
    );
    final literal = RegExp(r"'((?:err|map|plan|package|fuel|gear|unit)_[a-z_0-9]+)'");
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('app_strings.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in pattern.allMatches(src)) {
        used.add(m.group(1)!);
      }
      for (final m in literal.allMatches(src)) {
        used.add(m.group(1)!);
      }
    }
    final missing = used.where((k) => !AppStrings.tr.containsKey(k)).toList();
    expect(missing, isEmpty);
    expect(used, isNotEmpty);
  });

  test('translate: yer tutucu, dil ve geri düşüş', () {
    expect(AppStrings.translate('tr', 'walking_minutes', args: {'n': '3'}), '3 dk yürüme');
    expect(AppStrings.translate('en', 'walking_minutes', args: {'n': '3'}), '3 min walk');
    expect(AppStrings.translate('de', 'ok'), 'Tamam');
    expect(AppStrings.translate('tr', 'yok_boyle_anahtar'), 'yok_boyle_anahtar');
  });
}
