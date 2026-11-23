# Architecture

Clean Architecture découpée par feature. Exigence de la grille : séparation stricte Presentation / Domain / Data avec Repository Pattern.

## Arborescence

```
lib/
├── main.dart                  # bootstrap : Firebase.initializeApp, ProviderScope, runApp
├── app.dart                   # MaterialApp.router, thèmes, localisation
├── core/                      # transverse, sans logique métier de feature
│   ├── error/                 # Failure, exceptions typées
│   ├── network/               # connectivityProvider, isOnlineProvider
│   ├── providers/             # notifiers génériques (SubmitController)
│   ├── router/                # go_router + routes
│   ├── theme/                 # ThemeData clair/sombre + AppTheme (theme_tailor)
│   └── widgets/               # widgets génériques réutilisables (ErrorBottomSheet, LoadingButton…)
├── i18n/                      # fr.i18n.yaml, en.i18n.yaml + strings*.g.dart (slang)
└── features/
    └── <feature>/             # auth, profile, feed, spot, spot_editor, social, map…
        ├── domain/
        │   ├── entities/      # objets métier immuables, Dart pur
        │   ├── repositories/  # interfaces abstraites (contrats)
        │   └── usecases/      # une action métier = une classe
        ├── data/
        │   ├── models/        # DTO (fromJson/toJson, fromFirestore)
        │   ├── mappers/       # DTO <-> entité
        │   ├── datasources/   # remote (Firestore, Functions) et local (DB/cache)
        │   └── repositories/  # implémentations des interfaces du domaine
        └── presentation/
            ├── providers/     # providers / notifiers Riverpod de la feature
            ├── pages/         # écrans routés
            └── widgets/       # widgets propres à la feature
```

Les tests reproduisent la même arborescence sous `test/`.

## Règle de dépendance

```
presentation  ──►  domain  ◄──  data
```

- `domain` : Dart pur. Aucun import de `package:flutter`, `cloud_firestore`, `firebase_*`, ni de `data/`.
- `data` implémente les interfaces de `domain/repositories` et ne connaît pas `presentation`.
- `presentation` ne parle qu'aux use cases (ou aux repositories via leur interface), jamais directement à une datasource ni à Firestore.
- Une feature n'importe pas les couches `data/` ou `presentation/` d'une autre feature. Partager via `core/` ou via le `domain` exposé. Seule exception : le fichier `presentation/providers/<feature>_providers.dart` est l'API d'injection publique d'une feature, une autre feature peut y lire un provider d'infrastructure (ex. `profile` lit `currentUserIdProvider` de `auth`), jamais un widget ni un notifier d'écran.

## Domain

- Entités immuables (`final` + `const` constructor, `copyWith`, égalité par valeur). `freezed` est acceptable si l'équipe l'adopte.
- Value objects pour les types porteurs de règles (ex. `Rating` entre 1 et 5, `GeoPoint`).
- Use case : une classe, une méthode `call(...)`, nommée par l'action (`CreateSpot`, `ToggleFavorite`, `GetNearbySpots`).
- Les erreurs remontent sous forme typée (sealed class `Failure`), jamais des exceptions Firebase brutes. Voir « Erreurs » ci-dessous.

## Data

- DTO séparés des entités : ce sont eux qui connaissent le format Firestore / JSON.
- Le mapper est le seul endroit qui convertit DTO ↔ entité.
- Le repository orchestre remote + local et convertit les exceptions techniques en `Failure`.

## Erreurs

Tout est dans `core/error/` :

- `failure.dart` : sealed class `Failure implements Exception`, Dart pur (importable depuis le domaine). Sous-types : `NetworkFailure`, `UnauthenticatedFailure`, `PermissionFailure`, `NotFoundFailure`, `UnknownFailure`, et pour l'auth `InvalidCredentialsFailure`, `EmailAlreadyUsedFailure`, `WeakPasswordFailure`. La classe étant `sealed`, tout sous-type se déclare dans ce fichier.
- `firebase_failure.dart` : `failureFrom(error)` convertit une exception technique en `Failure`. Les repositories l'appellent dans leur `catch` : `catch (e) { throw failureFrom(e); }`. Les codes propres à une feature (ex. `wrong-password`) se traitent dans son repository avant de retomber sur `failureFrom`.
- `failure_message.dart` : `failure.title(t)` et `failure.message(t)` renvoient les textes localisés (`errors.<type>.title` / `.message` dans les `.i18n.yaml`). Les `switch` sont exhaustifs : un nouveau sous-type ne compile pas sans ses textes.
- `core/widgets/error_bottom_sheet.dart` : `showErrorBottomSheet(context, failure, onRetry: …)` affiche l'erreur à l'utilisateur (icône, titre et message selon le type de `Failure`, bouton « Réessayer » si `onRetry` est fourni). À déclencher depuis un `ref.listen`, pas depuis `build`.

