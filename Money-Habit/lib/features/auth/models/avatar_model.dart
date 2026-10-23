import 'package:flutter/foundation.dart';

enum AvatarType {
  preset,
  file,
}

@immutable
class AvatarModel {
  final AvatarType type;
  final String value;

  const AvatarModel({
    required this.type,
    required this.value,
  });

  AvatarModel copyWith({
    AvatarType? type,
    String? value,
  }) {
    return AvatarModel(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      type: AvatarType.values.asNameMap()[json['type']] ?? AvatarType.preset,
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
    };
  }
}
