#!/usr/bin/env bash

# ==============================================================================
# Flutter Feature Scaffold Oluşturucu (Rutino Projesi)
# Kurallar: PROJECT.md & SKILL.md
# ==============================================================================

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Hata: Feature adı parametre olarak verilmelidir."
  echo "Kullanım: ./generate_feature.sh <feature_name>"
  echo "Örnek:    ./generate_feature.sh habits"
  exit 1
fi

FEATURE_NAME="$1"

# snake_case kontrolü / küçük harf temizliği
FEATURE_NAME="$(echo "${FEATURE_NAME}" | tr '[:upper:]' '[:lower:]' | tr '-' '_')"

# PascalCase dönüştürme fonksiyonu
to_pascal_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1)) substr($i,2); print ""}'
}

PASCAL_NAME="$(to_pascal_case "${FEATURE_NAME}")"

TARGET_DIR="lib/features/${FEATURE_NAME}"
CONTROLLERS_DIR="${TARGET_DIR}/controllers"
MODELS_DIR="${TARGET_DIR}/models"
VIEWS_DIR="${TARGET_DIR}/views"
WIDGETS_DIR="${TARGET_DIR}/widgets"

echo "==> Rutino: '${FEATURE_NAME}' için klasör yapısı oluşturuluyor..."
mkdir -p "${CONTROLLERS_DIR}" "${MODELS_DIR}" "${VIEWS_DIR}" "${WIDGETS_DIR}"

MODEL_FILE="${MODELS_DIR}/${FEATURE_NAME}_model.dart"
CONTROLLER_FILE="${CONTROLLERS_DIR}/${FEATURE_NAME}_controller.dart"
VIEW_FILE="${VIEWS_DIR}/${FEATURE_NAME}_view.dart"
WIDGET_FILE="${WIDGETS_DIR}/${FEATURE_NAME}_widget.dart"

# 1. Model Dosyası
echo "==> Model oluşturuluyor: ${MODEL_FILE}"
cat <<EOF > "${MODEL_FILE}"
import 'package:flutter/foundation.dart';

@immutable
class ${PASCAL_NAME}Model {
  final String id;
  final bool isLoading;

  const ${PASCAL_NAME}Model({
    required this.id,
    this.isLoading = false,
  });

  ${PASCAL_NAME}Model copyWith({
    String? id,
    bool? isLoading,
  }) {
    return ${PASCAL_NAME}Model(
      id: id ?? this.id,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ${PASCAL_NAME}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_NAME}Model(
      id: json['id'] as String? ?? '',
      isLoading: json['isLoading'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isLoading': isLoading,
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
  final ValueNotifier<${PASCAL_NAME}Model> state = ValueNotifier<${PASCAL_NAME}Model>(
    const ${PASCAL_NAME}Model(id: ''),
  );

  void setLoading(bool loading) {
    state.value = state.value.copyWith(isLoading: loading);
  }

  void updateId(String newId) {
    state.value = state.value.copyWith(id: newId);
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

class ${PASCAL_NAME}CardWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const ${PASCAL_NAME}CardWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
    _controller = ${PASCAL_NAME}Controller();
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
        title: const Text('${PASCAL_NAME}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<${PASCAL_NAME}Model>(
            valueListenable: _controller.state,
            builder: (context, state, _) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ${PASCAL_NAME}CardWidget(
                    title: state.id.isEmpty ? 'Kayıt Yok' : state.id,
                    onTap: () => _controller.updateId('ID_\${DateTime.now().millisecondsSinceEpoch}'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
EOF

echo "==> Tamamlandı: '${FEATURE_NAME}' modülü Rutino standartlarına uygun olarak başarıyla üretildi."
echo "==> Doğrulama için: flutter analyze"
