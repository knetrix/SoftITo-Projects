/// Kadrodaki bir oyuncu: `{slot, firstName, lastName}` (§6.2).
class PlayerModel {
  const PlayerModel({
    required this.slot,
    required this.firstName,
    this.lastName = '',
  });

  final String slot;
  final String firstName;
  final String lastName;

  String get fullName =>
      lastName.isEmpty ? firstName : '$firstName $lastName';

  PlayerModel withSlot(String s) =>
      PlayerModel(slot: s, firstName: firstName, lastName: lastName);

  factory PlayerModel.fromMap(Map<String, dynamic> m) => PlayerModel(
        slot: (m['slot'] ?? '') as String,
        firstName: (m['firstName'] ?? '') as String,
        lastName: (m['lastName'] ?? '') as String,
      );

  Map<String, dynamic> toMap() =>
      {'slot': slot, 'firstName': firstName, 'lastName': lastName};

  static List<PlayerModel> listFrom(Object? raw) => [
        for (final e in (raw as List? ?? const []))
          PlayerModel.fromMap(Map<String, dynamic>.from(e as Map)),
      ];

  static Map<String, PlayerModel> mapFrom(List<PlayerModel> list) =>
      {for (final p in list) p.slot: p};

  @override
  bool operator ==(Object other) =>
      other is PlayerModel &&
      other.slot == slot &&
      other.firstName == firstName &&
      other.lastName == lastName;

  @override
  int get hashCode => Object.hash(slot, firstName, lastName);
}
