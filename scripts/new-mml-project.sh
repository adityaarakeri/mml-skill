#!/usr/bin/env bash
# Scaffold a local MML development project.
#
# Usage:
#   scripts/new-mml-project.sh <target-dir> [--example game-of-life] [--no-install]
#
# Creates:
#   <target-dir>/package.json      dev / serve-all / validate scripts (uses @mml-io/mml-cli)
#   <target-dir>/documents/        scene.html (and the example, if requested)
#   <target-dir>/assets/           for .glb / images / audio
#   <target-dir>/README.md
#   <target-dir>/.gitignore
# Then runs npm install unless --no-install is given.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$SKILL_DIR/assets/templates"

TARGET=""
EXAMPLE=""
INSTALL=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --example) EXAMPLE="$2"; shift 2 ;;
    --no-install) INSTALL=0; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "usage: $0 <target-dir> [--example game-of-life] [--no-install]" >&2
  exit 1
fi

if [[ -e "$TARGET" && -n "$(ls -A "$TARGET" 2>/dev/null)" ]]; then
  echo "refusing to scaffold into non-empty directory: $TARGET" >&2
  exit 1
fi

mkdir -p "$TARGET/documents" "$TARGET/assets"
NAME="$(basename "$TARGET")"

CLI_VERSION="$(npm view @mml-io/mml-cli version 2>/dev/null || echo "0.26.1")"

cat > "$TARGET/package.json" <<JSON
{
  "name": "$NAME",
  "private": true,
  "version": "0.1.0",
  "description": "MML (Metaverse Markup Language) documents",
  "scripts": {
    "dev": "mml serve documents/scene.html --assets ./assets",
    "serve-all": "mml serve-dir ./documents --assets ./assets",
    "validate": "mml validate documents/*.html"
  },
  "devDependencies": {
    "@mml-io/mml-cli": "^$CLI_VERSION"
  }
}
JSON

cp "$TEMPLATES/scene.html" "$TARGET/documents/scene.html"
cp "$TEMPLATES/gitignore" "$TARGET/.gitignore"
sed "s/__PROJECT__/$NAME/g" "$TEMPLATES/README.template.md" > "$TARGET/README.md"
touch "$TARGET/assets/.gitkeep"

if [[ -n "$EXAMPLE" ]]; then
  if [[ -f "$TEMPLATES/$EXAMPLE.html" ]]; then
    cp "$TEMPLATES/$EXAMPLE.html" "$TARGET/documents/$EXAMPLE.html"
    echo "added documents/$EXAMPLE.html"
  else
    echo "no template named '$EXAMPLE' in $TEMPLATES" >&2
    exit 1
  fi
fi

if [[ $INSTALL -eq 1 ]]; then
  (cd "$TARGET" && npm install --silent)
fi

echo
echo "Scaffolded $TARGET"
echo "  cd $TARGET && npm run dev      # http://localhost:7079"
echo "  npm run validate"
[[ -n "$EXAMPLE" ]] && echo "  npx mml serve documents/$EXAMPLE.html --assets ./assets"
exit 0
