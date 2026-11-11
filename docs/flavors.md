# Flavors

L'app existe en deux variantes, ou *flavors*, qui partagent le même code mais pas les mêmes données. Chaque flavor a son identifiant d'app et son projet Firebase, donc les deux s'installent côte à côte sur un téléphone et un compte de test ne touche jamais la prod.

| Flavor | Usage | Bundle id / applicationId | Nom affiché | Projet Firebase | Point d'entrée |
|---|---|---|---|---|---|
| `dev` | développement, tests, démo | `com.almey.spotshare.dev` | SpotShare Dev | `spotshare-dev-b6185` | `lib/main_dev.dart` |
| `prod` | stores, correcteur | `com.almey.spotshare` | SpotShare | `spotshare-b7f94` | `lib/main_prod.dart` |

## Lancer et builder

Il n'y a pas de build « sans flavor » : on précise toujours le flavor **et** son point d'entrée, qui doivent correspondre.

```bash
fvm flutter run --flavor dev -t lib/main_dev.dart
fvm flutter build appbundle --release --flavor prod -t lib/main_prod.dart
fvm flutter build ipa --release --flavor prod -t lib/main_prod.dart
```

`--flavor` choisit la configuration native (identifiant, nom, fichier Firebase natif). `-t` choisit le code Dart lancé, donc les options Firebase. Un mélange des deux (`--flavor prod -t lib/main_dev.dart`) donnerait une app prod branchée sur le Firebase de dev.

Quand des valeurs par environnement apparaîtront, elles iront dans `env/<flavor>.json`, injectées avec `--dart-define-from-file` (voir [backend-firebase.md](backend-firebase.md)).

## Comment c'est câblé

### Dart

- `lib/main.dart` contient `runMainApp(FirebaseOptions)` : le démarrage commun (Firebase, langue, `ProviderScope`, `runApp`). Il n'a pas de `main()`.
- `lib/main_<flavor>.dart` n'a qu'une ligne : il appelle `runMainApp` avec le `DefaultFirebaseOptions` de son fichier `lib/firebase_options_<flavor>.dart`. C'est le seul endroit où le flavor est choisi côté Dart.
- Pour connaître le flavor au runtime, la constante `appFlavor` de `package:flutter/services.dart` vaut `'dev'` ou `'prod'`. Ne pas s'en servir pour brancher de la logique métier : une différence de comportement entre environnements passe par la config (`env/<flavor>.json`).

### Android

Dans `android/app/build.gradle.kts`, `productFlavors` déclare `dev` (suffixe `.dev`) et `prod`. Chaque flavor définit la ressource `app_name`, utilisée comme label dans `AndroidManifest.xml`. Avec AGP 9, ça suppose `buildFeatures { resValues = true }`.

Le plugin `com.google.gms.google-services` lit automatiquement `android/app/src/<flavor>/google-services.json` selon le flavor buildé.

### iOS

iOS ne connaît pas les flavors : Flutter les associe à un **scheme** et à des **build configurations** nommées `<Build>-<flavor>`.

- 6 configurations : `Debug`, `Profile` et `Release`, chacune en `-dev` et `-prod`. Les configurations d'origine (`Debug`, `Release`, `Profile`) et le scheme `Runner` ont été supprimés : un build sans flavor échoue au lieu de produire une app hybride.
- 2 schemes partagés, `dev` et `prod`, dans `ios/Runner.xcodeproj/xcshareddata/xcschemes/`.
- Par configuration : `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME` (lu par `CFBundleDisplayName` dans `Info.plist`) et un fichier `ios/Flutter/<Build>-<flavor>.xcconfig` qui inclut `Generated.xcconfig`.
- Par configuration aussi : `GOOGLE_CLIENT_ID` et `REVERSED_CLIENT_ID` (connexion Google), lus par `GIDClientID` et l'URL scheme de `Info.plist`. Ils recopient `CLIENT_ID` et `REVERSED_CLIENT_ID` du `GoogleService-Info.plist` du flavor : à remettre à jour dans Xcode si ce fichier est régénéré avec un autre client OAuth.
- Les plugins passent par Swift Package Manager (pas de `Podfile`). La version iOS minimale est 15.0, imposée par Firebase.

