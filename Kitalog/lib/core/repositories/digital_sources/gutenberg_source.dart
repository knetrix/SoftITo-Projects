import '../../utils/reading_text_cleaner.dart';
import '../../utils/text_cleaner.dart';
import 'source_http.dart';

/// Project Gutenberg düz metinleri.
class GutenbergSource {
  GutenbergSource(this._http);

  static const String _host = 'www.gutenberg.org';

  final SourceHttp _http;

  static Uri textUri(String id) =>
      Uri.https(_host, '/cache/epub/$id/pg$id.txt');

  /// Kitabın metnini indirir; lisans başlığı, bitiş bloğu ve biçim işaretleri
  /// (`_italik_`, `[Illustration]`, dipnot numaraları) atılmış olarak döner.
  Future<String> fetchText(String id) async {
    final raw = await _http.getText(textUri(id));
    final text = ReadingTextCleaner.cleanGutenbergMarkup(
      TextCleaner.stripGutenbergBoilerplate(raw),
    );
    if (text.isEmpty) {
      throw const DigitalBookException(DigitalBookFailure.notFound);
    }
    return text;
  }
}
