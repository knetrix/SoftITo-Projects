import 'package:flutter/foundation.dart';

/// Kullanıcının eklediği kategori (yerleşik `BookGenre` türlerinde olmayan).
/// Kitap bu kategoriye `BookModel.customGenreId` ile bağlanır; rengi
/// `AppColors.customGenrePalette` içindeki sırasıdır.
@immutable
class CustomGenreModel {
  /// `AppColors.customGenrePalette` içindeki renk sayısı.
  static const int paletteSize = 8;

  /// Kategori adının en fazla uzunluğu (etiketlere sığması için).
  static const int maxNameLength = 30;

  /// Kayıt için ad: baş/son boşluklar atılır, iç boşluklar teke indirilir.
  static String cleanName(String name) => name.trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Karşılaştırma anahtarı: büyük/küçük harf ve Türkçe İ / I / ı farkı gözetilmez.
  static String nameKey(String name) => cleanName(name).replaceAll(RegExp('[İIı]'), 'i').toLowerCase();

  /// [existing] kategorilerinde henüz kullanılmayan ilk palet rengi; hepsi
  /// kullanıldıysa sırayla döner.
  static int nextColorIndex(List<CustomGenreModel> existing) {
    final used = existing.map((g) => g.colorIndex).toSet();
    for (var i = 0; i < paletteSize; i++) {
      if (!used.contains(i)) return i;
    }
    return existing.length % paletteSize;
  }

  final String id;
  final String name;
  final int colorIndex;
  final DateTime createdAt;

  const CustomGenreModel({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    required this.createdAt,
  });

  CustomGenreModel copyWith({
    String? id,
    String? name,
    int? colorIndex,
    DateTime? createdAt,
  }) {
    return CustomGenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CustomGenreModel.fromJson(Map<String, dynamic> json) {
    return CustomGenreModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      colorIndex: json['colorIndex'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
