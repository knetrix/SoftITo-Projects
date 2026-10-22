import 'package:flutter_test/flutter_test.dart';
import 'package:kitalog/core/constants/app_colors.dart';
import 'package:kitalog/core/models/book_genre.dart';
import 'package:kitalog/core/models/book_model.dart';
import 'package:kitalog/core/models/custom_genre_model.dart';
import 'package:kitalog/core/utils/validators.dart';

import '../helpers/test_dependencies.dart';

CustomGenreModel _genre(String id, int color) =>
    CustomGenreModel(id: id, name: id, colorIndex: color, createdAt: DateTime(2026));

void main() {
  group('CustomGenreModel', () {
    test('JSON gidiş-dönüşü ve palet boyutu AppColors ile aynıdır', () {
      final genre = CustomGenreModel(id: 'g1', name: 'Mizah', colorIndex: 3, createdAt: DateTime(2026, 5, 1));
      final back = CustomGenreModel.fromJson(genre.toJson());
      expect(back.id, 'g1');
      expect(back.name, 'Mizah');
      expect(back.colorIndex, 3);
      expect(back.createdAt, DateTime(2026, 5, 1));
      expect(CustomGenreModel.paletteSize, AppColors.customGenrePalette.length);
    });

    test('ad temizlenir; karşılaştırmada büyük/küçük harf ve İ / I / ı farkı gözetilmez', () {
      expect(CustomGenreModel.cleanName('  Polisiye   Roman '), 'Polisiye Roman');
      expect(CustomGenreModel.nameKey('İNCELEME'), CustomGenreModel.nameKey('inceleme'));
      expect(CustomGenreModel.nameKey('KISA ÖYKÜ'), CustomGenreModel.nameKey('kısa öykü'));
      expect(CustomGenreModel.nameKey('Mizah'), isNot(CustomGenreModel.nameKey('Mizahi')));
    });

    test('yeni renk önce kullanılmayan ilk renktir, hepsi doluysa sırayla döner', () {
      expect(CustomGenreModel.nextColorIndex(const []), 0);
      expect(CustomGenreModel.nextColorIndex([_genre('a', 0), _genre('b', 2)]), 1);
      final full = [for (var i = 0; i < CustomGenreModel.paletteSize; i++) _genre('$i', i)];
      expect(CustomGenreModel.nextColorIndex(full), 0);
    });

    test('BookModel kategori kimliğini saklar ve temizleyebilir', () {
      final book = BookModel(id: 'b', title: 'T', customGenreId: 'g1', addedAt: DateTime(2026));
      expect(BookModel.fromJson(book.toJson()).customGenreId, 'g1');
      expect(book.copyWith(clearCustomGenreId: true).customGenreId, isNull);
      expect(BookModel.fromJson({'id': 'x', 'title': 'Eski kayıt'}).customGenreId, isNull);
    });
  });

  group('Validators.genreName', () {
    const taken = ['Roman', 'Şiir', 'Mizah'];
    final cases = <String?, ValidationError?>{
      null: ValidationError.required,
      '   ': ValidationError.required,
      'roman': ValidationError.genreNameTaken,
      ' ŞİİR ': ValidationError.genreNameTaken,
      'mizah': ValidationError.genreNameTaken,
      'Polisiye': null,
      'a' * 30: null,
      'a' * 31: ValidationError.genreNameTooLong,
    };
    cases.forEach((input, expected) {
      test('"$input" → $expected', () => expect(Validators.genreName(input, taken), expected));
    });
  });

  group('LibraryController kategorileri', () {
    test('kategori eklenir, kalıcı saklanır; aynı ad yeni kategori açmaz', () async {
      final deps = await createTestDependencies();
      final library = deps.libraryController;
      await library.load();
      expect(library.customGenres.value, isEmpty);

      final mizah = await library.addCustomGenre('  Mizah ');
      expect(mizah.name, 'Mizah');
      expect(mizah.colorIndex, 0);
      final again = await library.addCustomGenre('MİZAH');
      expect(again.id, mizah.id);
      final polisiye = await library.addCustomGenre('Polisiye', colorIndex: 5);
      expect(polisiye.colorIndex, 5);
      expect(library.customGenres.value.length, 2);

      await library.load();
      expect(library.customGenres.value.map((g) => g.name), ['Mizah', 'Polisiye']);
      expect(library.customGenreById(polisiye.id)?.name, 'Polisiye');
      expect(library.customGenreById('yok'), isNull);
    });

    test('eşleşme: kategorili kitap "Diğer" sayılmaz; kategorisi silinmiş kitap türüne düşer', () async {
      final deps = await createTestDependencies();
      final library = deps.libraryController;
      await library.load();
      final mizah = await library.addCustomGenre('Mizah');
      final withCustom = BookModel(id: 'a', title: 'A', customGenreId: mizah.id, addedAt: DateTime(2026));
      final orphan = BookModel(id: 'b', title: 'B', customGenreId: 'silinmis', addedAt: DateTime(2026));

      expect(library.matchesGenre(withCustom, customGenreId: mizah.id), isTrue);
      expect(library.matchesGenre(withCustom, genre: BookGenre.other), isFalse);
      expect(library.matchesGenre(orphan, genre: BookGenre.other), isTrue);
      expect(library.matchesGenre(orphan, customGenreId: 'silinmis'), isFalse);
      expect(library.matchesGenre(withCustom), isTrue);
    });
  });
}
