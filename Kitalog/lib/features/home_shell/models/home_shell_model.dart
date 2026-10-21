import 'package:flutter/foundation.dart';

@immutable
class HomeShellModel {
  final int selectedIndex;

  const HomeShellModel({this.selectedIndex = 0});

  HomeShellModel copyWith({int? selectedIndex}) {
    return HomeShellModel(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  factory HomeShellModel.fromJson(Map<String, dynamic> json) {
    return HomeShellModel(selectedIndex: json['selectedIndex'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'selectedIndex': selectedIndex};
  }
}
