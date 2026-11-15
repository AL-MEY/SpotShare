# UI et widgets

## Découpage de l'arbre

- Toute méthode `build()` de plus de 80 lignes est découpée en widgets dédiés (critère éliminatoire de la grille).
- Extraire en **classes** `StatelessWidget`, pas en méthodes `_buildXxx()` : les classes permettent `const` et des rebuilds isolés.
- `StatelessWidget` / `ConsumerWidget` par défaut. `StatefulWidget` seulement pour un état visuel local (contrôleurs d'animation, de texte, de scroll).
- `const` sur tout constructeur et tout sous-arbre statique. L'analyseur le signale (`prefer_const_constructors`).

## Thème Material 3

- Dans un widget, tout passe par `context.appTheme` : `colors`, `textStyles`, `spacing`, `radius`, `stroke`, `shadows`, `opacity`.
- Aucune couleur, taille de texte, marge ou rayon en dur dans un widget.
- `accent` (le vermillon) est réservé au favori, aux marqueurs et au spot sélectionné : jamais sur un bouton d'action, qui utilise `action`.
- Fonctionnement du thème (fichiers, primitives et alias, correspondance Material 3, police) et ajout d'un token : [theme.md](theme.md).
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

- slang : clés dans `lib/i18n/fr.i18n.yaml` (langue de base) et `en.i18n.yaml`, config dans `slang.yaml`, génération via `./scripts/generate_theme_and_i18n.sh` (qui lance `fvm dart run slang`) (fichiers `strings*.g.dart` versionnés, jamais édités à la main).
- Accès dans un widget : `context.t.home.welcome` (import `package:spotshare/i18n/strings.g.dart`).
- Aucun texte visible en dur : toujours une clé, ajoutée dans **les deux** fichiers.
- La langue choisie par l'utilisateur est persistée localement et restaurée au démarrage.

## Navigation

- Toujours `context.go(AppRoutes.xxx)` / `context.push(AppRoutes.xxx)` (go_router), jamais `Navigator.push` vers une page ni de chemin en dur. Détails : [architecture.md](architecture.md#navigation).

## Boutons d'action asynchrone

- `LoadingButton` (`core/widgets/loading_button.dart`) : `FilledButton` désactivé avec un indicateur pendant `isLoading`. À utiliser pour toute soumission branchée sur un `AsyncValue`.

## Affichage des erreurs

- Erreur suite à une action (soumission, favori, suppression…) : `showErrorBottomSheet(context, failure, onRetry: …)` (`core/widgets/error_bottom_sheet.dart`), déclenchée depuis un `ref.listen`. Icône, titre et message dépendent du type de `Failure`.
- Erreur de chargement d'un écran : état d'erreur affiché dans la page (branche `error` du `.when`), avec `failure.title(t)` / `failure.message(t)`.
- Jamais de `e.toString()` ni de message Firebase affiché à l'utilisateur.

## Accessibilité

- Cibles tactiles ≥ 48 dp, `Semantics`/`tooltip` sur les boutons icônes, contrastes conformes en clair et sombre.
