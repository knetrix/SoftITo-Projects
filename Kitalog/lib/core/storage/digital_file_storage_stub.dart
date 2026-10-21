import 'digital_file_storage.dart';

/// `dart:io` olmayan platformlarda (web) bellek içi depolama kullanılır.
DigitalFileStorage createPlatformDigitalFileStorage() =>
    MemoryDigitalFileStorage();
