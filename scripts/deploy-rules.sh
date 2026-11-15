#!/usr/bin/env bash
# Déploie firestore.rules et storage.rules : ./scripts/deploy-rules.sh dev|prod|all [--dry-run]
# Prérequis : `firebase login`. Voir docs/backend-firebase.md.
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
  firebase deploy --only firestore:rules,storage --project "$project" "${@:2}"
done
