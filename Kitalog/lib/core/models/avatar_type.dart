enum AvatarType {
  none,
  preset,
  custom;

  static AvatarType fromName(String? name) {
    return AvatarType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AvatarType.none,
    );
  }
}
