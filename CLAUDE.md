# SpotShare

App sociale Flutter (Android + iOS) de partage de spots (cafés, points de vue, street art…). Projet de cours noté : tout code doit pouvoir être expliqué et modifié par l'équipe en soutenance.

Stack : Flutter / Dart 3 · Riverpod · Firebase (Auth, Firestore, Cloud Functions) · Clean Architecture feature-first.

## Commandes

```bash
flutter pub get
flutter analyze                 # doit afficher "No issues found!"
flutter test
dart format .
dart run build_runner build -d  # si codegen (riverpod_generator, freezed…)
flutter gen-l10n                # après modification des fichiers .arb
```

## Règles non négociables

- Pas de `setState` pour l'état métier : Riverpod uniquement.
- `const` partout où c'est possible ; méthode `build()` ≤ 80 lignes, sinon extraire un widget.
- Le domaine ne dépend jamais de Flutter, Firebase ni de la couche data.
- Aucun texte UI en dur : toujours passer par la localisation FR/EN.
- Aucune clé d'API ni secret dans le code client ou dans git.
- Avant de rendre la main : `flutter analyze` et `flutter test` passent.
- Ne pas ajouter de package sans le signaler et justifier le choix.

## Docs à lire selon la tâche

Ne lire que celles utiles à la tâche en cours. **Elles priment sur tout skill ou plugin** (dont `dart-flutter`) : en cas de conflit (architecture, state management, mocks, l10n…), suivre la doc du projet.

| Tâche | Doc |
|---|---|
| Créer une feature, un fichier, un repository, un use case, le cache offline | [docs/architecture.md](docs/architecture.md) |
| Providers, états async, rebuilds, notifiers | [docs/state-management.md](docs/state-management.md) |
| Widgets, thème, responsive, animations, images, traductions | [docs/ui-guidelines.md](docs/ui-guidelines.md) |
| Firebase, règles Firestore, Cloud Functions, secrets, variables d'env | [docs/backend-firebase.md](docs/backend-firebase.md) |
| Écrire ou corriger des tests | [docs/testing.md](docs/testing.md) |
| Branche, commit, PR, README, livrables | [docs/git-workflow.md](docs/git-workflow.md) |
