#!/usr/bin/env bash
# Install (symlink) this skill into the skill directories used by Claude Code, Codex,
# Antigravity, and OpenCode.
#
# Usage:
#   scripts/install.sh            # global: ~/.claude, ~/.codex, ~/.gemini/antigravity, ~/.config/opencode, ~/.agents
#   scripts/install.sh --project  # project-local: .claude/skills, .codex/skills, .agent/skills, .opencode/skills, .agents/skills
#   scripts/install.sh --copy     # copy instead of symlink (Windows without symlink support, or to freeze a version)
#
# Every agent reads the same SKILL.md format; they just look in different folders.
# Symlinks mean one edit updates all of them.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
MODE="global"
COPY=0

for arg in "$@"; do
  case "$arg" in
    --project) MODE="project" ;;
    --copy) COPY=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
  esac
done

if [[ "$MODE" == "global" ]]; then
  TARGETS=(
    "$HOME/.claude/skills"              # Claude Code
    "$HOME/.codex/skills"               # OpenAI Codex CLI
    "$HOME/.gemini/antigravity/skills"  # Google Antigravity
    "$HOME/.config/opencode/skills"     # OpenCode
    "$HOME/.agents/skills"              # shared location several tools also scan
  )
else
  TARGETS=(
    ".claude/skills"
    ".codex/skills"
    ".agent/skills"      # Antigravity workspace
    ".opencode/skills"
    ".agents/skills"
  )
fi

for dir in "${TARGETS[@]}"; do
  mkdir -p "$dir"
  dest="$dir/$SKILL_NAME"
  if [[ -e "$dest" || -L "$dest" ]]; then
    rm -rf "$dest"
  fi
  if [[ $COPY -eq 1 ]]; then
    cp -R "$SKILL_DIR" "$dest"
    echo "copied   -> $dest"
  else
    ln -s "$SKILL_DIR" "$dest"
    echo "linked   -> $dest"
  fi
done

echo
echo "Done. Restart the agent (or start a new session) so it re-scans its skills folder."
