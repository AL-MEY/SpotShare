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
  AppTextStylesTheme get textStyles;
  AppSpacingTheme get spacing;
  AppRadiusTheme get radius;
  AppStrokeTheme get stroke;
  AppShadowsTheme get shadows;
  AppOpacityTheme get opacity;

  @override
  AppTheme copyWith({
    AppColorsTheme? colors,
    AppTextStylesTheme? textStyles,
    AppSpacingTheme? spacing,
    AppRadiusTheme? radius,
    AppStrokeTheme? stroke,
    AppShadowsTheme? shadows,
    AppOpacityTheme? opacity,
  }) {
    return AppTheme(
      colors: colors ?? this.colors,
      textStyles: textStyles ?? this.textStyles,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      stroke: stroke ?? this.stroke,
      shadows: shadows ?? this.shadows,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  AppTheme lerp(covariant ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this as AppTheme;
    return AppTheme(
      colors: colors.lerp(other.colors, t),
      textStyles: textStyles.lerp(other.textStyles, t),
      spacing: spacing.lerp(other.spacing, t),
      radius: radius.lerp(other.radius, t),
      stroke: stroke.lerp(other.stroke, t),
      shadows: shadows.lerp(other.shadows, t),
      opacity: opacity.lerp(other.opacity, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppTheme &&
            const DeepCollectionEquality().equals(colors, other.colors) &&
            const DeepCollectionEquality().equals(
              textStyles,
              other.textStyles,
            ) &&
            const DeepCollectionEquality().equals(spacing, other.spacing) &&
            const DeepCollectionEquality().equals(radius, other.radius) &&
            const DeepCollectionEquality().equals(stroke, other.stroke) &&
            const DeepCollectionEquality().equals(shadows, other.shadows) &&
            const DeepCollectionEquality().equals(opacity, other.opacity));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(colors),
      const DeepCollectionEquality().hash(textStyles),
      const DeepCollectionEquality().hash(spacing),
      const DeepCollectionEquality().hash(radius),
      const DeepCollectionEquality().hash(stroke),
      const DeepCollectionEquality().hash(shadows),
      const DeepCollectionEquality().hash(opacity),
    );
  }
}

extension AppThemeBuildContext on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;
}

