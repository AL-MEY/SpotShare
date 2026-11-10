# UI et widgets

## Découpage de l'arbre

- Toute méthode `build()` de plus de 80 lignes est découpée en widgets dédiés (critère éliminatoire de la grille).
- Extraire en **classes** `StatelessWidget`, pas en méthodes `_buildXxx()` : les classes permettent `const` et des rebuilds isolés.
- `StatelessWidget` / `ConsumerWidget` par défaut. `StatefulWidget` seulement pour un état visuel local (contrôleurs d'animation, de texte, de scroll).
- `const` sur tout constructeur et tout sous-arbre statique. L'analyseur le signale (`prefer_const_constructors`).

## Thème Material 3

- `useMaterial3: true`, `ThemeData` clair **et** sombre définis dans `core/theme/`, générés depuis un `ColorScheme.fromSeed`.
- Aucune couleur ni taille de texte en dur dans les widgets : `Theme.of(context).colorScheme` et `textTheme`.
- Tokens hors Material (espacements, rayons, couleurs `success`/`warning`/`rating`) : `context.appTheme`, défini dans `core/theme/app_theme.dart` (theme_tailor) et instancié dans `app_theme_impl.dart`. Nouveau token = champ dans la classe + valeur dans l'impl + `./scripts/generate_theme_and_i18n.sh`.
- Respecter les zones sécurisées : `SafeArea` sur chaque page (ou `Scaffold` qui la gère correctement).

## Responsive

- Layout adaptatif téléphone et tablette via `LayoutBuilder`, `OrientationBuilder` ou `MediaQuery.sizeOf(context)`.
- Breakpoints centralisés dans `core/` (ex. compact < 600, medium < 840, expanded ≥ 840).
- Tester au moins un écran clé en largeur tablette.

## Animations et fluidité

- Transitions `Hero` entre une carte du feed / de la carte et la fiche détaillée (même `tag` unique, ex. `spot-image-$id`).
- `AnimatedSwitcher` pour les transitions d'état (loading → data, favori on/off).
- Objectif 60/120 fps : listes avec `ListView.builder` / `PageView.builder`, pas de travail lourd dans `build`, pas de rebuild global.

## Images

- `CachedNetworkImage` pour toute image distante, avec `memCacheWidth`/`memCacheHeight` adaptés à la taille affichée et un placeholder.

## Localisation FR / EN

- slang : clés dans `lib/i18n/fr.i18n.yaml` (langue de base) et `en.i18n.yaml`, config dans `build.yaml`, génération via `./scripts/generate_theme_and_i18n.sh` (fichiers `strings*.g.dart` versionnés, jamais édités à la main).
- Accès dans un widget : `context.t.home.welcome` (import `package:spotshare/i18n/strings.g.dart`).
- Aucun texte visible en dur : toujours une clé, ajoutée dans **les deux** fichiers.
- La langue choisie par l'utilisateur est persistée localement et restaurée au démarrage.

## Accessibilité

- Cibles tactiles ≥ 48 dp, `Semantics`/`tooltip` sur les boutons icônes, contrastes conformes en clair et sombre.
