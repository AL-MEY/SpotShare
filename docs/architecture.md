# Architecture

Clean Architecture découpée par feature. Exigence de la grille : séparation stricte Presentation / Domain / Data avec Repository Pattern.

## Arborescence

```
lib/
├── main.dart                  # bootstrap : Firebase.initializeApp, ProviderScope, runApp
├── app.dart                   # MaterialApp.router, thèmes, localisation
├── core/                      # transverse, sans logique métier de feature
│   ├── error/                 # Failure, exceptions typées
│   ├── network/               # état de connectivité
│   ├── router/                # go_router + routes
│   ├── theme/                 # ThemeData clair/sombre + AppTheme (theme_tailor)
│   └── widgets/               # widgets génériques réutilisables (ErrorBottomSheet…)
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
- Une feature n'importe pas les couches `data/` ou `presentation/` d'une autre feature. Partager via `core/` ou via le `domain` exposé.

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

- `failure.dart` : sealed class `Failure implements Exception`, Dart pur (importable depuis le domaine). Sous-types : `NetworkFailure`, `UnauthenticatedFailure`, `PermissionFailure`, `NotFoundFailure`, `UnknownFailure`.
- `firebase_failure.dart` : `failureFrom(error)` convertit une exception technique en `Failure`. Les repositories l'appellent dans leur `catch` : `catch (e) { throw failureFrom(e); }`. Les codes propres à une feature (ex. `wrong-password`) se traitent dans son repository avant de retomber sur `failureFrom`.
- `failure_message.dart` : `failure.title(t)` et `failure.message(t)` renvoient les textes localisés (`errors.<type>.title` / `.message` dans les `.i18n.yaml`). Les `switch` sont exhaustifs : un nouveau sous-type ne compile pas sans ses textes.
- `core/widgets/error_bottom_sheet.dart` : `showErrorBottomSheet(context, failure, onRetry: …)` affiche l'erreur à l'utilisateur (icône, titre et message selon le type de `Failure`, bouton « Réessayer » si `onRetry` est fourni). À déclencher depuis un `ref.listen`, pas depuis `build`.

Les `Failure` sont **levées** (`throw`), pas renvoyées dans un `Either`/`Result` : Riverpod les capture dans `AsyncValue.error`, sans package supplémentaire.

## Navigation

`core/router/app_router.dart` expose le `GoRouter` unique via `routerProvider`, consommé par `MaterialApp.router` dans `app.dart`.

- Chemins déclarés dans `AppRoutes` ; naviguer avec `context.go(AppRoutes.xxx)`, jamais avec une chaîne en dur.
- Ajouter un écran = une constante dans `AppRoutes` + un `GoRoute` dans `routerProvider`.
- Route inconnue : `NotFoundPage` (`core/router/not_found_page.dart`).
- Les gardes (ex. redirection vers la connexion) iront dans le `redirect` du `GoRouter`, en lisant l'état d'auth via `ref`.

## Offline et persistance locale

Exigence : consultation hors-ligne des spots déjà chargés, navigation continue sans réseau, capture photo offline avec synchronisation différée.

Stratégie attendue, implémentée dans les repositories :

1. **Lecture** : la source de vérité exposée à l'UI est la base locale. Le remote rafraîchit le local en arrière-plan (stale-while-revalidate).
2. **Écriture hors-ligne** : la création ou modification est enregistrée localement avec un statut `pendingSync` (photo stockée sur le disque de l'appareil), puis rejouée automatiquement au retour du réseau.
3. **Images** : `CachedNetworkImage` pour le cache disque des images distantes.

Le choix du moteur local (Drift, Isar, Hive…) reste à trancher par l'équipe et à documenter dans le README. La persistance offline native de Firestore aide, mais ne suffit pas pour les photos en attente d'upload.
