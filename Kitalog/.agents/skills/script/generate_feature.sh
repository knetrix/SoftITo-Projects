#!/usr/bin/env bash

# ==============================================================================
# Flutter Feature Scaffold Oluşturucu (Kitalog Projesi)
# Kurallar: PROJECT.md & .agents/skills/SKILL.md
# Kullanım: Proje kökünden -> bash .agents/skills/script/generate_feature.sh <feature_name>
# ==============================================================================

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Hata: Feature adı parametre olarak verilmelidir."
  echo "Kullanım: bash .agents/skills/script/generate_feature.sh <feature_name>"
  echo "Örnek:    bash .agents/skills/script/generate_feature.sh reading_goal"
  exit 1
fi

if [ ! -f "pubspec.yaml" ]; then
  echo "Hata: pubspec.yaml bulunamadı. Script'i Flutter proje kökünden çalıştırın."
  exit 1
fi

# snake_case kontrolü / küçük harf temizliği
FEATURE_NAME="$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr '-' '_')"

if ! [[ "${FEATURE_NAME}" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Hata: Feature adı snake_case olmalıdır (örn: book_detail)."
  exit 1
fi

# PascalCase dönüştürme: book_detail -> BookDetail
to_pascal_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) substr($i,2); print ""}'
}

# camelCase dönüştürme: book_detail -> bookDetail
to_camel_case() {
  local pascal
  pascal="$(to_pascal_case "$1")"
  echo "$(echo "${pascal:0:1}" | tr '[:upper:]' '[:lower:]')${pascal:1}"
}

PASCAL_NAME="$(to_pascal_case "${FEATURE_NAME}")"
CAMEL_NAME="$(to_camel_case "${FEATURE_NAME}")"
PACKAGE_NAME="$(awk '/^name:/ {print $2; exit}' pubspec.yaml)"
TITLE_KEY="${CAMEL_NAME}Title"

TARGET_DIR="lib/features/${FEATURE_NAME}"
CONTROLLERS_DIR="${TARGET_DIR}/controllers"
MODELS_DIR="${TARGET_DIR}/models"
VIEWS_DIR="${TARGET_DIR}/views"
WIDGETS_DIR="${TARGET_DIR}/widgets"
TEST_DIR="test/features/${FEATURE_NAME}"

if [ -d "${TARGET_DIR}" ]; then
  echo "Hata: '${TARGET_DIR}' zaten mevcut. Mevcut dosyaların üzerine yazılmaz."
  exit 1
fi

echo "==> '${FEATURE_NAME}' için klasör yapısı oluşturuluyor..."
mkdir -p "${CONTROLLERS_DIR}" "${MODELS_DIR}" "${VIEWS_DIR}" "${WIDGETS_DIR}" "${TEST_DIR}"

MODEL_FILE="${MODELS_DIR}/${FEATURE_NAME}_model.dart"
CONTROLLER_FILE="${CONTROLLERS_DIR}/${FEATURE_NAME}_controller.dart"
VIEW_FILE="${VIEWS_DIR}/${FEATURE_NAME}_view.dart"
WIDGET_FILE="${WIDGETS_DIR}/${FEATURE_NAME}_widget.dart"
TEST_FILE="${TEST_DIR}/${FEATURE_NAME}_controller_test.dart"

# 1. Model Dosyası
echo "==> Model oluşturuluyor: ${MODEL_FILE}"
cat <<EOF > "${MODEL_FILE}"
import 'package:flutter/foundation.dart';

enum ViewStatus { initial, loading, success, failure }

@immutable
class ${PASCAL_NAME}Model {
  final ViewStatus status;
  final List<String> items;

  const ${PASCAL_NAME}Model({
    this.status = ViewStatus.initial,
    this.items = const [],
  });

  bool get isLoading => status == ViewStatus.loading;

  ${PASCAL_NAME}Model copyWith({
    ViewStatus? status,
    List<String>? items,
  }) {
    return ${PASCAL_NAME}Model(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
    };
  }
}
EOF

# 2. Controller Dosyası
echo "==> Controller oluşturuluyor: ${CONTROLLER_FILE}"
cat <<EOF > "${CONTROLLER_FILE}"
import 'package:flutter/foundation.dart';

