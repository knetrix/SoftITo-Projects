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

  test('iade hatırlatmaları varsayılan açık; kapatma kalıcı yazılır, eski kayıtta açık sayılır', () async {
    final deps = await createTestDependencies();
    expect(deps.settingsController.state.value.loanRemindersEnabled, isTrue);
    await deps.settingsController.setLoanRemindersEnabled(false);
    expect((await deps.settingsRepository.get()).loanRemindersEnabled, isFalse);
    expect(AppSettingsModel.fromJson(const {'themeMode': 'dark'}).loanRemindersEnabled, isTrue);
    expect(AppSettingsModel.fromJson(const AppSettingsModel(loanRemindersEnabled: false).toJson()).loanRemindersEnabled, isFalse);
  });

  test('okuma hatırlatması anahtarları ve saati kalıcı yazılır', () async {
    final deps = await createTestDependencies();
    await deps.settingsController.setReadingRemindersEnabled(true);
    await deps.settingsController.setStalledBookRemindersEnabled(true);
    await deps.settingsController.setReadingReminderMinutes(8 * 60 + 15);
    final saved = await deps.settingsRepository.get();
    expect(saved.readingRemindersEnabled, isTrue);
    expect(saved.stalledBookRemindersEnabled, isTrue);
    expect(saved.readingReminderMinutes, 8 * 60 + 15);
  });
}
