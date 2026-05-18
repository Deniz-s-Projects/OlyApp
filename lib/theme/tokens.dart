/// Design tokens shared across light/dark themes.
///
/// Use these instead of inline `EdgeInsets.all(16)` / `BorderRadius.circular(12)`
/// so that spacing and shape stay coherent app-wide.
library;

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class AppElevation {
  AppElevation._();
  static const double card = 1;
  static const double raised = 2;
  static const double overlay = 4;
}
