import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenType.mobile;
    if (width < 1200) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getScreenType(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenType(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenType(context) == ScreenType.desktop;

  static double contentMaxWidth(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 800;
      case ScreenType.desktop:
        return 1000;
    }
  }

  static double headerFontSize(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 56;
      case ScreenType.tablet:
        return 64;
      case ScreenType.desktop:
        return 72;
    }
  }

  static double bodyFontSize(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return 14;
      case ScreenType.tablet:
        return 15;
      case ScreenType.desktop:
        return 16;
    }
  }

  static EdgeInsets pagePadding(BuildContext context) {
    switch (getScreenType(context)) {
      case ScreenType.mobile:
        return const EdgeInsets.all(12);
      case ScreenType.tablet:
        return const EdgeInsets.all(20);
      case ScreenType.desktop:
        return const EdgeInsets.all(24);
    }
  }
}
