import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/models/app_settings_model.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/digital_copy_model.dart';
import 'package:kitalog/core/models/digital_edition_model.dart';
import 'package:kitalog/core/models/digital_format.dart';
import 'package:kitalog/core/models/digital_source.dart';

void main() {
  final date = DateTime(2026, 10, 22);

  test('DigitalEditionModel gidiş-dönüş ve bozuk veri', () {
    const edition = DigitalEditionModel(
      source: DigitalSource.wikisource,
      sourceId: 'Kürk Mantolu Madonna',
      languageCode: 'tr',
    );
    expect(DigitalEditionModel.fromJson(edition.toJson()).toJson(), edition.toJson());
    expect(DigitalEditionModel.tryFromJson({'source': 'bilinmeyen', 'sourceId': 'x'}), isNull);
    expect(DigitalEditionModel.tryFromJson({'source': 'gutenberg', 'sourceId': ''}), isNull);
    expect(DigitalEditionModel.tryFromJson('metin'), isNull);
  });

  test('BookModel dijital sürümü saklar, eski kayıtlarda null okur, temizlenebilir', () {
    final book = BookModel(
      id: 'b',
      title: 'Crime and Punishment',
      pageCount: 551,
      addedAt: date,
      digitalEdition: const DigitalEditionModel(
        source: DigitalSource.gutenberg,
        sourceId: '2554',
        languageCode: 'en',
      ),
    );
    final back = BookModel.fromJson(book.toJson());
    expect(back.digitalEdition?.sourceId, '2554');
    expect(back.hasDigitalEdition, isTrue);
    expect(BookModel.fromJson({'id': 'eski', 'title': 'T'}).digitalEdition, isNull);
    expect(book.copyWith(clearDigitalEdition: true).digitalEdition, isNull);
  });

  test('DigitalCopyModel ilerlemeyi hesaplar ve gidiş-dönüş yapar', () {
    final copy = DigitalCopyModel(
      bookId: 'b',
      fileName: 'b.txt',
      charCount: 1000,
      downloadedAt: date,
      lastOffset: 250,
    );
    expect(copy.progress, 0.25);
    expect(copy.copyWith(lastOffset: 5000).progress, 1.0);
    expect(DigitalCopyModel.fromJson(copy.toJson()).toJson(), copy.toJson());
    expect(copy.copyWith(charCount: 0).progress, 0);
  });

  test('AppSettingsModel okuyucu yazı boyutunu sınırlar ve saklar', () {
    const settings = AppSettingsModel();
    expect(settings.readerTextScale, 1.0);
    expect(settings.copyWith(readerTextScale: 9).readerTextScale, AppSettingsModel.maxReaderTextScale);
    expect(settings.copyWith(readerTextScale: 0.1).readerTextScale, AppSettingsModel.minReaderTextScale);
    final back = AppSettingsModel.fromJson(settings.copyWith(readerTextScale: 1.4).toJson());
    expect(back.readerTextScale, 1.4);
    expect(AppSettingsModel.fromJson({}).readerTextScale, 1.0);
  });

  test('kullanıcı dosyası sürümü ve PDF kopyası biçimiyle saklanır; eski kayıtlar metin sayılır', () {
    const edition = DigitalEditionModel(
      source: DigitalSource.localFile,
      sourceId: 'sula.pdf',
      languageCode: '',
      format: DigitalFormat.pdf,
    );
    final back = DigitalEditionModel.fromJson(edition.toJson());
    expect(back.isLocalFile, isTrue);
    expect(back.format, DigitalFormat.pdf);
    expect(DigitalEditionModel.tryFromJson({'source': 'gutenberg', 'sourceId': '1'})!.format, DigitalFormat.text);

    final copy = DigitalCopyModel(
      bookId: 'k',
      fileName: 'k.pdf',
      charCount: 40,
      downloadedAt: DateTime(2026),
      lastOffset: 10,
      format: DigitalFormat.pdf,
      byteSize: 2048,
    );
    expect(DigitalCopyModel.fromJson(copy.toJson()).toJson(), copy.toJson());
    expect(DigitalCopyModel.fromJson({'bookId': 'x'}).format, DigitalFormat.text);
  });
}
