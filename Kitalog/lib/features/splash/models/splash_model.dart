import 'package:flutter/foundation.dart';

import '../../../core/models/view_status.dart';

@immutable
class SplashModel {
  final ViewStatus status;
  final String? destination;

  const SplashModel({this.status = ViewStatus.initial, this.destination});

  bool get isFailure => status == ViewStatus.failure;

  SplashModel copyWith({
    ViewStatus? status,
    String? destination,
    bool clearDestination = false,
  }) {
    return SplashModel(
      status: status ?? this.status,
      destination: clearDestination ? null : (destination ?? this.destination),
    );
  }

  factory SplashModel.fromJson(Map<String, dynamic> json) {
    return SplashModel(
      destination: json['destination'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'destination': destination};
  }
}
