import 'package:flutter/material.dart';

/// Adaptive responsive layout utilities for all Android screen form factors
/// (compact phones, large phones, foldables, tablets, portrait, landscape).
class ResponsiveLayout {
  ResponsiveLayout._();

  static const double compactPhoneBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  static bool isCompact(BuildContext context) {
    return MediaQuery.of(context).size.width < compactPhoneBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= compactPhoneBreakpoint && width < desktopBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Calculates responsive column counts for gallery cards
  static int getGalleryGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 420) {
      return 2; // Compact phone
    } else if (width < 700) {
      return 2; // Standard / Large phone
    } else if (width < 1000) {
      return 3; // Foldable / Small tablet
    } else {
      return 4; // Large tablet
    }
  }

  /// Calculates adaptive preview height for doll preview areas
  static double getDollPreviewHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > height;

    if (isLandscape) {
      return (height * 0.45).clamp(200.0, 320.0);
    }

    if (width < 360) {
      return 220.0;
    } else if (width < 500) {
      return 270.0;
    } else {
      return 340.0;
    }
  }

  /// Content container max-width wrapper to prevent over-stretching on wide screens
  static Widget constrainedContainer({
    required Widget child,
    double maxWidth = 800,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

