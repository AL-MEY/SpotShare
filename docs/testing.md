# Tests

La grille exige : tests unitaires des **repositories**, **use cases** et **providers**, et tests de widgets des composants critiques (carte, fiche lieu, formulaires).

## Organisation

- `test/` reproduit l'arborescence de `lib/` : `lib/features/spot/domain/usecases/create_spot.dart` → `test/features/spot/domain/usecases/create_spot_test.dart`.
- Un fichier de test par classe testée, suffixe `_test.dart`.
- Fakes et fixtures partagés dans `test/helpers/`.

## Quoi tester

| Cible | Comment |
|---|---|
| Use case | appel du repository mocké, résultat et erreurs |
| Repository | datasources mockées : mapping DTO ↔ entité, conversion des exceptions en `Failure`, logique offline (local d'abord, sync différée) |
| Provider / Notifier | `ProviderContainer` avec `overrides` des use cases ; vérifier la séquence `loading → data` et `loading → error` |
| Widget critique | `pumpWidget` dans un `ProviderScope(overrides: …)` + `MaterialApp` avec localisations ; vérifier les états loading / data / error et les interactions |

## Règles

- Jamais de vrai Firebase ni de réseau en test : mocks `mocktail` (pas `mockito` : pas de codegen) ou fakes. Pour Firestore, `fake_cloud_firestore` est accepté dans les tests de datasource.
- Structure Arrange / Act / Assert, noms de tests qui décrivent le comportement (`'renvoie une Failure quand le réseau est indisponible'`).
- Un bug corrigé = un test qui l'aurait détecté.
- `flutter test` doit passer avant tout commit ; la CI le vérifie sur chaque PR.