Les `Failure` sont **levées** (`throw`), pas renvoyées dans un `Either`/`Result` : Riverpod les capture dans `AsyncValue.error`, sans package supplémentaire.

## Réseau

- `core/network/connectivity_provider.dart` : `connectivityProvider` expose `Connectivity` (surchargeable en test) et `isOnlineProvider` (`StreamProvider<bool>`) émet l'état initial puis chaque changement. En ligne = au moins un résultat différent de `ConnectivityResult.none`.

## Navigation

`core/router/app_router.dart` expose le `GoRouter` unique via `routerProvider`, consommé par `MaterialApp.router` dans `app.dart`.

- Chemins déclarés dans `AppRoutes` ; naviguer avec `context.go(AppRoutes.xxx)`, jamais avec une chaîne en dur.
- Ajouter un écran = une constante dans `AppRoutes` + un `GoRoute` dans `routerProvider`.
- Route inconnue : `NotFoundPage` (`core/router/not_found_page.dart`).
- Garde dans le `redirect` du `GoRouter`, réévaluée à chaque changement de `authStateProvider` ou de `currentProfileProvider` :
  - visiteur : seulement les routes de `AppRoutes.public` (sinon retour à `welcome`). Une route accessible sans compte s'ajoute à `AppRoutes.public` ;
  - connecté, profil en chargement ou en erreur : `profileLoading` (`ProfileLoadingPage`, avec « Réessayer » en cas d'erreur) ;
  - connecté sans profil : `profileSetup` (`ProfileSetupPage`) ;
  - connecté avec profil : renvoyé vers `home` s'il est sur une route publique ou d'attente du profil.

## Authentification

Feature `auth`, branchée sur Firebase Authentication (fournisseurs et configuration : [backend-firebase.md](backend-firebase.md#authentification)).

- `AuthRepository` (domaine) : `currentUser`, `watchUser()`, `signIn`, `signInWithGoogle`, `signUp`, `signOut`, `sendPasswordResetEmail`. Entité `AppUser` (`id`, `email`).
- `FirebaseAuthRepository` (data) appelle `FirebaseAuth` directement, sans datasource intermédiaire : il n'y a ni cache local ni seconde source à orchestrer. Il convertit les codes d'erreur d'auth en `Failure` avant de retomber sur `failureFrom`.
- `presentation/providers/auth_providers.dart` : `authRepositoryProvider`, `authStateProvider` (`StreamProvider<AppUser?>`), `currentUserIdProvider` (ne notifie que si l'utilisateur change : base des providers qui dépendent de l'utilisateur connecté), un `SubmitController` par écran (`loginControllerProvider`, `signUpControllerProvider`, `passwordResetControllerProvider`, pour que l'erreur d'une page ne soit pas affichée par celle qu'elle recouvre) et un provider par use case (`signInProvider`, `signUpProvider`, `signOutProvider`, `sendPasswordResetEmailProvider`, `signInWithGoogleProvider`).
- La session est persistée par le SDK Firebase : au démarrage, `currentUser` est disponible de façon synchrone, d'où l'absence d'écran de chargement.
- `core/providers/submit_controller.dart` : `SubmitController`, `AsyncNotifier` qui porte l'état initial / loading / data / error d'un formulaire. `submit(action)` exécute le use case passé par la page. Chaque écran déclare son propre provider `AsyncNotifierProvider.autoDispose<SubmitController, void>`.
- Parcours visiteur : `WelcomePage` → « Commencer » → onboarding (`/onboarding`, feature `onboarding`) → `SignUpPage` en dernière étape (`/onboarding/sign-up`, route enfant de l'onboarding : le retour ramène à l'étape précédente). « J'ai déjà un compte » → `LoginPage` → `ForgotPasswordPage` (snackbar de confirmation puis retour). La création de compte ne s'atteint que par l'onboarding, la connexion n'a pas de lien vers l'inscription.
- `SignUpPage` et `LoginPage` proposent e-mail / mot de passe et Google (Google connecte aussi un compte existant). Toutes ces routes sont dans `AppRoutes.public`.
- `presentation/widgets/email_field.dart` et `password_field.dart` : `EmailField` et `PasswordField` (validation localisée, bouton afficher / masquer ; `isNewPassword: true` exige `minPasswordLength` = 6 caractères, le minimum de Firebase).
- Ajouter un fournisseur (Apple) = une méthode sur `AuthRepository` + un use case, comme pour Google. `authStateProvider` et la garde du routeur ne changent pas.

## Profil utilisateur

Feature `profile`, première feature à suivre l'arborescence complète : c'est le modèle à reproduire pour les spots.

```
domain/  entities/user_profile.dart            UserProfile (id, displayName, bio, avatarUrl) + limites de longueur
         repositories/profile_repository.dart  watchProfile(uid), saveProfile(profile, avatarPath:)
         usecases/save_profile.dart            nettoie les champs puis délègue
data/    models/user_profile_dto.dart          format du document Firestore (fromFirestore / toFirestore)
         mappers/user_profile_mapper.dart      DTO <-> entité
         datasources/profile_remote_data_source.dart  seul fichier qui parle à Firestore et Storage
         repositories/firebase_profile_repository.dart orchestre upload + écriture, convertit en Failure
presentation/
         providers/profile_providers.dart      profileRepositoryProvider, currentProfileProvider,
                                               saveProfileProvider, pickedAvatarProvider…
         pages/profile_setup_page.dart         dernière étape de l'onboarding, après l'inscription
         pages/profile_loading_page.dart       attente / erreur du chargement du profil
         widgets/                              un widget par fichier : avatar_picker, image_source_sheet,
                                               display_name_field, bio_field,
                                               profile_load_error
```

- Le profil (`users/{uid}`) est distinct du compte (`AppUser`, Firebase Auth) : l'auth sait *qui* est connecté, le profil est ce que la communauté voit. L'e-mail n'est jamais copié dans le profil.
- `currentProfileProvider` (`StreamProvider<UserProfile?>`) suit le document de l'utilisateur connecté en temps réel. `null` = profil pas encore créé, ce qui déclenche l'étape `ProfileSetupPage` (premier login e-mail **ou** Google).
- Avatar : l'image choisie (`image_picker`, redimensionnée à 512 px) reste un chemin local dans `pickedAvatarProvider` jusqu'à la soumission. `saveProfile` la téléverse puis écrit son URL dans le document. Chaque envoi a un nom unique, donc une nouvelle URL : `CachedNetworkImage` n'affiche jamais un avatar périmé.
- Le domaine ne voit qu'un `String` de chemin local, jamais `File`, `XFile` ni `Reference` Storage.

## Spot

Feature `spot` (fiche détail d'un spot). Les couches `domain`, `data` et les providers (`presentation/providers/spot_providers.dart`) existent ; les écrans viennent ensuite.

```
domain/  entities/spot.dart                    Spot (titre, catégorie, position, médias, tags, auteur, compteurs, moyenne)
         entities/spot_media.dart              SpotMedia scellé : SpotPhoto | SpotVideo
         entities/                             geo_position, spot_category, rating, spot_comment, spot_author
         repositories/spot_repository.dart     watchSpot(id), watchRecentSpots(limit:)
         repositories/rating_repository.dart   watchMyRating(spotId, userId), rate(...)
         repositories/comment_repository.dart  watchComments(spotId, limit:), addComment, deleteComment
         repositories/spot_author_repository.dart  watchAuthor(userId)
         usecases/                             add_comment (trim du texte), delete_comment, rate_spot
data/    models/                               spot_dto, spot_comment_dto, spot_author_dto (format Firestore)
         mappers/                              DTO -> entité ; spot_mapper ignore les médias mal formés
         datasources/                          un fichier par collection : spot, rating, comment, spot_author
         repositories/firebase_*_repository.dart  orchestrent la source et convertissent en Failure
```

- Lecture directe sur Firestore, avec son cache natif hors-ligne : pas de base locale pour l'instant (approche A du design `docs/superpowers/specs/2026-11-23-spot-detail-design.md`, §4). Toutes les lectures sont exposées en `Stream` (les écritures sont des `Future`).
- Spot absent : `NotFoundFailure` si la réponse vient du serveur, `NetworkFailure` si elle vient du cache (on ne sait pas encore s'il existe).
- Média sans `type` ou sans champ requis : ignoré par le mapper, le reste du spot s'affiche. Catégorie inconnue : `SpotCategory.other`.
- Notes : `spots/{id}/ratings/{uid}`, l'id du document est l'uid, donc une seule note par utilisateur par construction. Commentaires : `spots/{id}/comments`, du plus récent au plus ancien.
- Auteur : lu dans `users/{uid}` par la source de données propre à `spot` (`SpotAuthorRemoteDataSource`), sans importer `profile`. Un profil absent du cache est ignoré jusqu'à la réponse du serveur.
- `averageRating`, `ratingCount` et `commentCount` sont écrits côté serveur (Cloud Functions, à venir) : le client ne les modifie jamais.

### Providers

Fichier unique `presentation/providers/spot_providers.dart`, écrit à la main (pas de codegen).

- **Infrastructure** : `spotRepositoryProvider`, `ratingRepositoryProvider`, `commentRepositoryProvider`, `spotAuthorRepositoryProvider` (construits sur `FirebaseFirestore.instance`), et les cas d'usage `rateSpotProvider`, `addCommentProvider`, `deleteCommentProvider`.
- **Lectures** (`StreamProvider.autoDispose`) : `spotProvider(spotId)`, `recentSpotsProvider` (20 derniers spots), `spotAuthorProvider(userId)`, `myRatingProvider(spotId)` (`null` sans utilisateur connecté).
- **Pagination des commentaires** : `commentsLimitProvider(spotId)` (`CommentsLimit`, 20 par page, `showMore()`) ; `commentsProvider(spotId)` le `watch`, donc le flux est rouvert avec une limite plus grande à chaque `showMore()`.
- **Actions** (`AsyncNotifierProvider.autoDispose<SubmitController, void>`) : `rateSpotControllerProvider`, `commentComposerControllerProvider`, `deleteCommentControllerProvider`.

**Mise à jour optimiste (latency compensation)** : Firestore émet l'écriture locale immédiatement dans les flux ouverts, puis l'annule si le serveur la rejette. `myRatingProvider` reste donc un simple `StreamProvider` : pas d'état optimiste géré à la main. L'erreur de l'écriture n'arrive pas par ce flux mais par `rateSpotControllerProvider` (`AsyncError`).

**Lisibles par les autres features** (le feed par exemple) : uniquement les providers d'infrastructure `spotRepositoryProvider`, `ratingRepositoryProvider`, `commentRepositoryProvider`, `spotAuthorRepositoryProvider`, `rateSpotProvider`, `addCommentProvider`, `deleteCommentProvider`. Les providers d'état d'écran et les contrôleurs (`spotProvider`, `recentSpotsProvider`, `myRatingProvider`, `commentsLimitProvider`, `commentsProvider`, `spotAuthorProvider`, les trois `*ControllerProvider`) appartiennent aux écrans de `spot`.

## Offline et persistance locale

> La feature `spot` s'appuie pour l'instant sur le cache natif de Firestore (voir la section Spot).

Exigence : consultation hors-ligne des spots déjà chargés, navigation continue sans réseau, capture photo offline avec synchronisation différée.

Stratégie attendue, implémentée dans les repositories :

1. **Lecture** : la source de vérité exposée à l'UI est la base locale. Le remote rafraîchit le local en arrière-plan (stale-while-revalidate).
2. **Écriture hors-ligne** : la création ou modification est enregistrée localement avec un statut `pendingSync` (photo stockée sur le disque de l'appareil), puis rejouée automatiquement au retour du réseau.
3. **Images** : `CachedNetworkImage` pour le cache disque des images distantes.

Le choix du moteur local (Drift, Isar, Hive…) reste à trancher par l'équipe et à documenter dans le README. La persistance offline native de Firestore aide, mais ne suffit pas pour les photos en attente d'upload.
