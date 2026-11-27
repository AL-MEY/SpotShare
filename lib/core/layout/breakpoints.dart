enum WindowSize {
  compact,
  medium,
  expanded;

  static const compactMaxWidth = 600.0;
  static const mediumMaxWidth = 840.0;

  static WindowSize fromWidth(double width) {
    if (width < compactMaxWidth) return compact;
    if (width < mediumMaxWidth) return medium;
    return expanded;
  }
}
