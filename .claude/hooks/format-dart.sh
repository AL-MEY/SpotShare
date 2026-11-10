#!/usr/bin/env bash
# Formate le fichier .dart que Claude vient d'éditer (hook PostToolUse)
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
else
  # Repli sans jq : extraction naïve du champ file_path
  file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi

# Même SDK que le projet (.fvmrc) si fvm est installé, sinon le dart du PATH
if command -v fvm >/dev/null 2>&1; then
  dart_cmd=(fvm dart)
else
  dart_cmd=(dart)
fi

case "$file" in
  *.g.dart|*.freezed.dart|*.mocks.dart|*.tailor.dart) exit 0 ;;
  *.dart)
    [ -f "$file" ] || exit 0
    cd "${CLAUDE_PROJECT_DIR:-$(dirname "$0")/../..}" || exit 0
    # Échec non bloquant, mais affiché sur stderr au lieu d'être masqué
    "${dart_cmd[@]}" format "$file" >/dev/null || echo "format-dart: échec de dart format sur $file" >&2
    ;;
esac
exit 0