Le SDK Firebase natif cherche aussi un `GoogleService-Info.plist` dans l'app : sans lui, certains cas échouent, comme le démarrage à froid depuis une notification. La build phase `FlutterFire: "flutterfire bundle-service-file"` copie le bon fichier (`ios/flavors/<flavor>/`) dans l'app à chaque build, d'après l'entrée de la configuration courante dans `firebase.json`.

### Firebase

`scripts/flutterfire-config.sh <flavor>` (re)génère toute la config d'un flavor : il enregistre les apps dans le projet Firebase si besoin, puis écrit les fichiers ci-dessous. Il complète aussi `firebase.json` pour que `Profile-<flavor>` et `Release-<flavor>` aient leur entrée, sinon l'archive iOS échoue.

| Fichier | Lu par |
|---|---|
| `lib/firebase_options_<flavor>.dart` | Dart (`main_<flavor>.dart`) |
| `android/app/src/<flavor>/google-services.json` | plugin Gradle google-services |
| `ios/flavors/<flavor>/GoogleService-Info.plist` | SDK natif iOS, via la build phase FlutterFire |
| `firebase.json` | build phase FlutterFire et `flutterfire configure` |

Ces fichiers contiennent des identifiants publics : ils sont versionnés. Ne jamais les éditer à la main, relancer le script.

## Règles

- Tout run, build ou configuration d'IDE précise `--flavor` et le `-t` correspondant.
- Le flavor ne se choisit qu'à deux endroits : `--flavor` pour le natif, `main_<flavor>.dart` pour le Dart. Aucun `if (prod)` dispersé dans le code.
- Les développements et tests manuels se font en `dev`. `prod` ne sert qu'aux builds de livraison.
- Toute config Firebase côté console (fournisseurs d'auth, règles, index) se fait **dans les deux projets**. Les réglages liés à l'identifiant se font pour chaque bundle id : empreintes SHA Android, URL scheme Google sur iOS, App ID Apple pour `.dev`.
- Modifier un identifiant, un nom ou un projet Firebase impose de mettre à jour ce tableau, `scripts/flutterfire-config.sh`, puis de relancer le script.

## Prérequis machine

- `fvm` et la version épinglée dans `.fvmrc`.
- Pour builder iOS : Xcode 26.2 ou plus (exigé par Firebase iOS 13), et `fvm dart pub global activate flutterfire_cli`, puisque la build phase FlutterFire l'appelle.
- Pour relancer `scripts/flutterfire-config.sh` : en plus, `firebase login` avec un compte qui a accès aux deux projets.

## Problèmes connus

| Symptôme | Cause et solution |
|---|---|
| `Product Flavor dev contains custom resource values, but the feature is disabled` | AGP 9 : il manque `buildFeatures { resValues = true }`. |
| `Invalid manifest` sur `firebase-ios-sdk` | Xcode trop ancien : passer en 26.2 ou plus. |
| `no versions of 'firebase-ios-sdk' match the requirement …` alors que la version existe | Cache Swift Package Manager périmé : `git -C ~/Library/Caches/org.swift.swiftpm/repositories/firebase-ios-sdk-<hash> fetch --tags`, puis relancer le build. |
| `Requested entity already exists` pendant le script, alors que la console ne liste aucune app | Une app avec ce bundle id a été supprimée il y a moins de 30 jours. La restaurer dans Paramètres du projet → apps supprimées. |
| `429 RESOURCE_EXHAUSTED` pendant le script | Quota de création d'apps Firebase dépassé : attendre une minute et relancer. |
| `could not find a valid GoogleService-Info.plist` dans les logs Xcode | La configuration buildée n'a pas d'entrée dans `firebase.json` : relancer `scripts/flutterfire-config.sh <flavor>`. |
| Build Android qui casse d'un coup (`Unresolved reference 'compilerOptions'`) | Un Flutter global d'une autre version a re-migré `android/`. Pointer l'IDE sur `.fvm/flutter_sdk`, puis `fvm flutter create --platforms=android .`. |

## Ajouter un flavor (ex. `preprod`)

1. Android : un bloc dans `productFlavors`.
2. iOS : les 3 configurations `<Build>-preprod` (dupliquées depuis `-dev`), leurs xcconfig, le scheme `preprod`, le bundle id et `APP_DISPLAY_NAME`.
3. Dart : `lib/main_preprod.dart`.
4. Firebase : un bloc dans `scripts/flutterfire-config.sh`, puis lancer le script.
5. Mettre à jour cette doc et le README.