mixin _$AppColorsThemeTailorMixin on ThemeExtension<AppColorsTheme> {
  Color get background;
  Color get surface;
  Color get surfaceMuted;
  Color get foreground;
  Color get foregroundMuted;
  Color get border;
  Color get borderSubtle;
  Color get action;
  Color get onAction;
  Color get accent;
  Color get onAccent;
  Color get error;
  Color get focus;
  Color get inverse;
  Color get onInverse;
  Color get scrim;
  Color get onMedia;
  Color get mediaButton;
  Color get mediaLabel;
  Color get mapLand;
  Color get mapRoad;
  Color get mapPark;

  @override
  AppColorsTheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? foreground,
    Color? foregroundMuted,
    Color? border,
    Color? borderSubtle,
    Color? action,
    Color? onAction,
    Color? accent,
    Color? onAccent,
    Color? error,
    Color? focus,
    Color? inverse,
    Color? onInverse,
    Color? scrim,
    Color? onMedia,
    Color? mediaButton,
    Color? mediaLabel,
    Color? mapLand,
    Color? mapRoad,
    Color? mapPark,
  }) {
    return AppColorsTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      foreground: foreground ?? this.foreground,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      error: error ?? this.error,
      focus: focus ?? this.focus,
      inverse: inverse ?? this.inverse,
      onInverse: onInverse ?? this.onInverse,
      scrim: scrim ?? this.scrim,
      onMedia: onMedia ?? this.onMedia,
      mediaButton: mediaButton ?? this.mediaButton,
      mediaLabel: mediaLabel ?? this.mediaLabel,
      mapLand: mapLand ?? this.mapLand,
      mapRoad: mapRoad ?? this.mapRoad,
      mapPark: mapPark ?? this.mapPark,
    );
  }

  @override
  AppColorsTheme lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsTheme) return this as AppColorsTheme;
    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      foregroundMuted: Color.lerp(foregroundMuted, other.foregroundMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      error: Color.lerp(error, other.error, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      inverse: Color.lerp(inverse, other.inverse, t)!,
      onInverse: Color.lerp(onInverse, other.onInverse, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      onMedia: Color.lerp(onMedia, other.onMedia, t)!,
      mediaButton: Color.lerp(mediaButton, other.mediaButton, t)!,
      mediaLabel: Color.lerp(mediaLabel, other.mediaLabel, t)!,
      mapLand: Color.lerp(mapLand, other.mapLand, t)!,
      mapRoad: Color.lerp(mapRoad, other.mapRoad, t)!,
      mapPark: Color.lerp(mapPark, other.mapPark, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppColorsTheme &&
            const DeepCollectionEquality().equals(
              background,
              other.background,
            ) &&
            const DeepCollectionEquality().equals(surface, other.surface) &&
            const DeepCollectionEquality().equals(
              surfaceMuted,
              other.surfaceMuted,
            ) &&
            const DeepCollectionEquality().equals(
              foreground,
              other.foreground,
            ) &&
            const DeepCollectionEquality().equals(
              foregroundMuted,
              other.foregroundMuted,
            ) &&
            const DeepCollectionEquality().equals(border, other.border) &&
            const DeepCollectionEquality().equals(
              borderSubtle,
              other.borderSubtle,
            ) &&
            const DeepCollectionEquality().equals(action, other.action) &&
            const DeepCollectionEquality().equals(onAction, other.onAction) &&
            const DeepCollectionEquality().equals(accent, other.accent) &&
            const DeepCollectionEquality().equals(onAccent, other.onAccent) &&
            const DeepCollectionEquality().equals(error, other.error) &&
            const DeepCollectionEquality().equals(focus, other.focus) &&
            const DeepCollectionEquality().equals(inverse, other.inverse) &&
            const DeepCollectionEquality().equals(onInverse, other.onInverse) &&
            const DeepCollectionEquality().equals(scrim, other.scrim) &&
            const DeepCollectionEquality().equals(onMedia, other.onMedia) &&
            const DeepCollectionEquality().equals(
              mediaButton,
              other.mediaButton,
            ) &&
            const DeepCollectionEquality().equals(
              mediaLabel,
              other.mediaLabel,
            ) &&
            const DeepCollectionEquality().equals(mapLand, other.mapLand) &&
            const DeepCollectionEquality().equals(mapRoad, other.mapRoad) &&
            const DeepCollectionEquality().equals(mapPark, other.mapPark));
  }

  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(background),
      const DeepCollectionEquality().hash(surface),
      const DeepCollectionEquality().hash(surfaceMuted),
      const DeepCollectionEquality().hash(foreground),
      const DeepCollectionEquality().hash(foregroundMuted),
      const DeepCollectionEquality().hash(border),
      const DeepCollectionEquality().hash(borderSubtle),
      const DeepCollectionEquality().hash(action),
      const DeepCollectionEquality().hash(onAction),
      const DeepCollectionEquality().hash(accent),
      const DeepCollectionEquality().hash(onAccent),
      const DeepCollectionEquality().hash(error),
      const DeepCollectionEquality().hash(focus),
      const DeepCollectionEquality().hash(inverse),
      const DeepCollectionEquality().hash(onInverse),
      const DeepCollectionEquality().hash(scrim),
      const DeepCollectionEquality().hash(onMedia),
      const DeepCollectionEquality().hash(mediaButton),
      const DeepCollectionEquality().hash(mediaLabel),
      const DeepCollectionEquality().hash(mapLand),
      const DeepCollectionEquality().hash(mapRoad),
      const DeepCollectionEquality().hash(mapPark),
    ]);
  }
}

