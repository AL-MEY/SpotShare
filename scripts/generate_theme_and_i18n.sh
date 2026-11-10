#!/usr/bin/env bash
# Régénère le code du thème (theme_tailor) et des traductions (slang).
# À lancer après modification de lib/core/theme/ ou des fichiers lib/i18n/*.i18n.yaml.
set -euo pipefail

cd "$(dirname "$0")/.."
fvm dart run build_runner build --delete-conflicting-outputs
