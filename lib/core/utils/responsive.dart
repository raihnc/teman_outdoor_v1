import 'package:flutter/material.dart';

/// Ukuran layar berdasarkan lebar (breakpoint umum HP).
enum ScreenSize {
  small, // < 360
  normal, // 360 - 410
  large, // > 410
}

class ScreenInfo {
  final Size size;
  final ScreenSize screenSize;

  ScreenInfo(this.size)
      : screenSize = size.width < 360
            ? ScreenSize.small
            : size.width <= 410
                ? ScreenSize.normal
                : ScreenSize.large;

  double get width => size.width;
  double get height => size.height;
  bool get isSmallPhone => screenSize == ScreenSize.small;
  bool get isLargePhone => screenSize == ScreenSize.large;

  /// Padding horizontal responsif: kecil utk HP sempit, besar utk HP lebar.
  double get pagePadding => switch (screenSize) {
        ScreenSize.small => 12,
        ScreenSize.normal => 16,
        ScreenSize.large => 20,
      };

  /// Skala font/ukuran elemen relatif thd lebar referensi 390px.
  double get scale => (width / 390).clamp(0.85, 1.2);

  /// Jumlah kolom grid produk responsif.
  int get gridColumns => switch (screenSize) {
        ScreenSize.small => 2,
        ScreenSize.normal => 2,
        ScreenSize.large => 3,
      };

  /// Tinggi grid card agar proporsional thd lebar.
  double get gridAspectRatio => switch (screenSize) {
        ScreenSize.small => 0.62,
        ScreenSize.normal => 0.68,
        ScreenSize.large => 0.75,
      };

  double spacing(double base) => base * scale;
}

extension ResponsiveContext on BuildContext {
  ScreenInfo get screen => ScreenInfo(MediaQuery.sizeOf(this));
}

/// Widget pembungkus LayoutBuilder yg menyediakan [ScreenInfo].
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenInfo screen) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, ScreenInfo(constraints.biggest));
      },
    );
  }
}