mixin _$AppTextStylesThemeTailorMixin on ThemeExtension<AppTextStylesTheme> {
  TextStyle get h1;
  TextStyle get h2;
  TextStyle get h3;
  TextStyle get b1;
  TextStyle get b2;
  TextStyle get b3;
  TextStyle get l1;

  @override
  AppTextStylesTheme copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? b1,
    TextStyle? b2,
    TextStyle? b3,
    TextStyle? l1,
  }) {
    return AppTextStylesTheme(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      b1: b1 ?? this.b1,
      b2: b2 ?? this.b2,
      b3: b3 ?? this.b3,
      l1: l1 ?? this.l1,
    );
  }

  @override
  AppTextStylesTheme lerp(
    covariant ThemeExtension<AppTextStylesTheme>? other,
    double t,
  ) {
    if (other is! AppTextStylesTheme) return this as AppTextStylesTheme;
    return AppTextStylesTheme(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      b1: TextStyle.lerp(b1, other.b1, t)!,
      b2: TextStyle.lerp(b2, other.b2, t)!,
      b3: TextStyle.lerp(b3, other.b3, t)!,
      l1: TextStyle.lerp(l1, other.l1, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppTextStylesTheme &&
            const DeepCollectionEquality().equals(h1, other.h1) &&
            const DeepCollectionEquality().equals(h2, other.h2) &&
            const DeepCollectionEquality().equals(h3, other.h3) &&
            const DeepCollectionEquality().equals(b1, other.b1) &&
            const DeepCollectionEquality().equals(b2, other.b2) &&
            const DeepCollectionEquality().equals(b3, other.b3) &&
            const DeepCollectionEquality().equals(l1, other.l1));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(h1),
      const DeepCollectionEquality().hash(h2),
      const DeepCollectionEquality().hash(h3),
      const DeepCollectionEquality().hash(b1),
      const DeepCollectionEquality().hash(b2),
      const DeepCollectionEquality().hash(b3),
      const DeepCollectionEquality().hash(l1),
    );
  }
}

mixin _$AppSpacingThemeTailorMixin on ThemeExtension<AppSpacingTheme> {
  double get spacing3xs;
  double get spacing2xs;
  double get spacingXs;
  double get spacingS;
  double get spacingM;
  double get spacingL;
  double get spacingXl;
  double get spacing2xl;
  double get spacing3xl;
  double get spacing4xl;

  @override
  AppSpacingTheme copyWith({
    double? spacing3xs,
    double? spacing2xs,
    double? spacingXs,
    double? spacingS,
    double? spacingM,
    double? spacingL,
    double? spacingXl,
    double? spacing2xl,
    double? spacing3xl,
    double? spacing4xl,
  }) {
    return AppSpacingTheme(
      spacing3xs: spacing3xs ?? this.spacing3xs,
      spacing2xs: spacing2xs ?? this.spacing2xs,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingS: spacingS ?? this.spacingS,
      spacingM: spacingM ?? this.spacingM,
      spacingL: spacingL ?? this.spacingL,
      spacingXl: spacingXl ?? this.spacingXl,
      spacing2xl: spacing2xl ?? this.spacing2xl,
      spacing3xl: spacing3xl ?? this.spacing3xl,
      spacing4xl: spacing4xl ?? this.spacing4xl,
    );
  }

  @override
  AppSpacingTheme lerp(
    covariant ThemeExtension<AppSpacingTheme>? other,
    double t,
  ) {
    if (other is! AppSpacingTheme) return this as AppSpacingTheme;
    return AppSpacingTheme(
      spacing3xs: t < 0.5 ? spacing3xs : other.spacing3xs,
      spacing2xs: t < 0.5 ? spacing2xs : other.spacing2xs,
      spacingXs: t < 0.5 ? spacingXs : other.spacingXs,
      spacingS: t < 0.5 ? spacingS : other.spacingS,
      spacingM: t < 0.5 ? spacingM : other.spacingM,
      spacingL: t < 0.5 ? spacingL : other.spacingL,
      spacingXl: t < 0.5 ? spacingXl : other.spacingXl,
      spacing2xl: t < 0.5 ? spacing2xl : other.spacing2xl,
      spacing3xl: t < 0.5 ? spacing3xl : other.spacing3xl,
      spacing4xl: t < 0.5 ? spacing4xl : other.spacing4xl,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppSpacingTheme &&
            const DeepCollectionEquality().equals(
              spacing3xs,
              other.spacing3xs,
            ) &&
            const DeepCollectionEquality().equals(
              spacing2xs,
              other.spacing2xs,
            ) &&
            const DeepCollectionEquality().equals(spacingXs, other.spacingXs) &&
            const DeepCollectionEquality().equals(spacingS, other.spacingS) &&
            const DeepCollectionEquality().equals(spacingM, other.spacingM) &&
            const DeepCollectionEquality().equals(spacingL, other.spacingL) &&
            const DeepCollectionEquality().equals(spacingXl, other.spacingXl) &&
            const DeepCollectionEquality().equals(
              spacing2xl,
              other.spacing2xl,
            ) &&
            const DeepCollectionEquality().equals(
              spacing3xl,
              other.spacing3xl,
            ) &&
            const DeepCollectionEquality().equals(
              spacing4xl,
              other.spacing4xl,
            ));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(spacing3xs),
      const DeepCollectionEquality().hash(spacing2xs),
      const DeepCollectionEquality().hash(spacingXs),
      const DeepCollectionEquality().hash(spacingS),
      const DeepCollectionEquality().hash(spacingM),
      const DeepCollectionEquality().hash(spacingL),
      const DeepCollectionEquality().hash(spacingXl),
      const DeepCollectionEquality().hash(spacing2xl),
      const DeepCollectionEquality().hash(spacing3xl),
      const DeepCollectionEquality().hash(spacing4xl),
    );
  }
}

