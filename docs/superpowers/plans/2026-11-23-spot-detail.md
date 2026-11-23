# Fiche Spot + notes et commentaires — plan d'implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal :** livrer la fiche détaillée d'un spot (infos, galerie photo/vidéo, avis), la notation et les commentaires, avec règles Firestore, Cloud Functions (compteurs, `geohash`) et données de démo sur dev.

**Architecture :** nouvelle feature `lib/features/spot/` calquée sur `profile` (entités Dart pur → DTO/mapper/datasource Firestore → repositories qui lèvent des `Failure` → providers Riverpod écrits à la main → widgets, un par fichier). Lecture en temps réel directe sur Firestore (cache offline natif). Les compteurs et le `geohash` ne sont écrits que par des Cloud Functions TypeScript dans `functions/`.

**Tech Stack :** Flutter 3.47.9 (via `fvm`), Riverpod 3 (sans codegen), go_router, slang, theme_tailor, cloud_firestore, cached_network_image, connectivity_plus, video_player (nouveau), mocktail, fake_cloud_firestore (nouveau, dev). Functions : Node 22, TypeScript, firebase-functions v2, firebase-admin, geofire-common.

**Spec :** [docs/superpowers/specs/2026-11-23-spot-detail-design.md](../specs/2026-11-23-spot-detail-design.md), à lire avant de commencer : ce plan s'appuie dessus et ne la recopie pas.

## Global Constraints

- Branche `feat/spot-detail` (partie de `feat/user-profile`). Toutes les commandes Flutter/Dart passent par `fvm` (`fvm flutter test`…).
- Chaque commit compile, passe `fvm flutter analyze` (« No issues found! ») et `fvm flutter test`, et respecte `dart format`. Conventional Commits en anglais, sans co-auteur IA.
- **Commits séparés** (exigence de Mathis, spec §9) : chaque étape « Commit » ci-dessous est un commit distinct ; ne jamais en fusionner deux. `favoriteCount` (tâche 22) et `geohash` (tâche 23) ont leurs propres commits ; l'ajout d'un package est un commit `build` à part.
- Domaine en Dart pur : aucun import `package:flutter`, `cloud_firestore`, `firebase_*` ni `data/`.
- La feature `spot` n'importe rien de `profile/data` ni `profile/presentation`. Elle ne lit que `currentUserIdProvider` dans `auth_providers.dart`.
- Aucun texte visible en dur : clés slang dans `lib/i18n/fr.i18n.yaml` **et** `en.i18n.yaml`, puis `./scripts/generate_theme_and_i18n.sh`.
- Aucun style en dur : `context.appTheme` (`colors`, `textStyles.h1–h3/b1–b3/l1`, `spacing.spacing3xs…spacing4xl`, `radius`…). `accent` est réservé aux étoiles et à la sélection, `action` aux boutons.
- `build()` ≤ 80 lignes, un widget par fichier, `const` partout où c'est possible, `StatelessWidget`/`ConsumerWidget` par défaut.
- Erreur de chargement : affichée dans la page (`failure.title(t)` / `failure.message(t)`). Erreur suite à une action : `showErrorBottomSheet` depuis un `ref.listen`.
- Navigation uniquement via `AppRoutes` + `context.push`/`context.go`.
- Valeurs fixées par la spec : titre 3–80, description ≤ 2000, adresse 1–200, médias 1–10, tags 0–10 de 1–24 caractères, vidéo ≤ 60 s, commentaire 1–500 après trim, note entière 1–5, pagination des commentaires par 20.
- Tests : jamais de vrai Firebase ; noms de tests en français décrivant le comportement ; `test/` reproduit `lib/`.
- Doc alignée dans la même PR : chaque tâche qui rend une doc inexacte a son commit `docs(...)`.

## Review Focus

