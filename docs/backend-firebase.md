# Backend Firebase

## Services

| Service | Usage |
|---|---|
| Firebase Authentication | email/mot de passe + OAuth, session persistée |
| Cloud Firestore | spots, commentaires, notes, favoris, profils (temps réel) |
| Cloud Storage | photos des spots et avatars |
| Cloud Functions | logique serveur critique + proxy des API tierces (cartographie, géocodage) |

## Configuration

- Configurer via FlutterFire CLI : `flutterfire configure` génère `lib/firebase_options.dart`, `android/app/google-services.json` et `ios/Runner/GoogleService-Info.plist`.
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
