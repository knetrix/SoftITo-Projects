import 'book_genre.dart';

/// Seçili kategori: yerleşik tür veya (doluysa) kullanıcı kategorisi. Kayıt
/// (record) olduğu için değer eşitliğiyle karşılaştırılır; ekleme formu ve
/// raf filtresi birlikte kullanır.
typedef GenreChoice = ({BookGenre genre, String? customGenreId});
