#!/usr/bin/env bash
# Génère les fichiers de config Firebase d'un flavor : ./scripts/flutterfire-config.sh dev|prod
# Prérequis : `firebase login` et `fvm dart pub global activate flutterfire_cli`
# (~/.pub-cache/bin dans le PATH). Voir docs/flavors.md.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $# -eq 0 ]]; then
  echo "Erreur : préciser le flavor, 'dev' ou 'prod'." >&2
  exit 1
fi

# FlutterFire cherche la config iOS par nom de build configuration (ex. Release-dev).
# On recopie l'entrée générée pour Debug-<flavor> vers Profile/Release-<flavor>,
# sinon les archives Release échouent. Idempotent.
normalize_ios_build_configs() {
  python3 - firebase.json <<'PY'
import json, sys

path = sys.argv[1]
data = json.load(open(path))
ios = data['flutter']['platforms']['ios']['buildConfigurations']
build_types = ['Debug', 'Profile', 'Release']

templates = {}
for name, cfg in list(ios.items()):
    for build_type in build_types:
        prefix = build_type + '-'
        if name.startswith(prefix):
            templates.setdefault(name[len(prefix):], cfg)

for flavor, template in templates.items():
    for build_type in build_types:
        entry = dict(template)
        entry['uploadDebugSymbols'] = build_type == 'Release'
        ios[f'{build_type}-{flavor}'] = entry

json.dump(data, open(path, 'w'), separators=(',', ':'))
print(f'firebase.json : configs iOS -> {sorted(ios)}')
PY
}

case $1 in
  dev)
    flutterfire configure --yes \
      --project=spotshare-dev-b6185 \
      --platforms=android,ios \
      --out=lib/firebase_options_dev.dart \
      --ios-bundle-id=com.almey.spotshare.dev \
      --ios-build-config=Debug-dev \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --android-package-name=com.almey.spotshare.dev \
      --android-out=android/app/src/dev/google-services.json
    ;;
  prod)
    flutterfire configure --yes \
      --project=spotshare-b7f94 \
      --platforms=android,ios \
      --out=lib/firebase_options_prod.dart \
      --ios-bundle-id=com.almey.spotshare \
      --ios-build-config=Debug-prod \
      --ios-out=ios/flavors/prod/GoogleService-Info.plist \
      --android-package-name=com.almey.spotshare \
      --android-out=android/app/src/prod/google-services.json
    ;;
  *)
    echo "Erreur : flavor inconnu '$1', utiliser 'dev' ou 'prod'." >&2
    exit 1
    ;;
esac

normalize_ios_build_configs
