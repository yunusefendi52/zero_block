import 'package:flutter/widgets.dart';

extension ColorExtensions on Color {
  Color toLightness(double value) {
    return HSLColor.fromColor(this).withLightness(value).toColor();
  }
}

extension ColorExtensions2 on String {
  Color fromHex() {
    return Color(
      int.parse(substring(1, 7), radix: 16) + 0xFF000000,
    );
  }
}

String removeDecimalZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
}