1. **Spot sans média valide** (tous les médias mal formés, donc ignorés) : la vignette de la liste et la galerie affichent un placeholder au lieu de planter. Testé aux tâches 4 (mapper), 13 (galerie) et 18 (liste).
2. **Texte très long sans espaces** (commentaire de 500 caractères d'un seul mot, titre de 80 caractères sur un écran de 320 px de large) : retour à la ligne ou ellipse, jamais d'erreur d'overflow. Testé aux tâches 12 et 16.
3. **Auteur sans profil** (`users/{uid}` absent ou supprimé) : la fiche et les commentaires affichent « Auteur inconnu » avec un avatar générique. Testé aux tâches 6, 12 et 16.
4. **Taps rapides sur les étoiles** (3 puis 5) : la dernière note envoyée est 5, l'affichage finit sur 5, aucun état de chargement bloqué. Testé à la tâche 14.
5. **Spot supprimé pendant qu'on le regarde** (le flux émet « absent » depuis le serveur) : la page bascule sur l'état d'erreur « Introuvable », sans crash. Testé à la tâche 11.

---

## Structure des fichiers

```
lib/core/layout/breakpoints.dart                       WindowSize + Breakpoints (tâche 17)
lib/core/network/connectivity_provider.dart            connectivityProvider, isOnlineProvider (tâche 8)
lib/core/widgets/rating_stars.dart                     étoiles génériques sans Riverpod (tâche 10)
lib/features/spot/
  domain/entities/   geo_position, spot_category, spot_media, spot, rating, spot_comment, spot_author
  domain/repositories/ spot_repository, rating_repository, comment_repository, spot_author_repository
  domain/usecases/   rate_spot, add_comment, delete_comment
  data/models/       spot_dto (+ SpotMediaDto), spot_comment_dto, spot_author_dto
  data/mappers/      spot_mapper, spot_comment_mapper, spot_author_mapper
  data/datasources/  spot_remote_data_source, rating_remote_data_source,
                     comment_remote_data_source, spot_author_remote_data_source
  data/repositories/ firebase_spot_repository, firebase_rating_repository,
                     firebase_comment_repository, firebase_spot_author_repository
  presentation/providers/spot_providers.dart
  presentation/hero_tags.dart
  presentation/pages/ spot_detail_page, spot_media_viewer_page
  presentation/widgets/ (un fichier par widget, listés par tâche)
functions/                                             projet TypeScript (tâches 19 à 23)
firestore.rules                                        règles spots / ratings / comments (tâche 19)
scripts/deploy-functions.sh                            déploiement des Functions (tâche 20)
test/helpers/fake_spot_repository.dart, fake_rating_repository.dart,
            fake_comment_repository.dart, fake_spot_author_repository.dart, spot_fixtures.dart
```

---

### Task 1 : Entités du domaine

**Files :**
- Create : `lib/features/spot/domain/entities/{geo_position,spot_category,spot_media,spot,rating,spot_comment,spot_author}.dart`
- Test : `test/features/spot/domain/entities/{rating,spot,spot_media}_test.dart`

**Interfaces :**
- Produces :
  - `class GeoPosition { const GeoPosition({required double latitude, required double longitude}); }`, avec égalité par valeur.
  - `enum SpotCategory { cafe, viewpoint, streetArt, restaurant, park, other }`.
  - `sealed class SpotMedia { const SpotMedia({required String url}); String get previewUrl; }`, avec deux sous-classes :
    - `final class SpotPhoto extends SpotMedia`, dont `previewUrl` vaut `url` ;
    - `final class SpotVideo extends SpotMedia { const SpotVideo({required String url, required String thumbnailUrl, required Duration duration}); static const maxDuration = Duration(seconds: 60); }`, dont `previewUrl` vaut `thumbnailUrl`.
  - `class Spot`. Champs : `id`, `title`, `description`, `category`, `address`, `GeoPosition location`, `List<SpotMedia> media`, `List<String> tags`, `authorId`, `DateTime createdAt`, `double averageRating`, `int ratingCount`, `int commentCount`. Getter `String? get coverImageUrl`, qui vaut `null` si `media` est vide.
  - Constantes de `Spot` : `titleMinLength = 3`, `titleMaxLength = 80`, `descriptionMaxLength = 2000`, `addressMaxLength = 200`, `maxMedia = 10`, `maxTags = 10`, `tagMaxLength = 24`.
  - `class Rating { factory Rating(int value); final int value; static const min = 1, max = 5; }`. Lève `ArgumentError` hors de 1–5.
  - `class SpotComment { id, authorId, text, DateTime createdAt; static const maxLength = 500; }`.
  - `class SpotAuthor { id, displayName, String? avatarUrl }`.
  - Toutes les entités ont une égalité par valeur, et `Spot` compare ses listes élément par élément (helper privé, pas de package).

- [ ] **Step 1 : écrire les tests qui échouent**
  - `rating_test` :
    - `'accepte les valeurs de 1 à 5'` : `Rating(1).value == 1`, `Rating(5).value == 5` ;
    - `'refuse 0 et 6'` : `expect(() => Rating(0), throwsArgumentError)` et idem pour `6` ;
    - `'deux notes de même valeur sont égales'`.
  - `spot_media_test` :
    - `'la prévisualisation d’une photo est son url'` ;
    - `'la prévisualisation d’une vidéo est sa vignette'`.
  - `spot_test` :
    - `'la couverture est la prévisualisation du premier média'`, avec une vidéo en premier → sa `thumbnailUrl` ;
    - `'pas de couverture sans média'` → `null` ;
    - `'deux spots identiques sont égaux'`, avec des listes reconstruites.
- [ ] **Step 2 : lancer `fvm flutter test test/features/spot/domain/entities`**. Attendu : ÉCHEC (fichiers absents).
- [ ] **Step 3 : implémenter les entités** avec les signatures ci-dessus.
- [ ] **Step 4 : relancer les tests**. Attendu : SUCCÈS. Lancer aussi `fvm flutter analyze`.
- [ ] **Step 5 : commit** `feat(spot): add spot domain entities`

### Task 2 : Contrats de repository et use cases

**Files :**
- Create : `lib/features/spot/domain/repositories/{spot,rating,comment,spot_author}_repository.dart`, `lib/features/spot/domain/usecases/{rate_spot,add_comment,delete_comment}.dart`
- Test : `test/features/spot/domain/usecases/{rate_spot,add_comment,delete_comment}_test.dart`

**Interfaces :**
- Consumes : les entités de la tâche 1.
- Produces :
  - `abstract interface class SpotRepository { Stream<Spot> watchSpot(String spotId); Stream<List<Spot>> watchRecentSpots({int limit = 20}); }`
  - `abstract interface class RatingRepository { Stream<Rating?> watchMyRating({required String spotId, required String userId}); Future<void> rate({required String spotId, required String userId, required Rating rating}); }`
  - `abstract interface class CommentRepository { Stream<List<SpotComment>> watchComments(String spotId, {required int limit}); Future<void> addComment({required String spotId, required String authorId, required String text}); Future<void> deleteComment({required String spotId, required String commentId}); }`
  - `abstract interface class SpotAuthorRepository { Stream<SpotAuthor?> watchAuthor(String userId); }`
  - Use cases, chacun un `const` constructeur prenant son repository et une méthode `call` :
    - `RateSpot.call({required String spotId, required String userId, required Rating rating})` ;
    - `AddComment.call({required String spotId, required String authorId, required String text})`, qui trime `text` puis délègue ;
    - `DeleteComment.call({required String spotId, required String commentId})`.

- [ ] **Step 1 : écrire les tests qui échouent**, avec des mocks `mocktail` des repositories :
  - `'RateSpot transmet la note au repository'` ;
  - `'AddComment retire les espaces autour du texte'` : `'  Super café  '` → `addComment(text: 'Super café')` ;
  - `'AddComment propage la Failure du repository'` (`NetworkFailure`) ;
  - `'DeleteComment supprime le commentaire demandé'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter les interfaces et les use cases.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add spot repositories contracts and review use cases`

### Task 3 : Fakes de test partagés

**Files :**
- Create : `test/helpers/spot_fixtures.dart`, `test/helpers/fake_spot_repository.dart`, `fake_rating_repository.dart`, `fake_comment_repository.dart`, `fake_spot_author_repository.dart`
- Modify : `docs/testing.md` (section helpers)

**Interfaces :**
- Produces (à imiter de `FakeProfileRepository`) :
  - `spot_fixtures.dart` :
    - `const spotId = 's1'` ;
    - `Spot buildSpot({String id = spotId, String authorId = 'author', List<SpotMedia>? media, …})`, avec 2 photos par défaut ;
    - `SpotComment buildComment({String id, String authorId, String text})`.
  - Chaque fake implémente son interface avec :
    - un champ `Failure? failure`, qui fait échouer chaque méthode ;
    - un `StreamController` broadcast, et `emit…` pour pousser une nouvelle valeur ;
    - les appels mémorisés : `rated` (`List<Rating>`), `added` (`List<String>`), `deleted` (`List<String>`) ;
    - `dispose()`.
  - `FakeRatingRepository.rate` peut être retardé par un `Completer` exposé (`Completer<void>? pending`), pour la tâche 14.

- [ ] **Step 1 : écrire les fakes et fixtures.** Pas de test dédié : ils sont exercés dès la tâche 9.
- [ ] **Step 2 : `fvm flutter analyze`**. Attendu : aucune issue.
- [ ] **Step 3 : commit** `test(spot): add spot fakes and fixtures`
- [ ] **Step 4 : ajouter les nouveaux fakes à `docs/testing.md`**, puis commit `docs(testing): document spot fakes`

### Task 4 : Data — spot (DTO, mapper, datasource, repository)

**Files :**
- Modify : `pubspec.yaml` (dev : `fake_cloud_firestore`)
- Create : `lib/features/spot/data/models/spot_dto.dart`, `data/mappers/spot_mapper.dart`, `data/datasources/spot_remote_data_source.dart`, `data/repositories/firebase_spot_repository.dart`
- Test : `test/features/spot/data/{models/spot_dto_test,mappers/spot_mapper_test,datasources/spot_remote_data_source_test,repositories/firebase_spot_repository_test}.dart`

**Interfaces :**
- Consumes : `Spot`, `SpotMedia`, `SpotRepository` (tâches 1 et 2), `failureFrom` (`core/error/firebase_failure.dart`).
- Produces :
  - `class SpotMediaDto { type, url, String? thumbnailUrl, int? durationMs; factory SpotMediaDto.fromMap(Map<String, dynamic>); }`
  - `class SpotDto { …; GeoPoint location; DateTime createdAt; double averageRating; int ratingCount; int commentCount; factory SpotDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>>); }`. Les compteurs absents valent 0, et les `num` sont convertis en `double`/`int`.
  - `extension SpotDtoMapper on SpotDto { Spot toEntity(); }` :
    - une catégorie inconnue donne `SpotCategory.other` ;
    - un média mal formé est ignoré (type inconnu, vidéo sans `thumbnailUrl` ni `durationMs`).
  - `typedef SpotDocument = ({SpotDto? dto, bool isFromCache});`
  - `class SpotRemoteDataSource(FirebaseFirestore)` :
    - `Stream<SpotDocument> watchSpot(String spotId)` ;
    - `Stream<List<SpotDto>> watchRecentSpots(int limit)`, qui trie sur `createdAt` décroissant.
  - `class FirebaseSpotRepository implements SpotRepository`, qui reçoit `SpotRemoteDataSource`. Selon le document reçu :
    - `dto` présent → `Spot` ;
    - `dto == null` venant du serveur → `NotFoundFailure` ;
    - `dto == null` venant du cache → `NetworkFailure` ;
    - toute autre erreur passe par `failureFrom`.

- [ ] **Step 1 : ajouter `fake_cloud_firestore` en dev dependency.** Vérifier sa compatibilité avec `cloud_firestore ^7.1.0` via `fvm flutter pub get`. En cas d'incompatibilité, retirer le package et tester la datasource avec des mocks `mocktail`, comme `profile_remote_data_source_test.dart`, et le signaler à Mathis. Puis commit `build(spot): add fake_cloud_firestore for data source tests`.
- [ ] **Step 2 : écrire les tests qui échouent** :
  - DTO :
    - `'lit un document complet'` ;
    - `'les compteurs absents valent 0'`.
  - Mapper :
    - `'une catégorie inconnue devient other'` ;
    - `'convertit photo et vidéo dans l’ordre'` ;
    - `'ignore un média de type inconnu'` ;
    - `'ignore une vidéo sans vignette'` ;
    - `'un spot dont aucun média n’est valide a une liste vide'` (Review Focus 1).
  - Datasource (`FakeFirebaseFirestore`) :
    - `'émet le spot quand il existe'` ;
    - `'émet un document vide quand le spot n’existe pas'` ;
    - `'liste les spots récents du plus récent au plus ancien, limitée'`.
  - Repository (datasource mockée) :
    - `'convertit le DTO en entité'` ;
    - `'lève NotFoundFailure quand le serveur ne trouve pas le spot'` ;
    - `'lève NetworkFailure quand le spot est absent du cache'` ;
    - `'convertit une FirebaseException permission-denied en PermissionFailure'`.
- [ ] **Step 3 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 4 : implémenter.** `watchSpot` utilise `snapshots()` et renvoie `(dto: s.exists ? SpotDto.fromFirestore(s) : null, isFromCache: s.metadata.isFromCache)`.
- [ ] **Step 5 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 6 : commit** `feat(spot): add spot dto and mapper`. Inclure uniquement le DTO, le mapper et leurs tests.
- [ ] **Step 7 : commit** `feat(spot): add firestore spot data source and repository`

### Task 5 : Data — notes

**Files :**
- Create : `data/datasources/rating_remote_data_source.dart`, `data/repositories/firebase_rating_repository.dart`
- Test : `test/features/spot/data/datasources/rating_remote_data_source_test.dart`, `test/features/spot/data/repositories/firebase_rating_repository_test.dart`

**Interfaces :**
- Produces :
  - `class RatingRemoteDataSource(FirebaseFirestore)` :
    - `Stream<int?> watchRating(String spotId, String userId)` ;
    - `Future<void> setRating(String spotId, String userId, int value)`, qui écrit exactement `{value, updatedAt: FieldValue.serverTimestamp()}` dans `spots/{spotId}/ratings/{userId}`.
  - `class FirebaseRatingRepository implements RatingRepository`. Une valeur stockée hors 1–5 est lue comme `null`.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'écrit la note dans ratings/{uid} avec la valeur et la date'` ;
  - `'émet null quand l’utilisateur n’a pas noté'` ;
  - `'émet la nouvelle note après écriture'` ;
  - `'une valeur stockée invalide est lue comme absente'` ;
  - `'convertit les erreurs en Failure'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add firestore rating data source and repository`

### Task 6 : Data — commentaires et auteurs

**Files :**
- Create :
  - `data/models/spot_comment_dto.dart` et `data/models/spot_author_dto.dart` ;
  - `data/mappers/spot_comment_mapper.dart` et `data/mappers/spot_author_mapper.dart` ;
  - `data/datasources/comment_remote_data_source.dart` et `data/datasources/spot_author_remote_data_source.dart` ;
  - `data/repositories/firebase_comment_repository.dart` et `data/repositories/firebase_spot_author_repository.dart`.
- Test : un fichier par classe ci-dessus, sous `test/features/spot/data/`.

**Interfaces :**
- Produces :
  - `SpotCommentDto.fromFirestore(...)`. Si `createdAt` est absent (écriture locale pas encore confirmée par le serveur), il vaut `DateTime.now()`.
  - `SpotAuthorDto.fromFirestore(...)`, qui lit `displayName` et `avatarUrl` dans `users/{uid}`.
  - `CommentRemoteDataSource` :
    - `Stream<List<SpotCommentDto>> watchComments(String spotId, int limit)`, trié par `createdAt` décroissant ;
    - `Future<void> addComment(String spotId, String authorId, String text)`, qui écrit `{authorId, text, createdAt: serverTimestamp}` ;
    - `Future<void> deleteComment(String spotId, String commentId)`.
  - `SpotAuthorRemoteDataSource.watchAuthor(String userId) → Stream<SpotAuthorDto?>`, avec le même filtre cache que `ProfileRemoteDataSource.watchProfile`.
  - `FirebaseCommentRepository` et `FirebaseSpotAuthorRepository`, qui implémentent les interfaces de la tâche 2.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'un commentaire sans date serveur prend la date courante'` ;
  - `'liste les commentaires du plus récent au plus ancien, limités'` ;
  - `'ajoute un commentaire avec l’auteur, le texte et la date serveur'` ;
  - `'supprime le commentaire'` ;
  - `'lit le nom et l’avatar de l’auteur'` ;
  - `'émet null quand l’auteur n’a pas de profil'` (Review Focus 3) ;
  - pour chaque repository : `'convertit les erreurs en Failure'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add firestore comment data source and repository`. Inclure les fichiers commentaires et leurs tests.
- [ ] **Step 6 : commit** `feat(spot): add spot author data source and repository`

### Task 7 : Doc d'architecture de la feature spot

- [ ] **Step 1 : ajouter une section « Spot » à `docs/architecture.md`**, au format de la section « Profil utilisateur » : arborescence, lecture directe sur Firestore et cache natif, règle `NotFoundFailure` / `NetworkFailure`, auteurs lus dans `users/{uid}` sans importer `profile`.
- [ ] **Step 2 : commit** `docs(spot): document spot feature architecture`

### Task 8 : État du réseau

**Files :**
- Create : `lib/core/network/connectivity_provider.dart`
- Test : `test/core/network/connectivity_provider_test.dart`

**Interfaces :**
- Produces :
  - `final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());`
  - `final isOnlineProvider = StreamProvider<bool>(...)`. Il émet d'abord le résultat de `checkConnectivity()`, puis `onConnectivityChanged`. La valeur est `true` si au moins un résultat est différent de `ConnectivityResult.none`.

- [ ] **Step 1 : écrire les tests qui échouent** (avec `Connectivity` mocké) :
  - `'en ligne quand le wifi est disponible'` ;
  - `'hors ligne quand aucune connexion'` ;
  - `'suit les changements de connexion'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(core): add connectivity provider`
- [ ] **Step 6 : mettre à jour l'arborescence `core/network/` dans `architecture.md`**, puis commit `docs(core): document connectivity provider`

### Task 9 : Providers de la feature

**Files :**
- Create : `lib/features/spot/presentation/providers/spot_providers.dart`
- Test : `test/features/spot/presentation/providers/spot_providers_test.dart`

**Interfaces :**
- Consumes : tâches 2 et 4 à 8, `currentUserIdProvider`, `SubmitController`.
- Produces (noms exacts) :
  - Infrastructure, lisible par d'autres features :
    - `spotRepositoryProvider`, `ratingRepositoryProvider`, `commentRepositoryProvider`, `spotAuthorRepositoryProvider` : `Provider<Interface>` construits sur `FirebaseFirestore.instance` ;
    - `rateSpotProvider`, `addCommentProvider`, `deleteCommentProvider`.
  - Lectures :
    - `spotProvider` : `StreamProvider.autoDispose.family<Spot, String>` ;
    - `recentSpotsProvider` : `StreamProvider.autoDispose<List<Spot>>`, limité à 20 ;
    - `spotAuthorProvider` : `StreamProvider.autoDispose.family<SpotAuthor?, String>` ;
    - `myRatingProvider` : `StreamProvider.autoDispose.family<Rating?, String>`, qui renvoie `Stream.value(null)` sans utilisateur connecté.
  - Pagination :
    - `commentsLimitProvider` : `NotifierProvider.autoDispose.family<CommentsLimit, int, String>`, avec `class CommentsLimit extends Notifier<int> { CommentsLimit(this.spotId); static const pageSize = 20; void showMore(); }` ;
    - `commentsProvider` : `StreamProvider.autoDispose.family<List<SpotComment>, String>`, qui `watch` la limite.
  - Actions, chacun un `AsyncNotifierProvider.autoDispose<SubmitController, void>` : `rateSpotControllerProvider`, `commentComposerControllerProvider`, `deleteCommentControllerProvider`.

**Écart assumé par rapport à la spec** (« `myRatingProvider` : AsyncNotifier optimiste ») : la mise à jour optimiste vient de Firestore lui-même. Une écriture locale est émise immédiatement par le flux (*latency compensation*), puis annulée si le serveur la rejette. `myRatingProvider` reste donc un simple `StreamProvider`, et l'erreur arrive par `rateSpotControllerProvider`. Ce comportement est à expliquer en soutenance, et à documenter à l'étape 6.

- [ ] **Step 1 : écrire les tests qui échouent** (`ProviderContainer` + fakes de la tâche 3) :
  - `'spotProvider passe de loading à data'` ;
  - `'spotProvider passe en erreur avec la Failure du repository'` ;
  - `'myRatingProvider vaut null sans utilisateur connecté'` ;
  - `'commentsProvider charge 20 commentaires puis 40 après showMore'` : vérifier que `watchComments` est appelé avec `limit: 20` puis `40` ;
  - `'rateSpotControllerProvider passe en erreur quand la note est refusée'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add spot providers`
- [ ] **Step 6 : compléter la section Spot d'`architecture.md`** (liste des providers, *latency compensation*, providers lisibles par le flux), puis commit `docs(spot): document spot providers`

### Task 10 : Étoiles génériques

**Files :**
- Create : `lib/core/widgets/rating_stars.dart`
- Test : `test/core/widgets/rating_stars_test.dart`

**Interfaces :**
- Produces : `class RatingStars extends StatelessWidget { const RatingStars({required double value, ValueChanged<int>? onChanged, double? size, String Function(int)? semanticLabel}); }`.
  - Avec `onChanged`, il affiche 5 `IconButton` (cibles ≥ 48 dp, `tooltip` = `semanticLabel(n)`).
  - Sans `onChanged`, c'est un affichage en lecture seule, qui arrondit à la demi-étoile la plus proche (`star`, `star_half`, `star_border`).
  - Couleur : `colors.accent`.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'affiche 3,5 étoiles en lecture seule'`, qui compte les icônes ;
  - `'un tap sur la 4e étoile appelle onChanged(4)'` ;
  - `'sans onChanged, aucune étoile n’est cliquable'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(core): add reusable rating stars widget`

### Task 11 : Route et squelette de la page (chargement, erreur, données)

**Files :**
- Modify : `lib/core/router/app_router.dart`, `lib/i18n/fr.i18n.yaml`, `lib/i18n/en.i18n.yaml` (+ fichiers générés)
- Create :
  - `lib/features/spot/presentation/hero_tags.dart` ;
  - `presentation/pages/spot_detail_page.dart` ;
  - `presentation/widgets/spot_detail_skeleton.dart`, `spot_load_error.dart`, `spot_detail_layout.dart`.
- Test : `test/features/spot/presentation/pages/spot_detail_page_test.dart`

**Interfaces :**
- Produces :
  - Dans `AppRoutes` :
    - `static String spotDetail(String spotId) => '/spots/$spotId';`
    - `static String spotMedia(String spotId, int index) => '/spots/$spotId/media?index=$index';`
    - `GoRoute(path: '/spots/:spotId', routes: [GoRoute(path: 'media')])`, la route enfant étant branchée à la tâche 13.
  - `String spotMediaHeroTag(String spotId, int index)`, qui renvoie `'spot-image-$spotId'` pour l'index 0 et `'spot-media-$spotId-$index'` sinon.
  - `SpotDetailPage({required String spotId})` : un `Scaffold` qui fait `ref.watch(spotProvider(spotId))` dans un `AnimatedSwitcher`, avec trois branches :
    - `loading` → `SpotDetailSkeleton` ;
    - `error` → `SpotLoadError(failure, onRetry: invalidate)` ;
    - `data` → `SpotDetailLayout(spot: spot)`.
  - `SpotDetailLayout({required Spot spot})` : un `CustomScrollView` qui reçoit les sections des tâches 12 à 16. Son découpage tablette arrive à la tâche 17.
  - Clés slang à créer (FR et EN) sous `spot:` :
    - catégories : `category.{cafe, viewpoint, streetArt, restaurant, park, other}` ;
    - informations : `noRating`, `ratingCount` (pluriel), `by(name)`, `unknownAuthor`, `copyAddress`, `addressCopied`, `readMore`, `readLess`, `yourRating`, `rateTooltip(n)`, `ownSpot`, `offline` ;
    - commentaires : `comments.{title(n), hint, send, tooLong(max), empty, none, showMore, delete, deleteTitle, deleteMessage, cancel, justNow, minutesAgo(n), hoursAgo(n), daysAgo(n)}` ;
    - médias : `media.{position(current,total), play, pause, mute, unmute, videoError, close, video}` ;
    - liste : `recent.{title, empty}`.

- [ ] **Step 1 : écrire les tests qui échouent.** Ils passent par `pumpApp`, avec un utilisateur connecté, les fakes `spot` en `overrides`, puis `container.read(routerProvider).go(AppRoutes.spotDetail(spotId))` :
  - `'affiche le squelette pendant le chargement'` ;
  - `'affiche le titre du spot une fois chargé'` ;
  - `'affiche l’erreur et réessaie au tap sur Réessayer'` ;
  - `'bascule sur Introuvable quand le spot est supprimé pendant l’affichage'` : émettre un spot, puis `NotFoundFailure` (Review Focus 5) ;
  - `'une route /spots/ inconnue affiche la page introuvable'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : ajouter toutes les clés slang**, puis lancer `./scripts/generate_theme_and_i18n.sh`.
- [ ] **Step 4 : implémenter la route, la page, le squelette, l'erreur et la mise en page minimale** (le titre seul).
- [ ] **Step 5 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 6 : commit** `feat(l10n): add spot detail translations`. Inclure uniquement les YAML et les fichiers générés.
- [ ] **Step 7 : commit** `feat(spot): add spot detail route and page states`
- [ ] **Step 8 : ajouter la route à la section « Navigation » d'`architecture.md`**, puis commit `docs(spot): document spot detail route`

### Task 12 : Section informations

**Files :**
- Create : `presentation/widgets/spot_header.dart`, `spot_category_chip.dart`, `spot_rating_summary.dart`, `spot_address_row.dart`, `spot_author_label.dart`, `spot_description.dart`, `spot_tags.dart`, `author_avatar.dart`
- Modify : `spot_detail_layout.dart`
- Test : un `_test.dart` par widget ayant un comportement, et `spot_detail_page_test.dart`

**Interfaces :**
- Produces :
  - `SpotRatingSummary({required String spotId})` : un `ConsumerWidget` qui fait `ref.watch(spotProvider(spotId).select((s) => (s.value?.averageRating, s.value?.ratingCount)))`. Il affiche `RatingStars(value:)` suivi de « 4,3 (27 notes) » formaté avec `intl` selon la locale, ou `noRating` quand le compteur vaut 0.
  - `SpotAuthorLabel({required String authorId})` : fait `watch` sur `spotAuthorProvider` et affiche `by(name)` ou `unknownAuthor`.
  - `AuthorAvatar({required String? avatarUrl, required double size})` : un `CachedNetworkImage` avec `memCacheWidth`. Sans url, il affiche une icône personne.
  - `SpotAddressRow({required String address})` : un `IconButton` « copier » qui appelle `Clipboard.setData` puis affiche la snackbar `addressCopied`.
  - `SpotDescription({required String text})` : repliée à 5 lignes, avec `readMore`/`readLess` affiché seulement si le texte déborde. L'état visuel local passe par un `StatefulWidget`, ce qui est toléré.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'affiche catégorie, adresse, tags et auteur'` ;
  - `'affiche Aucune note quand le spot n’a pas de note'` ;
  - `'copie l’adresse et confirme'` ;
  - `'déplie la description longue'` ;
  - `'n’affiche pas Voir plus pour une description courte'` ;
  - `'affiche Auteur inconnu sans profil'` (Review Focus 3) ;
  - `'un titre de 80 caractères ne déborde pas à 320 px de large'` : `tester.view.physicalSize`, aucune exception (Review Focus 2) ;
  - `'la note moyenne se met à jour sans reconstruire l’en-tête'` : compteur de builds sur un widget témoin.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add spot info section`

### Task 13 : Galerie photo et plein écran

**Files :**
- Create : `presentation/widgets/spot_gallery.dart`, `spot_media_thumbnail.dart`, `zoomable_photo.dart`, `presentation/pages/spot_media_viewer_page.dart`
- Modify : `app_router.dart` (route enfant `media`), `spot_detail_layout.dart` (`SliverAppBar` extensible qui contient la galerie)
- Test : `test/features/spot/presentation/widgets/spot_gallery_test.dart`, `test/features/spot/presentation/pages/spot_media_viewer_page_test.dart`

**Interfaces :**
- Produces :
  - `SpotGallery({required Spot spot, required double height})` : un `PageView.builder`, avec l'indicateur `position(current,total)`. Chaque page est un `Hero(tag: spotMediaHeroTag(spot.id, i))` qui contient un `SpotMediaThumbnail`. Un tap fait `context.push(AppRoutes.spotMedia(spot.id, i))`.
  - `SpotMediaThumbnail({required SpotMedia media, required double width})` : un `switch` sur `media`. Une photo s'affiche en `CachedNetworkImage`. Une vidéo affiche sa vignette, avec une icône lecture et la durée `m:ss`. L'image d'erreur et le placeholder viennent du thème.
  - `SpotMediaViewerPage({required String spotId, required int initialIndex})` : fond `colors.inverse`, `PageView`, et un bouton fermer (`tooltip: close`). Une photo s'affiche en `ZoomablePhoto` (`InteractiveViewer`, `maxScale: 4`). Une vidéo affiche un placeholder, remplacé à la tâche 15.
  - Si `spot.media` est vide, la galerie affiche un placeholder (Review Focus 1). Un `index` hors bornes est ramené dans les bornes.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'affiche la position 1 sur 3 puis 2 sur 3 après un swipe'` ;
  - `'ouvre le plein écran sur le média touché'` ;
  - `'une vidéo apparaît en vignette avec sa durée'` ;
  - `'un spot sans média affiche un placeholder'` ;
  - `'un index hors bornes ouvre le dernier média'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): add media gallery with fullscreen zoom`

### Task 14 : Noter

**Files :**
- Create : `presentation/widgets/my_rating_stars.dart`
- Modify : `spot_detail_layout.dart`
- Test : `test/features/spot/presentation/widgets/my_rating_stars_test.dart`

**Interfaces :**
- Produces : `MyRatingStars({required Spot spot})`, un `ConsumerWidget`.
  - Il fait `watch` sur `myRatingProvider(spot.id)` et sur `isOnlineProvider`.
  - Un tap appelle `ref.read(rateSpotControllerProvider.notifier).submit(() => ref.read(rateSpotProvider)(spotId:, userId:, rating: Rating(n)))`.
  - Un `ref.listen(rateSpotControllerProvider)` affiche `showErrorBottomSheet` en cas d'`AsyncError`.
  - Il est masqué au profit du texte `ownSpot` quand `spot.authorId` est l'utilisateur courant.
  - Hors ligne, les étoiles sont désactivées et la mention `offline` s'affiche.
  - Un `AnimatedSwitcher` anime le changement de note.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'un tap sur la 4e étoile enregistre la note 4'` ;
  - `'affiche la note existante de l’utilisateur'` ;
  - `'affiche la bottom sheet d’erreur quand la note est refusée'` ;
  - `'désactive les étoiles hors ligne'` ;
  - `'masque la notation sur son propre spot'` ;
  - `'deux taps rapides (3 puis 5) enregistrent 5 en dernier et affichent 5'`, avec le `Completer` du fake (Review Focus 4).
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): let users rate a spot`

### Task 15 : Lecteur vidéo

**Files :**
- Modify : `pubspec.yaml` (`video_player`), `README.md` (packages), `spot_media_viewer_page.dart`
- Create : `presentation/widgets/spot_video_player.dart`
- Test : `test/features/spot/presentation/pages/spot_media_viewer_page_test.dart` (ajouts)

**Interfaces :**
- Produces : `SpotVideoPlayer({required SpotVideo video, required bool isActive})`, un `StatefulWidget`.
  - Il crée un `VideoPlayerController.networkUrl` dans `initState` et le libère dans `dispose`.
  - Il affiche la vignette tant que la vidéo n'est pas initialisée.
  - Lecture et pause au tap. Pause quand `isActive` devient `false` (changement de page).
  - Barre de progression `VideoProgressIndicator`, et bouton son (`mute`/`unmute`).
  - Si l'initialisation échoue, il affiche `videoError`.

- [ ] **Step 1 : ajouter `video_player` à `pubspec.yaml`**, puis commit `build(spot): add video_player for spot videos`.
- [ ] **Step 2 : écrire le test qui échoue** : `'le plein écran d’une vidéo affiche son lecteur'`, en vérifiant `find.byType(SpotVideoPlayer)`. La lecture elle-même n'est pas testable sans plateforme ; elle est vérifiée sur appareil à la tâche 24.
- [ ] **Step 3 : lancer le test**. Attendu : ÉCHEC.
- [ ] **Step 4 : implémenter.**
- [ ] **Step 5 : lancer le test**. Attendu : SUCCÈS.
- [ ] **Step 6 : commit** `feat(spot): play spot videos in fullscreen viewer`
- [ ] **Step 7 : ajouter `video_player` au README (packages retenus, avec justification)**, puis commit `docs(readme): document video_player`

### Task 16 : Commentaires — liste, ajout, suppression

**Files :**
- Create : `presentation/widgets/comment_list.dart`, `comment_tile.dart`, `comment_composer.dart`, `delete_comment_dialog.dart`, `relative_time.dart`
- Modify : `spot_detail_layout.dart`
- Test : un `_test.dart` par widget

**Interfaces :**
- Produces :
  - `CommentList({required String spotId})` :
    - fait `watch` sur `commentsProvider` et rend une `SliverList.builder` ;
    - affiche l'état vide `none` ;
    - affiche `showMore` si `comments.length >= limit`, qui appelle `CommentsLimit.showMore` ;
    - fait apparaître un nouveau commentaire avec `AnimatedSwitcher` / `SizeTransition`.
  - `CommentTile({required SpotComment comment, required String spotId})` :
    - un `ConsumerWidget` qui fait `watch` sur `spotAuthorProvider(comment.authorId)` ;
    - affiche `AuthorAvatar`, le nom ou `unknownAuthor`, le temps relatif et le texte ;
    - affiche le bouton supprimer (`tooltip: delete`) seulement si l'auteur est l'utilisateur courant.
  - `String formatRelativeTime(DateTime date, DateTime now, Translations t, String locale)` : `justNow` en dessous d'une minute, puis `minutesAgo`, `hoursAgo`, `daysAgo` jusqu'à 7 jours, puis `DateFormat.yMMMd(locale)`.
  - `CommentComposer({required String spotId})` :
    - un `StatefulWidget` qui porte le `TextEditingController` et la `Form` ;
    - une validation en temps réel (`autovalidateMode: onUserInteraction`) : vide après trim → `empty`, plus de 500 caractères → `tooLong(500)` ;
    - un `LoadingButton` relié à `commentComposerControllerProvider`, qui vide le champ en cas de succès ;
    - une erreur affichée en bottom sheet ; le composant est désactivé hors ligne.
  - `showDeleteCommentDialog(BuildContext) → Future<bool>` : confirmation, avec `deleteTitle`, `deleteMessage`, `cancel` et `delete`.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'formatRelativeTime'`, sur chaque seuil, en FR et en EN ;
  - `'affiche Aucun commentaire quand la liste est vide'` ;
  - `'affiche le nom de l’auteur du commentaire'` ;
  - `'Voir plus charge la page suivante'` ;
  - `'refuse un commentaire vide'` ;
  - `'refuse un commentaire de 501 caractères'` ;
  - `'envoie le commentaire trimé puis vide le champ'` ;
  - `'affiche la bottom sheet quand l’envoi échoue'` ;
  - `'désactive l’envoi hors ligne'` ;
  - `'le bouton supprimer n’apparaît que sur mes commentaires'` ;
  - `'supprime après confirmation, rien après annulation'` ;
  - `'un commentaire de 500 caractères sans espace ne déborde pas à 320 px de large'` (Review Focus 2).
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): show spot comments with pagination`. Inclure la liste, la tuile, `relative_time` et leurs tests.
- [ ] **Step 6 : commit** `feat(spot): let users add and delete their comments`

### Task 17 : Layout tablette

**Files :**
- Create : `lib/core/layout/breakpoints.dart`
- Modify : `spot_detail_layout.dart`
- Test : `test/core/layout/breakpoints_test.dart`, `spot_detail_page_test.dart`

**Interfaces :**
- Produces : `enum WindowSize { compact, medium, expanded; static WindowSize fromWidth(double width); }`, avec les seuils `< 600` → compact, `< 840` → medium, sinon expanded.
  - À partir de `expanded`, `SpotDetailLayout` (via `LayoutBuilder`) passe en `Row` : à gauche la galerie fixe (`flex: 1`, sans `SliverAppBar`), à droite le `CustomScrollView` avec les infos, ma note et les commentaires.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'les seuils 599, 600, 839, 840 donnent compact, medium, medium, expanded'` ;
  - `'à 1024 px de large, la galerie et les infos sont côte à côte'`, en comparant les positions `dx` ;
  - `'à 390 px de large, la galerie est au-dessus des infos'`.
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(core): add window size breakpoints`
- [ ] **Step 6 : commit** `feat(spot): adapt spot detail layout to tablets`
- [ ] **Step 7 : documenter `core/layout/` dans `architecture.md` et `ui-guidelines.md`** (section Responsive), puis commit `docs(ui): document breakpoints`

### Task 18 : Liste temporaire sur l'accueil (point d'entrée du Hero)

**Files :**
- Create : `presentation/widgets/spot_list_tile.dart`, `presentation/widgets/recent_spots_list.dart`
- Modify : `lib/home_page.dart`
- Test : `test/features/spot/presentation/widgets/recent_spots_list_test.dart`

**Interfaces :**
- Produces :
  - `RecentSpotsList()` : fait `watch` sur `recentSpotsProvider` et gère les trois états, dont `recent.empty`.
  - `SpotListTile({required Spot spot})` : vignette `Hero(tag: spotMediaHeroTag(spot.id, 0))`, titre, `RatingStars` en lecture seule. Un tap fait `context.push(AppRoutes.spotDetail(id))`.
  - Commentaire d'une ligne dans `home_page.dart` : `// Liste temporaire : remplacée par le flux (§2.2).`

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'affiche les spots récents'` ;
  - `'ouvre la fiche au tap'` ;
  - `'affiche l’état vide'` ;
  - `'un spot sans média affiche un placeholder'` (Review Focus 1).
- [ ] **Step 2 : lancer les tests**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter.**
- [ ] **Step 4 : lancer les tests**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(spot): list recent spots on home as temporary entry point`

### Task 19 : Projet Functions, règles Firestore et leurs tests

**Files :**
- Create : `functions/package.json`, `functions/tsconfig.json`, `functions/.gitignore` (`lib/`, `node_modules/`), `functions/src/index.ts`, `functions/test/rules.test.ts`
- Modify : `firebase.json` (blocs `functions` et `emulators.firestore`), `firestore.rules`, `.github/workflows/ci.yml` (job `functions`)

**Interfaces :**
- Produces :
  - Scripts npm :
    - `build` (`tsc`) ;
    - `test` (`node --test` sur les tests unitaires compilés) ;
    - `test:rules` (`firebase emulators:exec --only firestore 'node --test lib/test/rules.test.js'`) ;
    - `seed` (`tsx scripts/seed.ts`).
  - `engines.node = "22"`. Les versions sont les dernières stables, à vérifier avec `npm view`.
  - Règles :
    - `spots` : lecture pour tout utilisateur connecté, aucune écriture ;
    - `ratings` et `comments` : exactement comme spec §5 « Règles Firestore ».

- [ ] **Step 1 : initialiser le projet `functions/`**, avec un `index.ts` vide et un job CI `functions` (Node 22, `npm ci`, `npm run build`, `npm test`). Puis commit `chore(functions): set up typescript cloud functions project`.
- [ ] **Step 2 : écrire `rules.test.ts`** (`@firebase/rules-unit-testing`), qui doit échouer avec les règles actuelles :
  - lecture d'un spot : autorisée connecté, refusée en visiteur ;
  - écriture d'un spot : refusée ;
  - noter :
    - `5` sur `ratings/{monUid}` → OK ;
    - sur `ratings/{autreUid}` → refusé ;
    - `0` ou `6` → refusé ;
    - `3.5` → refusé ;
    - clé en trop → refusé ;
    - son propre spot → refusé ;
    - suppression d'une note → refusée.
  - commenter :
    - un commentaire valide → OK ;
    - `authorId` d'un autre → refusé ;
    - texte vide ou fait seulement d'espaces → refusé ;
    - 501 caractères → refusé ;
    - modification → refusée ;
    - supprimer le mien → OK ;
    - supprimer celui d'un autre → refusé.
- [ ] **Step 3 : `npm run build && npm run test:rules`**. Attendu : ÉCHEC.
- [ ] **Step 4 : écrire les règles.**
- [ ] **Step 5 : `npm run test:rules`**. Attendu : SUCCÈS.
- [ ] **Step 6 : commit** `feat(spot): add firestore rules for spots, ratings and comments`
- [ ] **Step 7 : documenter dans `backend-firebase.md`** le modèle de données, les règles, le contrat pour le formulaire §2.4 et `npm run test:rules`, puis commit `docs(backend): document spot data model and rules`

### Task 20 : Functions de compteurs (notes, commentaires) et déploiement dev

**Files :**
- Create : `functions/src/aggregates.ts`, `functions/test/aggregates.test.ts`, `scripts/deploy-functions.sh`
- Modify : `functions/src/index.ts`, `CLAUDE.md` (commandes), `docs/backend-firebase.md`

**Interfaces :**
- Produces :
  - `ratingStatsFrom(count: number, average: number | null): { ratingCount: number; averageRating: number }`, avec `average` à `null` → 0, arrondi à 2 décimales.
  - `recomputeRatingStats(db: Firestore, spotId: string): Promise<void>`, qui lance l'agrégation `count()` + `average('value')`.
  - `recomputeCount(db, spotId, collection: 'comments', field: 'commentCount'): Promise<void>`, avec un type élargi à la tâche 22.
  - Une erreur gRPC `NOT_FOUND` (code 5) lors de l'`update` est ignorée, car le spot a été supprimé.
  - Exports :
    - `onRatingWritten` (`onDocumentWritten('spots/{spotId}/ratings/{uid}')`) ;
    - `onCommentCreated` et `onCommentDeleted`.
  - Région : `setGlobalOptions({ region })` avec la localisation de la base Firestore. **Demander cette localisation à Mathis** (Console → Firestore → onglet Base de données) avant l'étape 4.
  - `scripts/deploy-functions.sh dev|prod|all [--dry-run]`, sur le modèle de `deploy-rules.sh`.

- [ ] **Step 1 : écrire les tests qui échouent** :
  - `'ratingStatsFrom sans note donne 0 et 0'` ;
  - `'ratingStatsFrom arrondit 4.3333 à 4.33'`.
- [ ] **Step 2 : `npm run build && npm test`**. Attendu : ÉCHEC.
- [ ] **Step 3 : implémenter `aggregates.ts` et les triggers.**
- [ ] **Step 4 : `npm test`**. Attendu : SUCCÈS.
- [ ] **Step 5 : commit** `feat(functions): recompute spot rating stats on rating write`. Inclure `ratingStatsFrom`, `recomputeRatingStats` et `onRatingWritten`.
- [ ] **Step 6 : commit** `feat(functions): recompute spot comment count`
- [ ] **Step 7 : ajouter le script de déploiement et la commande dans `CLAUDE.md`**, puis commit `chore(functions): add functions deploy script`
- [ ] **Step 8 : déployer sur dev** : `./scripts/deploy-rules.sh dev` puis `./scripts/deploy-functions.sh dev`. Attendu : « Deploy complete! ». Mathis lance ces commandes lui-même si `firebase login` est requis.
- [ ] **Step 9 : documenter dans `backend-firebase.md`** les Functions, la vérification manuelle (noter dans l'app → `averageRating` à jour dans la console) et le déploiement prod comme étape de livraison avec vérification Blaze. Puis commit `docs(backend): document spot cloud functions`.

### Task 21 : Données de démo

**Files :**
- Create : `functions/scripts/seed.ts`
- Modify : `README.md` (procédure de seed), `docs/backend-firebase.md`

**Interfaces :**
- Produces : `npm --prefix functions run seed -- --project spotshare-dev-b6185`.
  - Le script refuse tout autre id de projet avec un message clair.
  - Il utilise `initializeApp({ projectId })` avec les identifiants ADC (`gcloud auth application-default login`).
  - Il écrit, avec des ids fixes `seed-*` :
    - 6 spots, couvrant les 6 catégories, avec de vraies adresses à Paris ;
    - 3 profils `users/seed-user-{1..3}` ;
    - des notes et 3 à 25 commentaires par spot, dont un spot à plus de 20 commentaires pour la pagination ;
    - au moins 2 spots avec une vidéo libre de droits de 60 s maximum, plus sa vignette ;
    - un spot de `seed-user-1` ;
    - les compteurs, recalculés à partir des données écrites.

- [ ] **Step 1 : écrire le script.**
- [ ] **Step 2 : lancer `npm run build`**. Attendu : compilation OK. Puis lancer le seed sur dev. Attendu : les documents sont visibles dans la console, et un second lancement ne crée pas de doublon.
- [ ] **Step 3 : commit** `feat(functions): add dev seed script for demo spots`
- [ ] **Step 4 : documenter dans le README et `backend-firebase.md`**, puis commit `docs(readme): document demo data seeding`

### Task 22 : `favoriteCount` (commits dédiés)

**Files :**
- Modify : `spot.dart`, `spot_dto.dart`, `spot_mapper.dart`, `spot_fixtures.dart`, les tests correspondants, `functions/src/aggregates.ts`, `functions/src/index.ts`, `functions/scripts/seed.ts`, `docs/backend-firebase.md`

**Interfaces :**
- Produces : `Spot.favoriteCount` (`int`), qui vaut 0 si le champ est absent du document. Exports `onFavoriteCreated` et `onFavoriteDeleted` (`spots/{spotId}/favorites/{uid}`). `recomputeCount` accepte `'favorites' → 'favoriteCount'`.

- [ ] **Step 1 : tests qui échouent** : `'lit favoriteCount'` et `'favoriteCount absent vaut 0'` (DTO et mapper).
- [ ] **Step 2 : implémenter côté app**, lancer `fvm flutter test`. Attendu : SUCCÈS. Puis commit `feat(spot): add favorite count to spot model`.
- [ ] **Step 3 : ajouter les triggers**, lancer `npm test` et `./scripts/deploy-functions.sh dev`. Puis commit `feat(functions): recompute spot favorite count`.
- [ ] **Step 4 : faire écrire `favoriteCount: 0` par le seed**, puis commit `feat(functions): seed favorite count`.
- [ ] **Step 5 : documenter dans `backend-firebase.md`** l'emplacement des favoris et le compteur réservé au serveur, puis commit `docs(backend): document favorite count`.

### Task 23 : `geohash` (commits dédiés)

**Files :**
- Modify : comme la tâche 22, plus `functions/src/geohash.ts` et `functions/test/geohash.test.ts`

**Interfaces :**
- Produces :
  - `Spot.geohash` (`String?`) : `null` tant que la function ne l'a pas calculé.
  - `geohashFor(lat: number, lng: number): string`, avec `geohashForLocation` de geofire-common et une précision de 9.
  - `locationChanged(before?: {latitude, longitude}, after?: {latitude, longitude}): boolean`.
  - Export `onSpotWritten` (`onDocumentWritten('spots/{spotId}')`). Il n'écrit rien si le spot est supprimé ou si `location` n'a pas changé, ce qui évite une boucle infinie.

- [ ] **Step 1 : tests qui échouent** côté app : `'lit le geohash'` et `'geohash absent vaut null'`. Puis implémenter, et commit `feat(spot): add geohash to spot model`.
- [ ] **Step 2 : tests qui échouent** côté functions :
  - `'geohashFor(48.8584, 2.2945) vaut u09tunq6q'` : vérifier la valeur exacte avec geofire-common avant de l'écrire dans le test ;
  - `'locationChanged est faux quand la position ne bouge pas'` ;
  - `'locationChanged est vrai à la création'` ;
  - `'locationChanged est faux à la suppression'`.
  
  Puis implémenter, lancer `npm test`, déployer sur dev, et commit `feat(functions): compute spot geohash from location`.
- [ ] **Step 3 : faire écrire le `geohash` par le seed**, puis commit `feat(functions): seed spot geohash`.
- [ ] **Step 4 : documenter dans `backend-firebase.md`** le champ `geohash` réservé au serveur, à utiliser par la carte. Puis commit `docs(backend): document spot geohash`.

### Task 24 : Vérification finale

- [ ] **Step 1 :** lancer `dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze` et `fvm flutter test`. Attendu : aucune issue, tous les tests verts.
- [ ] **Step 2 :** lancer `npm --prefix functions run build && npm --prefix functions test && npm --prefix functions run test:rules`. Attendu : tout vert.
- [ ] **Step 3 : vérifier sur appareil** (`fvm flutter run --flavor dev -t lib/main_dev.dart`), sur le projet dev rempli par le seed :
  - le Hero depuis l'accueil ;
  - le swipe et le zoom de la galerie ;
  - la lecture vidéo et sa pause en changeant de média ;
  - noter, puis voir la moyenne se mettre à jour en quelques secondes grâce à la function ;
  - commenter, supprimer un commentaire, et « voir plus » ;
  - le mode avion sur un spot déjà vu (consultable, actions désactivées) et sur un spot jamais vu (erreur réseau) ;
  - les modes clair et sombre, en FR et en EN ;
  - la largeur tablette, sur un simulateur iPad.
- [ ] **Step 4 : relire la doc** (`architecture.md`, `backend-firebase.md`, `testing.md`, `ui-guidelines.md`, `README.md`, `CLAUDE.md`) par rapport au code final. S'il y a des corrections, les faire dans un commit `docs(...)`.
- [ ] **Step 5 :** ouvrir la PR vers `feat/user-profile`, ou vers `main` si elle a été mergée entre-temps, après un rebase. Remplir le template (captures clair/sombre) et signaler la liste temporaire de l'accueil.
