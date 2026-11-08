# UI et widgets

## Découpage de l'arbre

- Toute méthode `build()` de plus de 80 lignes est découpée en widgets dédiés (critère éliminatoire de la grille).
- Extraire en **classes** `StatelessWidget`, pas en méthodes `_buildXxx()` : les classes permettent `const` et des rebuilds isolés.
- `StatelessWidget` / `ConsumerWidget` par défaut. `StatefulWidget` seulement pour un état visuel local (contrôleurs d'animation, de texte, de scroll).
- `const` sur tout constructeur et tout sous-arbre statique. L'analyseur le signale (`prefer_const_constructors`).

## Thème Material 3

- `useMaterial3: true`, `ThemeData` clair **et** sombre définis dans `core/theme/`, générés depuis un `ColorScheme.fromSeed`.
- Aucune couleur ni taille de texte en dur dans les widgets : `Theme.of(context).colorScheme` et `textTheme`.
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

- `flutter_localizations` + fichiers `lib/l10n/app_fr.arb` et `app_en.arb`, génération via `flutter gen-l10n`.
- `l10n.yaml` : `arb-dir: lib/l10n`, `output-dir: lib/l10n/generated`, `template-arb-file: app_fr.arb`. Ne pas utiliser `synthetic-package` ni `package:flutter_gen` (obsolètes) : importer `package:spotshare/l10n/generated/app_localizations.dart`.
- Aucun texte visible en dur : toujours une clé ARB, ajoutée dans **les deux** fichiers.
- La langue choisie par l'utilisateur est persistée localement et restaurée au démarrage.

## Accessibilité

- Cibles tactiles ≥ 48 dp, `Semantics`/`tooltip` sur les boutons icônes, contrastes conformes en clair et sombre.
