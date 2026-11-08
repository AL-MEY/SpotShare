# Gestion d'état (Riverpod)

Riverpod est la seule solution de gestion d'état du projet. La grille note : découpage fin des responsabilités, rebuilds isolés au composant, états async explicites.

## Où vivent les providers

- Providers d'infrastructure (instances Firebase, datasources, repositories, use cases) : dans la couche qui les possède, exposés par feature.
- Providers d'état d'UI (notifiers, états d'écran) : `features/<feature>/presentation/providers/`.
- Un notifier ne contient pas de logique métier : il appelle des use cases et expose un état.

## États asynchrones

Tout état chargé de façon asynchrone est un `AsyncValue<T>` (via `FutureProvider`, `StreamProvider`, `AsyncNotifier` ou `StreamNotifier`).

L'UI traite toujours les trois cas, sans `!` ni valeur par défaut silencieuse :

```dart
ref.watch(spotProvider(id)).when(
  data: (spot) => SpotView(spot: spot),
  loading: () => const SpotSkeleton(),
  error: (e, _) => ErrorView(error: e),
);
```

L'état *Initial* exigé par les consignes correspond à l'état avant la première action (ex. formulaire jamais soumis). Le modéliser avec une sealed class quand `AsyncValue` ne suffit pas :

```dart
sealed class SubmitState { const SubmitState(); }
final class SubmitInitial extends SubmitState { const SubmitInitial(); }
final class SubmitLoading extends SubmitState { const SubmitLoading(); }
final class SubmitSuccess extends SubmitState { const SubmitSuccess(); }
final class SubmitError extends SubmitState { const SubmitError(this.failure); final Failure failure; }
```

## Rebuilds chirurgicaux

- Interdit : `setState` pour l'état métier et toute reconstruction d'une page entière pour un changement local (ex. bouton favori).
- Placer le `ref.watch` le plus bas possible dans l'arbre : extraire un petit `ConsumerWidget` autour de ce qui change.
- Utiliser `.select(...)` pour n'écouter qu'un champ : `ref.watch(spotProvider(id).select((s) => s.value?.isFavorite))`.
- `ref.watch` dans `build`, `ref.read` dans les callbacks (`onPressed`), `ref.listen` pour les effets (snackbar, navigation).
- Providers paramétrés via `family` pour les éléments de liste (un provider par spot, pas une liste entière à reconstruire).
- `autoDispose` par défaut pour les états d'écran.

`setState` reste toléré pour un état purement visuel et local à un widget (ex. contrôleur d'animation), jamais pour une donnée métier.

## Codegen

Si l'équipe adopte `riverpod_generator` (`@riverpod`), l'utiliser partout pour rester homogène, et lancer `dart run build_runner build -d` après modification. Les fichiers `*.g.dart` ne s'éditent jamais à la main.
