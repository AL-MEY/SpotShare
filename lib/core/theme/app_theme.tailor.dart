// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_theme.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppThemeTailorMixin on ThemeExtension<AppTheme> {
  AppColorsTheme get colors;
  AppSpacingTheme get spacing;
  AppRadiusTheme get radius;

  @override
  AppTheme copyWith({
    AppColorsTheme? colors,
    AppSpacingTheme? spacing,
    AppRadiusTheme? radius,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
    );
  }

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this as AppTheme;
    return AppTheme(
      colors: colors.lerp(other.colors, t),
      spacing: spacing.lerp(other.spacing, t),
      radius: radius.lerp(other.radius, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppTheme &&
            const DeepCollectionEquality().equals(colors, other.colors) &&
            const DeepCollectionEquality().equals(spacing, other.spacing) &&
            const DeepCollectionEquality().equals(radius, other.radius));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(colors),
      const DeepCollectionEquality().hash(spacing),
      const DeepCollectionEquality().hash(radius),
    );
  }
}

extension AppThemeBuildContext on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;
}

mixin _$AppColorsThemeTailorMixin on ThemeExtension<AppColorsTheme> {
  Color get success;
  Color get warning;
  Color get rating;

  @override
  AppColorsTheme copyWith({Color? success, Color? warning, Color? rating}) {
    return AppColorsTheme(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      rating: rating ?? this.rating,
    );
  }

  @override
  AppColorsTheme lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsTheme) return this as AppColorsTheme;
    return AppColorsTheme(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppColorsTheme &&
            const DeepCollectionEquality().equals(success, other.success) &&
            const DeepCollectionEquality().equals(warning, other.warning) &&
            const DeepCollectionEquality().equals(rating, other.rating));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(success),
      const DeepCollectionEquality().hash(warning),
      const DeepCollectionEquality().hash(rating),
    );
  }
}

mixin _$AppSpacingThemeTailorMixin on ThemeExtension<AppSpacingTheme> {
  double get xs;
  double get s;
  double get m;
  double get l;
  double get xl;

  @override
  AppSpacingTheme copyWith({
    double? xs,
    double? s,
    double? m,
    double? l,
    double? xl,
  }) {
    return AppSpacingTheme(
      xs: xs ?? this.xs,
      s: s ?? this.s,
      m: m ?? this.m,
      l: l ?? this.l,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacingTheme lerp(
    covariant ThemeExtension<AppSpacingTheme>? other,
    double t,
  ) {
    if (other is! AppSpacingTheme) return this as AppSpacingTheme;
    return AppSpacingTheme(
      xs: t < 0.5 ? xs : other.xs,
      s: t < 0.5 ? s : other.s,
      m: t < 0.5 ? m : other.m,
      l: t < 0.5 ? l : other.l,
      xl: t < 0.5 ? xl : other.xl,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppSpacingTheme &&
            const DeepCollectionEquality().equals(xs, other.xs) &&
            const DeepCollectionEquality().equals(s, other.s) &&
            const DeepCollectionEquality().equals(m, other.m) &&
            const DeepCollectionEquality().equals(l, other.l) &&
            const DeepCollectionEquality().equals(xl, other.xl));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(xs),
      const DeepCollectionEquality().hash(s),
      const DeepCollectionEquality().hash(m),
      const DeepCollectionEquality().hash(l),
      const DeepCollectionEquality().hash(xl),
    );
  }
}

mixin _$AppRadiusThemeTailorMixin on ThemeExtension<AppRadiusTheme> {
  double get s;
  double get m;
  double get l;
  double get full;

  @override
  AppRadiusTheme copyWith({double? s, double? m, double? l, double? full}) {
    return AppRadiusTheme(
      s: s ?? this.s,
      m: m ?? this.m,
      l: l ?? this.l,
      full: full ?? this.full,
    );
  }

  @override
  AppRadiusTheme lerp(
    covariant ThemeExtension<AppRadiusTheme>? other,
    double t,
  ) {
    if (other is! AppRadiusTheme) return this as AppRadiusTheme;
    return AppRadiusTheme(
      s: t < 0.5 ? s : other.s,
      m: t < 0.5 ? m : other.m,
      l: t < 0.5 ? l : other.l,
      full: t < 0.5 ? full : other.full,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppRadiusTheme &&
            const DeepCollectionEquality().equals(s, other.s) &&
            const DeepCollectionEquality().equals(m, other.m) &&
            const DeepCollectionEquality().equals(l, other.l) &&
            const DeepCollectionEquality().equals(full, other.full));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(s),
      const DeepCollectionEquality().hash(m),
      const DeepCollectionEquality().hash(l),
      const DeepCollectionEquality().hash(full),
    );
  }
}
