import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../models/avatar_type.dart';
import '../models/user_model.dart';

/// Kullanıcı avatarı: hazır avatar (asset), yüklenen resim (base64) veya simge.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, required this.radius});

  final UserModel? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.l10n.profileAvatar,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: context.colors.surfaceContainerHigh,
        backgroundImage: _image(),
        child: _image() == null
            ? Icon(Icons.person, size: radius, color: context.colors.primary)
            : null,
      ),
    );
  }

  ImageProvider? _image() {
    final current = user;
    final value = current?.avatarValue;
    if (current == null || value == null || value.isEmpty) return null;
    switch (current.avatarType) {
      case AvatarType.preset:
        return AssetImage(AppAssets.avatarPath(value));
      case AvatarType.custom:
        try {
          final Uint8List bytes = base64Decode(value);
          return MemoryImage(bytes);
        } on FormatException {
          return null;
        }
      case AvatarType.none:
        return null;
    }
  }
}
