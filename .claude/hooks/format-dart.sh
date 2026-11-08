#!/usr/bin/env bash
# Formate le fichier .dart que Claude vient d'éditer (hook PostToolUse)
input=$(cat)

if command -v jq >/dev/null 2>&1; then
  file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
else
  # Repli sans jq : extraction naïve du champ file_path
  file=$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi

case "$file" in
  *.g.dart|*.freezed.dart|*.mocks.dart) exit 0 ;;
  *.dart) [ -f "$file" ] && dart format "$file" >/dev/null ;;
esac
exit 0
