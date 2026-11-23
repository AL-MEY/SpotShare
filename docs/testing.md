# Tests

La grille exige : tests unitaires des **repositories**, **use cases** et **providers**, et tests de widgets des composants critiques (carte, fiche lieu, formulaires).

## Organisation

- `test/` reproduit l'arborescence de `lib/` : `lib/features/spot/domain/usecases/create_spot.dart` → `test/features/spot/domain/usecases/create_spot_test.dart`.
- Un fichier de test par classe testée, suffixe `_test.dart`.
- Fakes et fixtures partagés dans `test/helpers/` : `pumpApp(tester, auth: …)` pompe l'app complète avec un `FakeAuthRepository` (visiteur par défaut, `FakeAuthRepository(FakeAuthRepository.user)` pour un utilisateur connecté, `auth.emit(...)` pour simuler connexion et déconnexion, `auth.failure = …` pour faire échouer toutes les actions, `auth.resetEmail` pour vérifier l'e-mail de réinitialisation). `pumpApp(tester, profile: …)` remplace aussi le profil par un `FakeProfileRepository` : par défaut l'utilisateur connecté a déjà un profil, `FakeProfileRepository(null)` simule un premier login (redirection vers `ProfileSetupPage`), `profile.saved` / `profile.savedAvatarPath` vérifient l'enregistrement, `profile.failure = …` fait échouer chargement et enregistrement. `overrides: [...]` remplace d'autres providers (ex. `imagePickerProvider` avec un mock d'`ImagePicker`).
- Fakes de la feature `spot` (`spot_fixtures.dart`, `fake_spot_repository.dart`, `fake_rating_repository.dart`, `fake_comment_repository.dart`, `fake_spot_author_repository.dart`) : `buildSpot(...)` / `buildComment(...)` (id `spotId` = `'s1'`) fabriquent des entités ; chaque fake expose `failure = …` pour faire échouer ses méthodes, `emit(...)` pour pousser une nouvelle valeur dans le flux (`emitFailure(...)` pour une erreur sur `FakeSpotRepository`) et `dispose()`. `FakeRatingRepository.rated` liste les notes envoyées et `pending` (un `Completer`) retarde `rate` ; `FakeCommentRepository.added` / `deleted` / `requestedLimits` mémorisent textes ajoutés, ids supprimés et limites demandées à `watchComments`.

## Quoi tester

| Cible | Comment |
|---|---|
| Use case | appel du repository mocké, résultat et erreurs |
| Repository | datasources mockées : mapping DTO ↔ entité, conversion des exceptions en `Failure`, logique offline (local d'abord, sync différée) |
| Provider / Notifier | `ProviderContainer` avec `overrides` des use cases ; vérifier la séquence `loading → data` et `loading → error` |
| Routeur | pomper `SpotShareApp`, `pumpApp` renvoie le `ProviderContainer` : `container.read(routerProvider).go(...)` ; vérifier la page affichée |
| Widget critique | `pumpWidget` dans un `ProviderScope(overrides: …)` + `MaterialApp` avec localisations ; vérifier les états loading / data / error et les interactions |

## Règles

- Jamais de vrai Firebase ni de réseau en test : mocks `mocktail` (pas `mockito` : pas de codegen) ou fakes. Pour Firestore, `fake_cloud_firestore` est accepté dans les tests de datasource.
- Structure Arrange / Act / Assert, noms de tests qui décrivent le comportement (`'renvoie une Failure quand le réseau est indisponible'`).
- Un bug corrigé = un test qui l'aurait détecté.
- `flutter test` doit passer avant tout commit ; la CI le vérifie sur chaque PR.
