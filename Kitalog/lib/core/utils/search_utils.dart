/// Arama için metni sadeleştirir: küçük harfe çevirir, Türkçe `İ/I/ı` ve
/// aksanlı harfleri (`ç ğ ö ş ü`) ASCII karşılıklarına indirger.
String foldForSearch(String value) {
  const map = {
    'İ': 'i',
    'I': 'i',
    'ı': 'i',
    'ç': 'c',
    'Ç': 'c',
    'ğ': 'g',
    'Ğ': 'g',
    'ö': 'o',
    'Ö': 'o',
    'ş': 's',
    'Ş': 's',
    'ü': 'u',
    'Ü': 'u',
    'â': 'a',
    'Â': 'a',
    'î': 'i',
    'û': 'u',
  };
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(map[char] ?? char.toLowerCase());
  }
  return buffer.toString().trim();
}
