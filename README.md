# SpotShare

Application sociale Flutter (Android + iOS) de partage de spots : cafés, points de vue, street art…

## Installation

Prérequis : [fvm](https://fvm.app) (la version de Flutter est figée dans `.fvmrc`, 3.47.9).

```bash
fvm install
fvm flutter pub get
fvm dart pub global activate flutterfire_cli   # requis par le build iOS
fvm flutter run --flavor dev -t lib/main_dev.dart
```

Deux flavors : `dev` (`com.almey.spotshare.dev`, projet Firebase `spotshare-dev-b6185`) et `prod` (`com.almey.spotshare`, projet `spotshare-b7f94`). Chaque flavor a son point d'entrée `lib/main_<flavor>.dart`. Fonctionnement et problèmes connus : [docs/flavors.md](docs/flavors.md).

Après modification des traductions (`lib/i18n/*.i18n.yaml`) ou du thème (`lib/core/theme/`), régénérer le code :

```bash
./scripts/generate_theme_and_i18n.sh
```

Les fichiers générés (`*.g.dart`, `*.tailor.dart`) sont versionnés : le projet build sans étape de génération.

## Règles Firebase

Les règles Firestore et Storage sont versionnées (`firestore.rules`, `storage.rules`). Après modification, les déployer (prérequis : `firebase login`) :

```bash
./scripts/deploy-rules.sh dev            # ou prod, ou all pour les deux
./scripts/deploy-rules.sh all --dry-run  # vérifie la compilation sans déployer
```

Détails et modèle de données : [docs/backend-firebase.md](docs/backend-firebase.md).

## Packages retenus

| Package | Rôle |
|---|---|
| `flutter_riverpod` | Gestion d'état (seule solution du projet) |
| `go_router` | Navigation déclarative |
| `google_sign_in` | Connexion Google native (sélecteur de compte Android / iOS) : `firebase_auth` seul ne sait pas ouvrir ce flux sur mobile, il ne fait qu'échanger le jeton obtenu |
| `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions` | Backend : authentification, données temps réel, photos, logique serveur et proxy des API tierces |
| `image_picker` | Photo depuis l'appareil photo ou la galerie, redimensionnée à la source (avatar, photos de spots) : plugin officiel de l'équipe Flutter, sans dépendance de compression en plus |
| `cached_network_image` | Cache disque des images distantes (consultation hors-ligne) |
| `video_player` | Lecture des vidéos de spots en plein écran : package officiel de l'équipe Flutter, aucun lecteur natif à écrire |
| `connectivity_plus` | Détection du réseau pour le mode hors-ligne et la synchronisation différée |
| `shared_preferences` | Persistance locale des préférences (langue choisie) |
| `slang`, `slang_flutter`, `intl`, `flutter_localizations` | Traductions FR/EN typées, générées depuis des fichiers YAML |
| `theme_tailor_annotation` | Tokens de thème typés (espacements, rayons, couleurs hors Material) via `ThemeExtension` |
| dev : `build_runner`, `theme_tailor` | Génération de code du thème (les traductions sont générées par la CLI de `slang`) |
| dev : `mocktail` | Mocks de test sans génération de code |

Choix écartés : `riverpod_generator` (incompatible avec `theme_tailor` 3.x, providers écrits à la main) ; moteur de base locale (Drift, Isar…) encore à trancher.
