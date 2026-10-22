import 'package:flutter/foundation.dart';

/// Bildirime dokununca açılacak yer.
enum NotificationTargetKind {
  /// Kitap Detay (iade hatırlatması).
  book,

  /// Okumaya dön: dijital sürümü varsa Okuyucu, yoksa Kitap Detay (okuma hatırlatması).
  read,

  /// Okuma Durumu sekmesi (okunan kitap yokken günlük hatırlatma).
  readingStatus;

  static NotificationTargetKind fromName(String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return NotificationTargetKind.book;
  }
}

/// Bildirimin `payload`'ında taşınan hedef: `book:<id>`, `read:<id>` veya
/// `readingStatus`. Önceki sürümün bildirimleri yalnızca kitap kimliği taşır;
/// önek yoksa hedef Kitap Detay sayılır.
@immutable
class NotificationTargetModel {
  final NotificationTargetKind kind;
  final String? bookId;

  const NotificationTargetModel({required this.kind, this.bookId});

  const NotificationTargetModel.book(String this.bookId) : kind = NotificationTargetKind.book;

  const NotificationTargetModel.read(String this.bookId) : kind = NotificationTargetKind.read;

  const NotificationTargetModel.readingStatus() : kind = NotificationTargetKind.readingStatus, bookId = null;

  /// Boş veya kitabı eksik payload için `null`.
  static NotificationTargetModel? parse(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    if (payload == NotificationTargetKind.readingStatus.name) return const NotificationTargetModel.readingStatus();
    final separator = payload.indexOf(':');
    if (separator < 0) return NotificationTargetModel.book(payload);
    final kind = payload.substring(0, separator);
    final bookId = payload.substring(separator + 1);
    if (bookId.isEmpty) return null;
    return kind == NotificationTargetKind.read.name
        ? NotificationTargetModel.read(bookId)
        : NotificationTargetModel.book(bookId);
  }

  String encode() => bookId == null ? kind.name : '${kind.name}:$bookId';

  NotificationTargetModel copyWith({NotificationTargetKind? kind, String? bookId}) {
    return NotificationTargetModel(kind: kind ?? this.kind, bookId: bookId ?? this.bookId);
  }

  factory NotificationTargetModel.fromJson(Map<String, dynamic> json) {
    return NotificationTargetModel(
      kind: NotificationTargetKind.fromName(json['kind'] as String?),
      bookId: json['bookId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'kind': kind.name, 'bookId': bookId};

  @override
  bool operator ==(Object other) => other is NotificationTargetModel && other.kind == kind && other.bookId == bookId;

  @override
  int get hashCode => Object.hash(kind, bookId);

  @override
  String toString() => encode();
}
