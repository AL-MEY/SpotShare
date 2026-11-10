# Thème

Comment le thème fonctionne dans Flutter en général, puis comment il est construit dans SpotShare. Les règles d'usage dans les widgets sont dans [ui-guidelines.md](ui-guidelines.md).

## Le thème dans Flutter

### `ThemeData`, transmis par l'arbre

Un thème Flutter est un objet `ThemeData` passé à `MaterialApp`. `MaterialApp` le place dans l'arbre avec un widget `Theme`, qui est un `InheritedWidget` : n'importe quel widget en dessous le lit avec `Theme.of(context)`.

Lire le thème via `context` a deux effets :

- les widgets n'ont pas besoin qu'on leur passe les couleurs ou les tailles ;
- un widget qui a lu le thème est reconstruit automatiquement quand le thème change, par exemple au passage clair → sombre.

### Clair et sombre

`MaterialApp` reçoit deux thèmes, `theme` (clair) et `darkTheme` (sombre), et choisit selon `themeMode`. La valeur par défaut, `ThemeMode.system`, suit le réglage du téléphone. Au changement, Flutter anime la transition en interpolant chaque valeur entre les deux thèmes (méthode `lerp`).

### Ce que contient `ThemeData`

| Partie | Rôle |
|---|---|
| `colorScheme` | Les **rôles de couleur** Material 3 : `primary`, `onPrimary`, `surface`, `onSurface`, `outline`, `error`… Chaque widget Material sait quel rôle utiliser : un `FilledButton` prend `primary` pour son fond et `onPrimary` pour son texte. |
| `textTheme` | Les **rôles typographiques** : `headlineLarge`, `titleMedium`, `bodyMedium`, `labelLarge`… Un `AppBar` utilise `titleLarge`, un bouton `labelLarge`, un `Text` sans style `bodyMedium`. |
| `fontFamily`, `scaffoldBackgroundColor`… | Réglages globaux. |
| `xxxTheme` (`filledButtonTheme`, `inputDecorationTheme`…) | Personnalisation fine d'un type de widget. |
| `extensions` | Valeurs **propres à l'app**, que Material ne prévoit pas. |

L'intérêt de bien remplir `colorScheme` et `textTheme` : les widgets Material prennent la bonne apparence sans aucun style écrit à la main.

### `ThemeExtension` : ajouter ses propres tokens

Material ne connaît ni « espacement M », ni « couleur de fond de carte », ni « ombre flottante ». Pour les ranger dans le thème, Flutter propose `ThemeExtension<T>` : une classe à soi, enregistrée dans `ThemeData.extensions` et relue avec `Theme.of(context).extension<T>()`.

Une `ThemeExtension` doit implémenter deux méthodes :

- `copyWith` : créer une variante en changeant quelques champs ;
- `lerp` : interpoler entre deux instances, pour l'animation clair ↔ sombre.

Pour une classe de vingt couleurs, c'est beaucoup de code répétitif à écrire et à maintenir.

### theme_tailor : générer ce code

