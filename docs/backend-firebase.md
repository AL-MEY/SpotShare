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
| Google | prévu | package `google_sign_in` à ajouter, puis `signInWithCredential(GoogleAuthProvider.credential(...))` |
| Apple | prévu | `signInWithProvider(AppleAuthProvider())` de `firebase_auth` ; à confirmer sur appareil avant d'ajouter `sign_in_with_apple` |

Réinitialisation du mot de passe : `sendPasswordResetEmail` envoie l'e-mail Firebase (modèle à personnaliser dans la console des deux projets). Un e-mail inconnu réussit en silence pour ne pas révéler l'existence d'un compte ; l'UI affiche donc toujours le même message de confirmation.

Chaque fournisseur s'active dans la console **des deux projets** (dev et prod). Pour Google : empreintes SHA-1/SHA-256 Android de chaque flavor, puis régénérer la config avec `scripts/flutterfire-config.sh <flavor>`. Côté iOS, le client OAuth et l'URL scheme sont déjà branchés par configuration de build (voir [flavors.md](flavors.md#ios)). Pour Apple : capability « Sign in with Apple » sur les deux bundle ids ; côté Android, Service ID et clé Apple renseignés dans la console Firebase. Apple impose de proposer « Sign in with Apple » dès qu'une app iOS propose une connexion tierce comme Google.

Cas à traiter à l'implémentation : annulation par l'utilisateur (ne pas afficher d'erreur), `account-exists-with-different-credential` (même e-mail déjà utilisé par un autre fournisseur), e-mail masqué par Apple.

Architecture côté app : [architecture.md](architecture.md#authentification).

## Configuration

- Un projet Firebase par flavor (`spotshare-dev-b6185` pour dev, `spotshare-b7f94` pour prod). La config de chaque flavor se génère avec `scripts/flutterfire-config.sh <flavor>`, jamais à la main : voir [flavors.md](flavors.md).
- Ces fichiers contiennent des identifiants **publics** de projet Firebase : ils sont versionnés pour que le correcteur puisse builder. La sécurité repose sur les règles et l'App Check, pas sur leur secret.
- Code des Functions et règles dans un dossier `firebase/` (ou `functions/` à la racine) versionné avec l'app.

## Règles de sécurité Firestore / Storage

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
