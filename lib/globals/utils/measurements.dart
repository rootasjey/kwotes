import "package:flutter/widgets.dart";

class Measurements {
  const Measurements();

  /// Width limit between mobile & desktop screen size.
  final double mobileWidthTreshold = 700.0;

  /// Return true if the app's window is equal or less than the maximum
  /// mobile width.
  bool isMobileSize(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double pageWidth = size.width;
    return pageWidth <= mobileWidthTreshold;
  }
}