[theme_tailor](https://pub.dev/packages/theme_tailor) génère ce code répétitif. On écrit une classe annotée avec `@TailorMixin()` qui ne contient que ses champs, et `build_runner` produit dans `app_theme.tailor.dart` un mixin avec `copyWith`, `lerp`, `==` et `hashCode`.

Avec `themeGetter: ThemeGetter.onBuildContext`, il génère aussi un raccourci : `context.appTheme` au lieu de `Theme.of(context).extension<AppTheme>()!`.

Le fichier `*.tailor.dart` est généré : il ne s'édite jamais à la main. On le régénère avec `./scripts/generate_theme_and_i18n.sh`.

## Dans SpotShare

### Les fichiers

| Fichier | Contenu |
|---|---|
| `lib/core/theme/app_theme.dart` | La **forme** du thème : les classes theme_tailor et leurs champs, sans aucune valeur. |
| `lib/core/theme/app_theme_impl.dart` | Les **valeurs** : primitives, instances claire et sombre, construction des `ThemeData`. |
| `lib/core/theme/app_theme.tailor.dart` | Code généré par theme_tailor. |
| `assets/fonts/` | Instrument Sans (graisses 400, 500 et 600) et sa licence OFL. |

Séparer la forme des valeurs suit la même logique que gota-app : on peut changer une couleur sans toucher aux classes, et ajouter un token sans toucher aux widgets.

### `AppTheme` : une seule extension racine

Une seule `ThemeExtension` est enregistrée : `AppTheme`. Elle regroupe des sous-thèmes, un par famille de tokens.

| Champ | Classe | Contenu | Varie entre clair et sombre |
|---|---|---|---|
| `colors` | `AppColorsTheme` | Alias de couleur fonctionnels | oui |
| `textStyles` | `AppTextStylesTheme` | `h1`–`h3`, `b1`–`b3`, `l1` | non |
| `spacing` | `AppSpacingTheme` | `spacing3xs` → `spacing4xl` (2 à 48) | non |
| `radius` | `AppRadiusTheme` | `none`, `rXs`, `rS`, `rM`, `full` | non |
| `stroke` | `AppStrokeTheme` | `strokeS`, `strokeM`, `strokeL` | non |
| `shadows` | `AppShadowsTheme` | `float`, `focusRing` | oui |
| `opacity` | `AppOpacityTheme` | calques d'état et désactivé | non |

Un seul point d'accès, `context.appTheme`, et les sous-thèmes ont `themeGetter: ThemeGetter.none` : ils ne sont pas enregistrés séparément, donc un raccourci `context.spacing` planterait.

```dart
final theme = context.appTheme;

Padding(
  padding: EdgeInsets.all(theme.spacing.spacingM),
  child: Text(spot.name, style: theme.textStyles.h2),
);
```

### Couleurs : primitives et alias

Le design system a deux couches de couleurs :

- **Primitives** (`neutral100` à `neutral1200`, `brand100` à `brand300`, `error100`, `error200`, `neutralAlpha*`) : des gammes sans signification. Elles sont **privées**, dans la classe `_Palette` de l'impl.
- **Alias fonctionnels** (`background`, `surface`, `foreground`, `action`, `accent`, `border`…) : ce qu'une couleur *veut dire*. Ce sont les seuls champs de `AppColorsTheme`, donc les seuls accessibles aux widgets.

Un widget écrit `colors.foreground`, jamais « le neutre 1100 ». En sombre, `foreground` pointe vers une autre primitive : le widget n'a rien à gérer, et l'accessibilité (les contrastes) se règle à un seul endroit.

Deux alias nomment des primitives utilisées directement sur les photos : `mediaButton` (`neutralAlpha30`) et `mediaLabel` (`neutralAlpha40`).

### Correspondance avec Material 3

Dans `_buildTheme`, les alias sont recopiés dans les rôles du `ColorScheme`, et les styles dans les rôles du `TextTheme`. Les widgets Material suivent ainsi le design system sans configuration.

| Alias | Rôle `ColorScheme` |
|---|---|
| `action`, `onAction` | `primary`, `onPrimary` (et `secondary` : le design est monochrome) |
| `accent`, `onAccent` | `tertiary`, `onTertiary` |
| `background` | `surface`, `surfaceContainerLowest` |
| `surface` | `surfaceContainerLow`, `surfaceContainer` |
| `surfaceMuted` | `surfaceContainerHigh`, `surfaceContainerHighest` |
| `foreground`, `foregroundMuted` | `onSurface`, `onSurfaceVariant` |
| `border`, `borderSubtle` | `outline`, `outlineVariant` |
| `error` | `error` |
| `inverse`, `onInverse` | `inverseSurface`, `onInverseSurface` |

| Style | Rôle `TextTheme` |
|---|---|
| `h1` | `headlineLarge` |
| `h2` | `titleLarge` |
| `h3` | `titleMedium` |
| `b1`, `b2`, `b3` | `bodyLarge`, `bodyMedium`, `bodySmall` |
| `l1` | `labelLarge` |

Le design n'utilise pas les rôles M3 restants (`display*`, `headlineSmall`, `labelSmall`…). Ils gardent leurs valeurs Material par défaut, mais avec la police de l'app.

Le test `test/core/theme/app_theme_impl_test.dart` vérifie cette correspondance pour les deux thèmes.

### Typographie

- Une seule famille, Instrument Sans, déclarée dans `pubspec.yaml` sous le nom `InstrumentSans`. Elle est aussi posée en `fontFamily` du `ThemeData`, pour que les widgets Material l'utilisent.
- Les fichiers sont embarqués dans l'app plutôt que chargés par le réseau (`google_fonts`) : la police marche hors ligne, une exigence du projet.
- Seules les graisses du design system sont embarquées : 400, 500 et 600. Demander une autre graisse donnerait une graisse simulée par le moteur de rendu.
- Conversion depuis les tokens : `height = lineHeight / fontSize` (Flutter attend un multiplicateur), et `letterSpacing` en px `= em × fontSize` (par exemple `-0.02em × 32 = -0.64`).
- Chiffres tabulaires partout (`FontFeature.tabularFigures()`), pour que les compteurs et les distances ne « sautent » pas en changeant de valeur.
- Les styles n'ont pas de couleur : elle vient du contexte (`foreground` par défaut via le `TextTheme`), ou se précise avec `copyWith(color: …)`.

### Ombres

Converties depuis la syntaxe CSS des tokens (`x y flou étalement couleur`) en `BoxShadow`. Le design en utilise très peu : la séparation entre éléments vient des surfaces.

- `float` : deux ombres superposées, pour ce qui flotte (bottom sheet, bouton flottant, marqueur sélectionné).
- `focusRing` : deux anneaux pleins, 2 px de fond puis 2 px d'encre. En CSS, la première ombre listée est dessinée au-dessus. Flutter dessine dans l'ordre de la liste, donc l'ordre est inversé dans le code.

À l'animation clair ↔ sombre, theme_tailor ne sait pas interpoler une liste d'ombres : elle bascule d'un coup à mi-transition, sans effet visible.

### Opacités

Les calques d'état (`stateHover`, `statePressed`…) ont les mêmes valeurs que Material 3, donc les widgets Material les appliquent déjà. Les tokens servent aux widgets dessinés à la main, pour garder les mêmes valeurs.

## Faire évoluer le thème

**Changer une valeur** (une couleur, une taille) : la modifier dans `app_theme_impl.dart`. Pas de génération à relancer, puisque la forme des classes ne change pas.

**Ajouter un token** :

1. Ajouter le champ dans la bonne classe de `app_theme.dart`.
2. Donner sa valeur dans `app_theme_impl.dart`, en clair et en sombre si c'est une couleur.
3. Lancer `./scripts/generate_theme_and_i18n.sh`.
4. Si c'est un alias de couleur qui correspond à un rôle Material, le brancher dans `_colorScheme` et compléter le test.

**Ajouter une famille de tokens** (par exemple des durées d'animation) : une nouvelle classe `@TailorMixin(themeGetter: ThemeGetter.none)` dans `app_theme.dart`, un champ dans `AppTheme`, puis ses valeurs dans l'impl.
