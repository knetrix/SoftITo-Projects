import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/app_settings_model.dart';

import '../helpers/test_dependencies.dart';

void main() {
  test('okuyucu yazı boyutu kalıcı kaydedilir ve sınırlanır', () async {
    final deps = await createTestDependencies();
    await deps.settingsController.setReaderTextScale(1.3);
    expect(deps.settingsController.state.value.readerTextScale, 1.3);
    expect((await deps.settingsRepository.get()).readerTextScale, 1.3);
    await deps.settingsController.setReaderTextScale(10);
    expect(
      deps.settingsController.state.value.readerTextScale,
      AppSettingsModel.maxReaderTextScale,
    );
  });
}
