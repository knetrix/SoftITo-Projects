enum ReadingStatus {
  toRead,
  reading,
  finished;

  static ReadingStatus fromName(String? name) {
    return ReadingStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ReadingStatus.toRead,
    );
  }
}
