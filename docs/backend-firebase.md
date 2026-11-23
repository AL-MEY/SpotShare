# Backend Firebase

## Services

| Service | Usage |
|---|---|
| Firebase Authentication | email/mot de passe + OAuth, session persistée |
| Cloud Firestore | spots, commentaires, notes, favoris, profils (temps réel) |
| Cloud Storage | photos des spots et avatars |
| Cloud Functions | logique serveur critique + proxy des API tierces (cartographie, géocodage) |

## Authentification

| Fournisseur | État | Côté client |
|---|---|---|
| E-mail / mot de passe | implémenté | `firebase_auth` seul |
| Google | implémenté | `google_sign_in` ouvre le sélecteur de compte, puis `signInWithCredential(GoogleAuthProvider.credential(idToken: …))` |
| Apple | prévu | `signInWithProvider(AppleAuthProvider())` de `firebase_auth` ; à confirmer sur appareil avant d'ajouter `sign_in_with_apple` |

Réinitialisation du mot de passe : `sendPasswordResetEmail` envoie l'e-mail Firebase (modèle à personnaliser dans la console des deux projets). Un e-mail inconnu réussit en silence pour ne pas révéler l'existence d'un compte ; l'UI affiche donc toujours le même message de confirmation.

Chaque fournisseur s'active dans la console **des deux projets** (dev et prod). Pour Google sur Android : `google_sign_in` lit le client web dans `google-services.json`, et le projet Firebase doit connaître les empreintes SHA-1/SHA-256 de chaque flavor (un `oauth_client` de `client_type` 1 apparaît alors dans le fichier). Ajouter les empreintes dans la console, puis régénérer la config avec `scripts/flutterfire-config.sh <flavor>`. Côté iOS, le client OAuth et l'URL scheme sont déjà branchés par configuration de build (voir [flavors.md](flavors.md#ios)). Pour Apple : capability « Sign in with Apple » sur les deux bundle ids ; côté Android, Service ID et clé Apple renseignés dans la console Firebase. Apple impose de proposer « Sign in with Apple » dès qu'une app iOS propose une connexion tierce comme Google.

L'annulation par l'utilisateur n'est pas une erreur : `signInWithGoogle` se termine sans rien faire. Une erreur non reconnue devient `UnknownFailure` et sa cause est écrite dans la console de debug (`failureFrom`). Cas restant à traiter : `account-exists-with-different-credential` (même e-mail déjà utilisé par un autre fournisseur), e-mail masqué par Apple.

Architecture côté app : [architecture.md](architecture.md#authentification).

## Configuration

- Un projet Firebase par flavor (`spotshare-dev-b6185` pour dev, `spotshare-b7f94` pour prod). La config de chaque flavor se génère avec `scripts/flutterfire-config.sh <flavor>`, jamais à la main : voir [flavors.md](flavors.md).
- Ces fichiers contiennent des identifiants **publics** de projet Firebase : ils sont versionnés pour que le correcteur puisse builder. La sécurité repose sur les règles et l'App Check, pas sur leur secret.
- Code des Cloud Functions (TypeScript, Node 22) dans `functions/`, règles à la racine (`firestore.rules`, `storage.rules`), le tout versionné avec l'app.

## Modèle de données

| Emplacement | Contenu | Écrit par |
|---|---|---|
| Firestore `users/{uid}` | `displayName` (2–30 car.), `bio` (≤ 160), `avatarUrl` (`null` ou URL de téléchargement d'un avatar de son propre dossier Storage : une URL externe est refusée), `updatedAt` (horodatage serveur) | l'utilisateur lui-même |
| Storage `users/{uid}/avatar_<timestamp>.<ext>` | avatar : `jpg`, `jpeg`, `png`, `webp` ou `heic`, type MIME correspondant envoyé explicitement, < 5 Mo | l'utilisateur lui-même |

Le document de profil est public pour tout utilisateur connecté (auteur d'un spot, d'un commentaire) : il ne contient donc rien de privé. L'écriture se fait en `merge` pour ne pas écraser de futurs champs gérés côté serveur (compteurs…), qu'il faudra ajouter à la liste `hasOnly` des règles.

### Spots, notes, commentaires, favoris

| Emplacement | Contenu | Écrit par |
|---|---|---|
| Firestore `spots/{spotId}` | `title` (3–80), `description` (0–2000, texte brut), `category` (`cafe`, `viewpoint`, `streetArt`, `restaurant`, `park`, `other`), `address` (1–200), `location` (geopoint), `media` (1–10 éléments `type`, `url`, `thumbnailUrl?`, `durationMs?`), `tags` (0–10), `authorId`, `createdAt` | formulaire de création (§2.4), pas encore écrit |
| idem, champs serveur | `geohash`, `averageRating`, `ratingCount`, `commentCount`, `favoriteCount` | Cloud Functions uniquement |
| Firestore `spots/{spotId}/ratings/{uid}` | `value` (entier 1–5), `updatedAt` (horodatage serveur) | l'utilisateur `uid` |
| Firestore `spots/{spotId}/comments/{commentId}` | `authorId`, `text` (1–500, non vide après trim), `createdAt` (horodatage serveur) | l'auteur du commentaire |
| Firestore `spots/{spotId}/favorites/{uid}` | `createdAt` | le propriétaire `uid` (fonctionnalité favoris, règles encore fermées) |

L'id d'une note ou d'un favori est l'uid : une seule note par personne par construction. Nom et avatar des auteurs sont lus dans `users/{uid}`, jamais recopiés.

#### Contrat pour le formulaire de création (§2.4)

- À la création d'un spot, les compteurs `averageRating`, `ratingCount`, `commentCount` et `favoriteCount` valent `0`.
- `geohash` est absent : la Cloud Function `onSpotWritten` le calcule à partir de `location`.
- Un client n'écrit jamais `geohash` ni les compteurs, et ne peut pas les modifier : `spots` est aujourd'hui fermé en écriture, les règles de création devront garder cette interdiction.

Firestore garde un cache local (activé par défaut sur mobile) : le profil s'affiche hors-ligne s'il a déjà été chargé.

L'écriture est optimiste : `set` met à jour le cache local tout de suite, le flux du profil émet et le routeur part sur l'accueil sans attendre le serveur (hors-ligne compris : l'envoi se fait au retour du réseau). Si le serveur refuse ensuite l'écriture, le document disparaît du cache et le routeur ramène vers la création du profil, sans message d'erreur. D'où une validation client identique aux règles : longueurs vérifiées côté client (`UserProfile.lengthOf`, qui compte des points de code). Attention : `size()` dans les règles compte des unités UTF-16, donc un emoji vaut 2 côté règles et 1 côté client ; un texte proche de la limite avec des emojis peut passer la validation client et être refusé par le serveur.

Limites connues :
- avec un nouvel avatar, l'upload Storage passe avant l'écriture : hors-ligne, le bouton reste en chargement jusqu'au retour du réseau ou à l'échec de l'upload ;
- si l'upload réussit mais que l'écriture échoue, le fichier reste orphelin dans Storage.
- l'ancien avatar n'est jamais supprimé (et `storage.rules` n'autorise pas la suppression) : à ajouter avec la page d'édition du profil, seul endroit où un avatar peut être remplacé.

## Règles de sécurité Firestore / Storage

Fichiers versionnés à la racine : `firestore.rules` et `storage.rules`, référencés par `firebase.json`. Les alias de projets sont dans `.firebaserc` (`dev`, `prod`). Déploiement avec `scripts/deploy-rules.sh` (lance `firebase deploy --only firestore:rules,storage` sur chaque projet) :

```bash
./scripts/deploy-rules.sh dev            # ou prod, ou all pour les deux
./scripts/deploy-rules.sh all --dry-run  # vérifie la compilation sans déployer
```

Déployer d'abord sur dev et vérifier sur l'app avant prod. Prérequis par projet : base Firestore et Storage créés dans la console (Storage demande le forfait Blaze sur les nouveaux projets).


- Tout est refusé par défaut, puis ouvert explicitement collection par collection.
- `spots/{spotId}` : lecture pour tout utilisateur connecté, **aucune écriture client** (la création relèvera du formulaire §2.4).
- `spots/{spotId}/favorites/{uid}` : fermé (lecture et écriture refusées) tant que ses règles ne sont pas écrites.
- `spots/{spotId}/ratings/{uid}` : lecture pour tout connecté ; création/modification seulement si `uid == request.auth.uid`, clés exactes `value` et `updatedAt`, `value` entier de 1 à 5, `updatedAt == request.time`, et l'auteur du spot ne peut pas noter son propre spot (lecture du spot par `get()`). Pas de suppression.
- `spots/{spotId}/comments/{commentId}` : lecture pour tout connecté ; création si le spot existe, `authorId == request.auth.uid`, clés exactes `authorId`, `text`, `createdAt`, texte de 1 à 500 caractères et non vide après `trim()`, `createdAt == request.time` ; suppression de son propre commentaire seulement ; pas de modification.
- Les règles sont versionnées et testées avec l'émulateur Firestore (voir ci-dessous).

### Tester les règles

`functions/test/rules.test.ts` (`@firebase/rules-unit-testing`, `node --test`) vérifie chaque règle ci-dessus, cas autorisés et refusés. Aucun projet réel n'est touché : l'émulateur tourne sous l'id `demo-spotshare`.

```bash
cd functions
npm ci
npm run build
npm run test:rules
```

Prérequis : `firebase-tools` installé et un JDK 21 ou plus **dans le `PATH`** (pas seulement `JAVA_HOME`), par exemple :

```bash
export PATH="$(/usr/libexec/java_home -v 21)/bin:$PATH"
```

Le script `test:rules` appelle `"$npm_node_execpath"` car le binaire autonome de `firebase` injecte son propre `node` dans la commande lancée : il faut donc passer par `npm run test:rules`, pas copier la commande à la main.

Limites des chaînes dans les règles : `size()` compte des unités UTF-16 (comme `String.length` de Dart, utilisé par le composeur de commentaires : cohérent) et `trim()` ne retire que les espaces ASCII ; l'app trime avec Dart avant d'envoyer. `npm test` ne lance que les tests unitaires des Functions (le job CI `functions` fait `npm ci`, `npm run build`, `npm test`) ; les tests de règles, qui démarrent l'émulateur, restent en local.

## Cloud Functions

Code dans `functions/src` (TypeScript, 2nde génération, Node 22). Les compteurs d'un spot sont **dénormalisés** : seules les Functions les écrivent (les règles n'accordent au client aucune écriture sur ces champs du spot).

| Function | Déclencheur | Effet |
|---|---|---|
| `onRatingWritten` | écriture de `spots/{spotId}/ratings/{uid}` | recalcule `ratingCount` et `averageRating` (arrondi à 2 décimales, 0 sans note) |
| `onCommentCreated` / `onCommentDeleted` | création / suppression de `spots/{spotId}/comments/{commentId}` | recalcule `commentCount` |
| `onFavoriteCreated` / `onFavoriteDeleted` | création / suppression de `spots/{spotId}/favorites/{uid}` | recalcule `favoriteCount` |

`favoriteCount` est réservé au serveur : le client crée ou supprime seulement son document `favorites/{uid}`, jamais le compteur.

Chaque Function **recompte** via une requête d'agrégation (`count()`, `average('value')`) au lieu d'incrémenter : le résultat reste juste même si un événement est rejoué ou arrive dans le désordre. Si le spot a été supprimé entre-temps (erreur gRPC `NOT_FOUND`, code 5), l'écriture est ignorée.

**Région** : `REGION` dans `functions/src/index.ts` (`europe-west1`) doit correspondre à la localisation de la base Firestore (`eur3` → `europe-west1`). À vérifier dans la Console : Firestore → onglet Base de données. Une région différente fonctionne mais ajoute de la latence et peut échouer au déploiement.

### Déploiement et vérification

Le déploiement des Functions exige le plan Blaze et `firebase login` sur le compte de l'équipe.

```bash
./scripts/deploy-rules.sh dev
./scripts/deploy-functions.sh dev     # attendu : « Deploy complete! »
```

Vérification manuelle sur dev : noter un spot depuis l'app, puis dans la Console (Firestore → `spots/{id}`) contrôler que `ratingCount` et `averageRating` sont à jour ; ajouter puis supprimer un commentaire et contrôler `commentCount`.

La prod est une étape de livraison : vérifier d'abord que le projet prod est en plan Blaze, puis `./scripts/deploy-rules.sh prod` et `./scripts/deploy-functions.sh prod`.

## Données de démo

Script : `functions/scripts/seed.ts` (données dans `seed_data.ts`, testées par `npm test` : types de média reconnus par l'app) (`npm --prefix functions run seed -- --project spotshare-dev-b6185`, identifiants `gcloud auth application-default login`). Il écrit avec l'Admin SDK, donc sans passer par les règles.

| Données | Contenu |
|---|---|
| `users/seed-user-{1..3}` | profils sans avatar |
| `spots/seed-spot-{1..6}` | une catégorie chacun, adresses réelles à Paris ; `seed-spot-1` et `seed-spot-6` appartiennent à `seed-user-1` ; 3 spots avec une vidéo (clips libres de droits de 5 à 10 s, dont Big Buck Bunny en CC-BY (Blender Foundation), vignette picsum) |
| `ratings/{uid}` | chaque utilisateur note les spots dont il n'est pas l'auteur |
| `comments/seed-comment-<spot>-<n>` | de 3 à 25 par spot (`seed-spot-1` : 25) |

Les compteurs `averageRating`, `ratingCount` et `commentCount` sont calculés dans le script avec `ratingStatsFrom` (le même calcul que les Functions), `favoriteCount` vaut 0. Les ids étant fixes, un second lancement réécrit les mêmes documents. Les commentaires d'un lancement précédent qui n'existent plus dans le script ne sont pas supprimés.

Le script ne s'exécute que pour `spotshare-dev-b6185`. Pour le tester sans toucher au projet réel, le lancer dans l'émulateur Firestore (la variable `FIRESTORE_EMULATOR_HOST` est alors prise en compte par `firebase-admin`). Avec le binaire `firebase` autonome, appeler `node` explicitement :

```bash
cd functions
firebase emulators:exec --only firestore --project spotshare-dev-b6185 \
  "$(which node) node_modules/tsx/dist/cli.mjs scripts/seed.ts --project spotshare-dev-b6185"
```

## Secrets et variables d'environnement

- **Aucune clé d'API dans le code Flutter** ni dans git. La clé cartographique est stockée côté serveur (secret Cloud Functions) et l'app appelle une Function qui relaie la requête.
- Valeurs non secrètes mais dépendantes de l'environnement : `--dart-define-from-file=env/dev.json` ; le fichier réel est ignoré par git, un `env/example.json` documente les clés.
- Les fichiers `.env*` sont ignorés par git et non lisibles par l'agent IA.
- Toute nouvelle variable doit être documentée dans le README (section variables d'environnement).

## Côté client

- Firebase n'est appelé que depuis la couche `data` (datasources). Le domaine et la présentation ne voient jamais `FirebaseFirestore`, `DocumentSnapshot`, etc.
- Les `FirebaseException` sont converties en `Failure` dans le repository.