mixin _$AppRadiusThemeTailorMixin on ThemeExtension<AppRadiusTheme> {
  double get none;
  double get rXs;
  double get rS;
  double get rM;
  double get full;

  @override
  AppRadiusTheme copyWith({
    double? none,
    double? rXs,
    double? rS,
    double? rM,
    double? full,
  }) {
    return AppRadiusTheme(
      none: none ?? this.none,
      rXs: rXs ?? this.rXs,
      rS: rS ?? this.rS,
      rM: rM ?? this.rM,
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
      none: t < 0.5 ? none : other.none,
      rXs: t < 0.5 ? rXs : other.rXs,
      rS: t < 0.5 ? rS : other.rS,
      rM: t < 0.5 ? rM : other.rM,
      full: t < 0.5 ? full : other.full,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppRadiusTheme &&
            const DeepCollectionEquality().equals(none, other.none) &&
            const DeepCollectionEquality().equals(rXs, other.rXs) &&
            const DeepCollectionEquality().equals(rS, other.rS) &&
            const DeepCollectionEquality().equals(rM, other.rM) &&
            const DeepCollectionEquality().equals(full, other.full));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(none),
      const DeepCollectionEquality().hash(rXs),
      const DeepCollectionEquality().hash(rS),
      const DeepCollectionEquality().hash(rM),
      const DeepCollectionEquality().hash(full),
    );
  }
}

mixin _$AppStrokeThemeTailorMixin on ThemeExtension<AppStrokeTheme> {
  double get strokeS;
  double get strokeM;
  double get strokeL;

  @override
  AppStrokeTheme copyWith({double? strokeS, double? strokeM, double? strokeL}) {
    return AppStrokeTheme(
      strokeS: strokeS ?? this.strokeS,
      strokeM: strokeM ?? this.strokeM,
      strokeL: strokeL ?? this.strokeL,
    );
  }

  @override
  AppStrokeTheme lerp(
    covariant ThemeExtension<AppStrokeTheme>? other,
    double t,
  ) {
    if (other is! AppStrokeTheme) return this as AppStrokeTheme;
    return AppStrokeTheme(
      strokeS: t < 0.5 ? strokeS : other.strokeS,
      strokeM: t < 0.5 ? strokeM : other.strokeM,
      strokeL: t < 0.5 ? strokeL : other.strokeL,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppStrokeTheme &&
            const DeepCollectionEquality().equals(strokeS, other.strokeS) &&
            const DeepCollectionEquality().equals(strokeM, other.strokeM) &&
            const DeepCollectionEquality().equals(strokeL, other.strokeL));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(strokeS),
      const DeepCollectionEquality().hash(strokeM),
      const DeepCollectionEquality().hash(strokeL),
    );
  }
}

