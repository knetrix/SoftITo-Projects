import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extension.dart';
import '../controllers/rental_map_controller.dart';
import '../models/istanbul_geo.dart';
import '../models/vehicle_model.dart';
import 'istanbul_map_painter.dart';
import 'vehicle_marker_painter.dart';

/// Kaydırılıp yakınlaştırılabilen İstanbul haritası + araç simgeleri.
/// Yerel `TransformationController` dışında durum tutmaz.
class RentalMapCanvasWidget extends StatefulWidget {
  const RentalMapCanvasWidget({
    super.key,
    required this.controller,
    required this.onVehicleTap,
  });

  final RentalMapController controller;

  /// Boş alana dokunulursa `null` ile çağrılır.
  final ValueChanged<VehicleModel?> onVehicleTap;

  @override
  State<RentalMapCanvasWidget> createState() => _RentalMapCanvasWidgetState();
}

class _RentalMapCanvasWidgetState extends State<RentalMapCanvasWidget> {
  static const double _overscan = 1.8;
  static const double _maxScale = 3.5;

  final TransformationController _transform = TransformationController();
  Size _viewport = Size.zero;
  Size _canvas = Size.zero;
  bool _centered = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  Offset get _userNormalized => IstanbulGeo.normalize(
        widget.controller.userLatitude,
        widget.controller.userLongitude,
      );

  void _centerOnUser() {
    if (_viewport == Size.zero) return;
    final scale = _transform.value.getMaxScaleOnAxis();
    final user = _userNormalized;
    final tx = (_viewport.width / 2 - user.dx * _canvas.width * scale)
        .clamp(_viewport.width - _canvas.width * scale, 0.0);
    final ty = (_viewport.height / 2 - user.dy * _canvas.height * scale)
        .clamp(_viewport.height - _canvas.height * scale, 0.0);
    _transform.value = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _handleTap(Offset position, List<VehicleModel> vehicles) {
    final points = [
      for (final v in vehicles) IstanbulGeo.normalize(v.latitude, v.longitude),
    ];
    final index = VehicleMarkerPainter.markerIndexAt(
      position,
      _canvas,
      points,
      _transform.value.getMaxScaleOnAxis(),
    );
    widget.onVehicleTap(index == null ? null : vehicles[index]);
  }

  void _layout(BoxConstraints constraints) {
    _viewport = constraints.biggest;
    final base = _viewport.width > _viewport.height * IstanbulGeo.aspectRatio
        ? _viewport.width
        : _viewport.height * IstanbulGeo.aspectRatio;
    final width = base * _overscan;
    _canvas = Size(width, width / IstanbulGeo.aspectRatio);
    if (!_centered) {
      _centered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _centerOnUser());
    }
  }

  double get _minScale {
    final byWidth = _viewport.width / _canvas.width;
    final byHeight = _viewport.height / _canvas.height;
    return byWidth > byHeight ? byWidth : byHeight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _layout(constraints);
        return Stack(
          children: [
            InteractiveViewer(
              transformationController: _transform,
              constrained: false,
              minScale: _minScale,
              maxScale: _maxScale,
              boundaryMargin: EdgeInsets.zero,
              child: SizedBox.fromSize(
                size: _canvas,
                child: _MapLayers(
                  controller: widget.controller,
                  transform: _transform,
                  onTap: _handleTap,
                  onMarkerSelect: widget.onVehicleTap,
                ),
              ),
            ),
            _RecenterButton(onPressed: _centerOnUser),
          ],
        );
      },
    );
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      top: MediaQuery.paddingOf(context).top + 72,
      child: Semantics(
        button: true,
        label: context.tr('map_recenter'),
        child: IconButton.filledTonal(
          tooltip: context.tr('map_recenter'),
          onPressed: onPressed,
          icon: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}

class _MapLayers extends StatelessWidget {
  const _MapLayers({
    required this.controller,
    required this.transform,
    required this.onTap,
    required this.onMarkerSelect,
  });

  final RentalMapController controller;
  final TransformationController transform;
  final void Function(Offset position, List<VehicleModel> vehicles) onTap;
  final ValueChanged<VehicleModel?> onMarkerSelect;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ValueListenableBuilder<List<VehicleModel>>(
      valueListenable: controller.available,
      builder: (context, vehicles, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => onTap(d.localPosition, vehicles),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: IstanbulMapPainter(
                    palette: MapPalette.of(brightness),
                    labels: _labels(context),
                  ),
                ),
              ),
              _MarkerLayer(
                controller: controller,
                transform: transform,
                vehicles: vehicles,
                onMarkerSelect: onMarkerSelect,
              ),
            ],
          ),
        );
      },
    );
  }

  List<MapLabel> _labels(BuildContext context) => [
        const MapLabel(text: 'Fatih', lat: 41.0165, lon: 28.935),
        const MapLabel(text: 'Beyoğlu', lat: 41.0395, lon: 28.971),
        const MapLabel(text: 'Şişli', lat: 41.0765, lon: 28.975),
        const MapLabel(text: 'Beşiktaş', lat: 41.0555, lon: 29.0),
        const MapLabel(text: 'Üsküdar', lat: 41.014, lon: 29.0315),
        const MapLabel(text: 'Kadıköy', lat: 40.9845, lon: 29.047),
        const MapLabel(text: 'Ümraniye', lat: 41.0850, lon: 29.095),
        MapLabel(
            text: context.tr('map_bosphorus'),
            lat: 41.066,
            lon: 29.0525,
            isWater: true),
        MapLabel(
            text: context.tr('map_marmara'),
            lat: 40.963,
            lon: 28.955,
            isWater: true),
        MapLabel(
            text: context.tr('map_golden_horn'),
            lat: 41.046,
            lon: 28.9415,
            isWater: true),
      ];
}

class _MarkerLayer extends StatelessWidget {
  const _MarkerLayer({
    required this.controller,
    required this.transform,
    required this.vehicles,
    required this.onMarkerSelect,
  });

  final RentalMapController controller;
  final TransformationController transform;
  final List<VehicleModel> vehicles;
  final ValueChanged<VehicleModel?> onMarkerSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final points = [
      for (final v in vehicles) IstanbulGeo.normalize(v.latitude, v.longitude),
    ];
    final labels = [
      for (final v in vehicles) '${v.model}, ${v.district}',
    ];
    final user = IstanbulGeo.normalize(
      controller.userLatitude,
      controller.userLongitude,
    );
    return ValueListenableBuilder<VehicleModel?>(
      valueListenable: controller.selected,
      builder: (context, selected, _) {
        final selectedIndex = selected == null
            ? null
            : vehicles.indexWhere((v) => v.id == selected.id);
        return ValueListenableBuilder<Matrix4>(
          valueListenable: transform,
          builder: (context, matrix, _) {
            return CustomPaint(
              painter: VehicleMarkerPainter(
                points: points,
                semanticLabels: labels,
                selectedIndex: selectedIndex == -1 ? null : selectedIndex,
                userPoint: user,
                scale: matrix.getMaxScaleOnAxis(),
                markerColor: scheme.primary,
                selectedColor: scheme.secondary,
                iconColor: scheme.onPrimary,
                ringColor: scheme.surface,
                userColor: AppColors.userLocation,
                onMarkerTap: (i) => onMarkerSelect(vehicles[i]),
              ),
            );
          },
        );
      },
    );
  }
}
