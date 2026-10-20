import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Gerçek araç fotoğrafı (`Image.network`). Placeholder/ikon yedeği yalnızca
/// yükleme hatasında gösterilir.
class VehicleImageWidget extends StatelessWidget {
  const VehicleImageWidget({
    super.key,
    required this.url,
    required this.semanticLabel,
    this.width,
    this.height = 96,
  });

  static const Map<String, String> _headers = {
    'User-Agent': 'Tiknow/1.0 (Flutter student project)',
  };

  final String url;
  final String semanticLabel;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        height: height,
        color: scheme.surfaceContainerHighest,
        child: Image.network(
          url,
          // Tarayıcılar User-Agent başlığını zaten kısıtlar.
          headers: kIsWeb ? null : _headers,
          fit: BoxFit.cover,
          semanticLabel: semanticLabel,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  value: progress.expectedTotalBytes == null
                      ? null
                      : progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => Center(
            child: Icon(
              Icons.directions_car_filled,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
