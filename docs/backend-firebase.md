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
- Code des Functions et règles dans un dossier `firebase/` (ou `functions/` à la racine) versionné avec l'app.

## Modèle de données

| Emplacement | Contenu | Écrit par |
|---|---|---|
| Firestore `users/{uid}` | `displayName` (2–30 car.), `bio` (≤ 160), `avatarUrl` (`null` ou URL de téléchargement d'un avatar de son propre dossier Storage : une URL externe est refusée), `updatedAt` (horodatage serveur) | l'utilisateur lui-même |
| Storage `users/{uid}/avatar_<timestamp>.<ext>` | avatar : `jpg`, `jpeg`, `png`, `webp` ou `heic`, type MIME correspondant envoyé explicitement, < 5 Mo | l'utilisateur lui-même |

Le document de profil est public pour tout utilisateur connecté (auteur d'un spot, d'un commentaire) : il ne contient donc rien de privé. L'écriture se fait en `merge` pour ne pas écraser de futurs champs gérés côté serveur (compteurs…), qu'il faudra ajouter à la liste `hasOnly` des règles.

Firestore garde un cache local (activé par défaut sur mobile) : le profil s'affiche hors-ligne s'il a déjà été chargé.

L'écriture est optimiste : `set` met à jour le cache local tout de suite, le flux du profil émet et le routeur part sur l'accueil sans attendre le serveur (hors-ligne compris : l'envoi se fait au retour du réseau). Si le serveur refuse ensuite l'écriture, le document disparaît du cache et le routeur ramène vers la création du profil, sans message d'erreur. D'où une validation client identique aux règles : longueurs comptées en points de code (`UserProfile.lengthOf`), comme `size()` dans les règles.

Limites connues :
- avec un nouvel avatar, l'upload Storage passe avant l'écriture : hors-ligne, le bouton reste en chargement jusqu'au retour du réseau ou à l'échec de l'upload ;
- si l'upload réussit mais que l'écriture échoue, le fichier reste orphelin dans Storage.
- l'ancien avatar n'est jamais supprimé (et `storage.rules` n'autorise pas la suppression) : à ajouter avec la page d'édition du profil, seul endroit où un avatar peut être remplacé.

## Règles de sécurité Firestore / Storage

Fichiers versionnés à la racine : `firestore.rules` et `storage.rules`, référencés par `firebase.json`. Les alias de projets sont dans `.firebaserc` (`dev`, `prod`). Déploiement :

```bash
firebase deploy --only firestore:rules,storage --project dev
firebase deploy --only firestore:rules,storage --project prod
```

Vérifier la compilation sans déployer : ajouter `--dry-run`. Prérequis par projet : base Firestore et Storage créés dans la console (Storage demande le forfait Blaze sur les nouveaux projets).


- Tout est refusé par défaut, puis ouvert explicitement collection par collection.
- Lecture des spots publique pour un utilisateur authentifié ; écriture/suppression réservées à l'auteur (`request.auth.uid == resource.data.authorId`).
- Validation des champs côté règles (types, longueurs, note entre 1 et 5).
- Les règles sont versionnées (`firestore.rules`, `storage.rules`) et testées avec l'émulateur quand c'est possible.

## Secrets et variables d'environnement

- **Aucune clé d'API dans le code Flutter** ni dans git. La clé cartographique est stockée côté serveur (secret Cloud Functions) et l'app appelle une Function qui relaie la requête.
- Valeurs non secrètes mais dépendantes de l'environnement : `--dart-define-from-file=env/dev.json` ; le fichier réel est ignoré par git, un `env/example.json` documente les clés.
- Les fichiers `.env*` sont ignorés par git et non lisibles par l'agent IA.
- Toute nouvelle variable doit être documentée dans le README (section variables d'environnement).

## Côté client

- Firebase n'est appelé que depuis la couche `data` (datasources). Le domaine et la présentation ne voient jamais `FirebaseFirestore`, `DocumentSnapshot`, etc.
- Les `FirebaseException` sont converties en `Failure` dans le repository.
