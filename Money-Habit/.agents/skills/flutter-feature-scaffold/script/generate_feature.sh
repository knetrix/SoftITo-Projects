#!/usr/bin/env bash

# ==============================================================================
# Flutter Feature Scaffold Oluşturucu (Money Habit Tracker Projesi)
# Kurallar: PROJECT_NEW.md & SKILL.md
# Proje kök dizininde (pubspec.yaml'ın olduğu yerde) çalıştırılmalıdır.
# ==============================================================================

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Hata: Feature adı parametre olarak verilmelidir."
  echo "Kullanım: bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh <feature_name>"
  echo "Örnek:    bash .agents/skills/flutter-feature-scaffold/script/generate_feature.sh expenses"
  exit 1
fi

if [ ! -f "pubspec.yaml" ]; then
  echo "Hata: pubspec.yaml bulunamadı. Script proje kök dizininde çalıştırılmalıdır."
  exit 1
fi

# snake_case kontrolü / küçük harf temizliği
FEATURE_NAME="$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_')"

if ! [[ "${FEATURE_NAME}" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Hata: Feature adı snake_case olmalıdır (örn: expenses, budget_stats)."
  exit 1
fi

PACKAGE_NAME="$(awk '/^name:/ {print $2; exit}' pubspec.yaml)"

# PascalCase dönüştürme fonksiyonu
to_pascal_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) substr($i,2); print ""}'
}

PASCAL_NAME="$(to_pascal_case "${FEATURE_NAME}")"
CAMEL_NAME="$(echo "${PASCAL_NAME:0:1}" | tr '[:upper:]' '[:lower:]')${PASCAL_NAME:1}"
L10N_TITLE_KEY="${CAMEL_NAME}Title"

TARGET_DIR="lib/features/${FEATURE_NAME}"
CONTROLLERS_DIR="${TARGET_DIR}/controllers"
MODELS_DIR="${TARGET_DIR}/models"
VIEWS_DIR="${TARGET_DIR}/views"
WIDGETS_DIR="${TARGET_DIR}/widgets"
TEST_DIR="test/features/${FEATURE_NAME}"

# Var olan feature'ın üzerine yazmayı engelle
if [ -d "${TARGET_DIR}" ] && [ -n "$(ls -A "${TARGET_DIR}" 2>/dev/null)" ]; then
  echo "Hata: '${TARGET_DIR}' zaten mevcut ve boş değil. Üzerine yazılmadı."
  exit 1
fi

echo "==> '${FEATURE_NAME}' için klasör yapısı oluşturuluyor..."
mkdir -p "${CONTROLLERS_DIR}" "${MODELS_DIR}" "${VIEWS_DIR}" "${WIDGETS_DIR}" "${TEST_DIR}"

MODEL_FILE="${MODELS_DIR}/${FEATURE_NAME}_model.dart"
CONTROLLER_FILE="${CONTROLLERS_DIR}/${FEATURE_NAME}_controller.dart"
VIEW_FILE="${VIEWS_DIR}/${FEATURE_NAME}_view.dart"
WIDGET_FILE="${WIDGETS_DIR}/${FEATURE_NAME}_card.dart"
TEST_FILE="${TEST_DIR}/${FEATURE_NAME}_controller_test.dart"

# 1. Model Dosyası
echo "==> Model oluşturuluyor: ${MODEL_FILE}"
cat <<EOF > "${MODEL_FILE}"
import 'package:flutter/foundation.dart';