import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_NAME}Controller {
  final ValueNotifier<${PASCAL_NAME}Model> state =
      ValueNotifier<${PASCAL_NAME}Model>(const ${PASCAL_NAME}Model());

  Future<void> load() async {
    state.value = state.value.copyWith(status: ViewStatus.loading);
    // Repository çağrısı burada yapılır (lib/core/repositories/).
    state.value = state.value.copyWith(status: ViewStatus.success);
  }

  void addItem(String item) {
    // Liste yerinde değiştirilmez; yeni liste üretilir.
    state.value = state.value.copyWith(items: [...state.value.items, item]);
  }

  void dispose() {
    state.dispose();
  }
}
EOF

# 3. Widget Dosyası
echo "==> Widget oluşturuluyor: ${WIDGET_FILE}"
cat <<EOF > "${WIDGET_FILE}"
import 'package:flutter/material.dart';

class ${PASCAL_NAME}ItemWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ${PASCAL_NAME}ItemWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
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
import '../controllers/${FEATURE_NAME}_controller.dart';
import '../models/${FEATURE_NAME}_model.dart';
import '../widgets/${FEATURE_NAME}_widget.dart';

class ${PASCAL_NAME}View extends StatefulWidget {
  const ${PASCAL_NAME}View({super.key});

  @override
  State<${PASCAL_NAME}View> createState() => _${PASCAL_NAME}ViewState();
}

class _${PASCAL_NAME}ViewState extends State<${PASCAL_NAME}View> {
  late final ${PASCAL_NAME}Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller = ${PASCAL_NAME}Controller()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.${TITLE_KEY})),
      body: SafeArea(
        child: ValueListenableBuilder<${PASCAL_NAME}Model>(
          valueListenable: _controller.state,
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return ${PASCAL_NAME}ItemWidget(title: state.items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
EOF

# 5. Test Dosyası
echo "==> Test oluşturuluyor: ${TEST_FILE}"
cat <<EOF > "${TEST_FILE}"
import 'package:flutter_test/flutter_test.dart';
import 'package:${PACKAGE_NAME}/features/${FEATURE_NAME}/controllers/${FEATURE_NAME}_controller.dart';
import 'package:${PACKAGE_NAME}/features/${FEATURE_NAME}/models/${FEATURE_NAME}_model.dart';

void main() {
  late ${PASCAL_NAME}Controller controller;

  setUp(() => controller = ${PASCAL_NAME}Controller());
  tearDown(() => controller.dispose());

  test('başlangıç state değeri initial ve boş liste', () {
    expect(controller.state.value.status, ViewStatus.initial);
    expect(controller.state.value.items, isEmpty);
  });

  test('load sonrası state success olur', () async {
    await controller.load();
    expect(controller.state.value.status, ViewStatus.success);
  });

  test('addItem yeni liste üreterek eleman ekler', () {
    final before = controller.state.value.items;
    controller.addItem('Örnek');
    expect(controller.state.value.items, ['Örnek']);
    expect(identical(before, controller.state.value.items), isFalse);
  });
}
EOF

# 6. Çoklu Dil Anahtarı (ARB)
add_arb_key() {
  local file="$1"
  local value="$2"
  if [ ! -f "${file}" ]; then
    echo "==> Uyarı: ${file} bulunamadı, '${TITLE_KEY}' anahtarını elle ekleyin."
    return
  fi
  if grep -q "\"${TITLE_KEY}\"" "${file}"; then
    echo "==> ${file}: '${TITLE_KEY}' zaten mevcut."
    return
  fi
  # İlk '{' satırından hemen sonra anahtarı ekler (GNU/BSD uyumlu olması için awk).
  awk -v line="  \"${TITLE_KEY}\": \"${value}\"," 'NR==1 && /^\{/ {print; print line; next} {print}' \
    "${file}" > "${file}.tmp" && mv "${file}.tmp" "${file}"
  echo "==> ${file}: '${TITLE_KEY}' eklendi (değeri çevirin)."
}

add_arb_key "lib/l10n/app_tr.arb" "${PASCAL_NAME}"
add_arb_key "lib/l10n/app_en.arb" "${PASCAL_NAME}"

if [ ! -f "lib/core/extensions/context_extensions.dart" ]; then
  echo "==> Uyarı: lib/core/extensions/context_extensions.dart yok; view içindeki context.l10n çalışmaz."
fi

echo "==> Tamamlandı: '${FEATURE_NAME}' başarıyla üretildi."
echo "==> Sonraki adımlar: ARB değerlerini çevir, gerekirse AppRoutes'a rota ekle."
echo "==> Doğrulama için: flutter gen-l10n && flutter analyze && flutter test"