mixin _$AppShadowsThemeTailorMixin on ThemeExtension<AppShadowsTheme> {
  List<BoxShadow> get float;
  List<BoxShadow> get focusRing;

  @override
  AppShadowsTheme copyWith({
    List<BoxShadow>? float,
    List<BoxShadow>? focusRing,
  }) {
    return AppShadowsTheme(
      float: float ?? this.float,
      focusRing: focusRing ?? this.focusRing,
    );
  }

  @override
  AppShadowsTheme lerp(
    covariant ThemeExtension<AppShadowsTheme>? other,
    double t,
  ) {
    if (other is! AppShadowsTheme) return this as AppShadowsTheme;
    return AppShadowsTheme(
      float: t < 0.5 ? float : other.float,
      focusRing: t < 0.5 ? focusRing : other.focusRing,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppShadowsTheme &&
            const DeepCollectionEquality().equals(float, other.float) &&
            const DeepCollectionEquality().equals(focusRing, other.focusRing));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(float),
      const DeepCollectionEquality().hash(focusRing),
    );
  }
}

mixin _$AppOpacityThemeTailorMixin on ThemeExtension<AppOpacityTheme> {
  double get stateHover;
  double get stateFocus;
  double get statePressed;
  double get stateDragged;
  double get disabledContent;
  double get disabledContainer;

  @override
  AppOpacityTheme copyWith({
    double? stateHover,
    double? stateFocus,
    double? statePressed,
    double? stateDragged,
    double? disabledContent,
    double? disabledContainer,
  }) {
    return AppOpacityTheme(
      stateHover: stateHover ?? this.stateHover,
      stateFocus: stateFocus ?? this.stateFocus,
      statePressed: statePressed ?? this.statePressed,
      stateDragged: stateDragged ?? this.stateDragged,
      disabledContent: disabledContent ?? this.disabledContent,
      disabledContainer: disabledContainer ?? this.disabledContainer,
    );
  }

  @override
  AppOpacityTheme lerp(
    covariant ThemeExtension<AppOpacityTheme>? other,
    double t,
  ) {
    if (other is! AppOpacityTheme) return this as AppOpacityTheme;
    return AppOpacityTheme(
      stateHover: t < 0.5 ? stateHover : other.stateHover,
      stateFocus: t < 0.5 ? stateFocus : other.stateFocus,
      statePressed: t < 0.5 ? statePressed : other.statePressed,
      stateDragged: t < 0.5 ? stateDragged : other.stateDragged,
      disabledContent: t < 0.5 ? disabledContent : other.disabledContent,
      disabledContainer: t < 0.5 ? disabledContainer : other.disabledContainer,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppOpacityTheme &&
            const DeepCollectionEquality().equals(
              stateHover,
              other.stateHover,
            ) &&
            const DeepCollectionEquality().equals(
              stateFocus,
              other.stateFocus,
            ) &&
            const DeepCollectionEquality().equals(
              statePressed,
              other.statePressed,
            ) &&
            const DeepCollectionEquality().equals(
              stateDragged,
              other.stateDragged,
            ) &&
            const DeepCollectionEquality().equals(
              disabledContent,
              other.disabledContent,
            ) &&
            const DeepCollectionEquality().equals(
              disabledContainer,
              other.disabledContainer,
            ));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(stateHover),
      const DeepCollectionEquality().hash(stateFocus),
      const DeepCollectionEquality().hash(statePressed),
      const DeepCollectionEquality().hash(stateDragged),
      const DeepCollectionEquality().hash(disabledContent),
      const DeepCollectionEquality().hash(disabledContainer),
    );
  }
}