@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final String title;
  final int amount; // kuruş
  final DateTime createdAt;

  const ${PASCAL_NAME}Model({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
  });

  ${PASCAL_NAME}Model copyWith({
    String? id,
    String? title,
    int? amount,
    DateTime? createdAt,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
EOF

# 2. Controller Dosyası
echo "==> Controller oluşturuluyor: ${CONTROLLER_FILE}"
cat <<EOF > "${CONTROLLER_FILE}"
import 'package:flutter/foundation.dart';

import '../../../core/services/local_storage_service.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Controller {
  // TODO: Anahtarı core/constants/storage_keys.dart içine taşı.
  static const String _storageKey = '${FEATURE_NAME}';

  final LocalStorageService _storage;
  final ValueNotifier<List<${PASCAL_NAME}Model>> items;

  ${PASCAL_NAME}Controller(this._storage)
      : items = ValueNotifier<List<${PASCAL_NAME}Model>>(
          _storage
              .readJsonList(_storageKey)
              .map(${PASCAL_NAME}Model.fromJson)
              .toList(),
        );

  int get totalAmount => items.value.fold(0, (sum, e) => sum + e.amount);

  Future<void> add(${PASCAL_NAME}Model item) async {
    items.value = [item, ...items.value];
    await _persist();
  }

  Future<void> remove(String id) async {
    items.value = items.value.where((e) => e.id != id).toList();
    await _persist();
  }

  Future<void> _persist() => _storage.writeJsonList(
        _storageKey,
        items.value.map((e) => e.toJson()).toList(),
      );

  void dispose() {
    items.dispose();
  }
}
EOF

# 3. Widget Dosyası
echo "==> Widget oluşturuluyor: ${WIDGET_FILE}"
cat <<EOF > "${WIDGET_FILE}"
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/money_extensions.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Card extends StatelessWidget {
  final ${PASCAL_NAME}Model item;
  final VoidCallback? onTap;

  const ${PASCAL_NAME}Card({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return Card(
      child: ListTile(
        title: Text(item.title, style: context.textStyles.titleMedium),
        trailing: Text(
          item.amount.toCurrency(localeCode),
          style: context.textStyles.titleMedium,
        ),
        onTap: onTap,
      ),
    );
  }
}
EOF

# 4. View Dosyası
echo "==> View oluşturuluyor: ${VIEW_FILE}"
cat <<EOF > "${VIEW_FILE}"
import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/widgets/settings_action_button.dart';
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../models/${FEATURE_NAME}_model.dart';
import '../widgets/${FEATURE_NAME}_card.dart';

class ${PASCAL_NAME}View extends StatefulWidget {
  final LocalStorageService storage;

  const ${PASCAL_NAME}View({super.key, required this.storage});

  @override
  State<${PASCAL_NAME}View> createState() => _${PASCAL_NAME}ViewState();
}

class _${PASCAL_NAME}ViewState extends State<${PASCAL_NAME}View> {
  late final ${PASCAL_NAME}Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = ${PASCAL_NAME}Controller(widget.storage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.${L10N_TITLE_KEY}),
        actions: const [SettingsActionButton()],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<${PASCAL_NAME}Model>>(
          valueListenable: _controller.items,
          builder: (context, items, _) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => ${PASCAL_NAME}Card(item: items[index]),
            );
          },
        ),
      ),
    );
  }
}
EOF

# 5. Birim Test İskeleti
echo "==> Test oluşturuluyor: ${TEST_FILE}"
cat <<EOF > "${TEST_FILE}"
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:${PACKAGE_NAME}/core/services/local_storage_service.dart';
import 'package:${PACKAGE_NAME}/features/${FEATURE_NAME}/controllers/${FEATURE_NAME}_controller.dart';
import 'package:${PACKAGE_NAME}/features/${FEATURE_NAME}/models/${FEATURE_NAME}_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ${PASCAL_NAME}Controller controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = await LocalStorageService.init();
    controller = ${PASCAL_NAME}Controller(storage);
  });

  tearDown(() => controller.dispose());

  test('başlangıçta liste boştur', () {
    expect(controller.items.value, isEmpty);
    expect(controller.totalAmount, 0);
  });

  test('add ve remove listeyi ve toplamı günceller', () async {
    final item = ${PASCAL_NAME}Model(
      id: '1',
      title: 'Test',
      amount: 12550,
      createdAt: DateTime(2026, 1, 1),
    );

    await controller.add(item);
    expect(controller.items.value, hasLength(1));
    expect(controller.totalAmount, 12550);

    await controller.remove('1');
    expect(controller.items.value, isEmpty);
  });
}
EOF

# 6. l10n Başlık Anahtarı (ARB dosyaları varsa ve anahtar yoksa eklenir)
add_arb_key() {
  local file="$1" key="$2" value="$3"
  [ -f "${file}" ] || return 0
  grep -q "\"${key}\"" "${file}" && return 0
  perl -0pi -e "s/\\s*\\}\\s*\\z/,\\n  \"${key}\": \"${value}\"\\n}\\n/" "${file}"
  echo "==> l10n anahtarı eklendi: ${file} -> ${key}"
}

add_arb_key "lib/core/l10n/app_tr.arb" "${L10N_TITLE_KEY}" "${PASCAL_NAME}"
add_arb_key "lib/core/l10n/app_en.arb" "${L10N_TITLE_KEY}" "${PASCAL_NAME}"

echo "==> Tamamlandı: '${FEATURE_NAME}' başarıyla üretildi."
echo "==> Sonraki adımlar:"
echo "    1. app_tr.arb / app_en.arb içindeki '${L10N_TITLE_KEY}' değerlerini gerçek başlıklarla değiştir."
echo "    2. Model alanlarını feature'a göre düzenle, storage anahtarını StorageKeys'e taşı."
echo "    3. flutter gen-l10n && flutter analyze && flutter test"
