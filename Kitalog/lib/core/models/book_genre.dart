enum BookGenre {
  novel,
  science,
  history,
  philosophy,
  personalDevelopment,
  sciFiFantasy,
  biography,
  poetry,
  children,
  other;

  static BookGenre fromName(String? name) {
    return BookGenre.values.firstWhere(
      (e) => e.name == name,
      orElse: () => BookGenre.other,
    );
  }
}
