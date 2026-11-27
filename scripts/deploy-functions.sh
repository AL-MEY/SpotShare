#!/usr/bin/env bash
# Déploie les Cloud Functions : ./scripts/deploy-functions.sh dev|prod|all [--dry-run]
# Prérequis : `firebase login`, projet en plan Blaze. Voir docs/backend-firebase.md.
set -euo pipefail

cd "$(dirname "$0")/.."

case ${1:-} in
  dev | prod) projects=("$1") ;;
  all) projects=(dev prod) ;;
  *)
    echo "Erreur : préciser 'dev', 'prod' ou 'all'." >&2
    exit 1
    ;;
esac

for project in "${projects[@]}"; do
  firebase deploy --only functions --project "$project" "${@:2}"
done
