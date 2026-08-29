#!/usr/bin/env bash
# Detect drift between this skill and upstream MML.
#
# Usage:
#   scripts/check-upstream.sh            # report only; exit 1 if anything changed
#   scripts/check-upstream.sh --accept   # regenerate elements.md and rewrite upstream.lock
#
# What it checks (all against the latest published @mml-io/mml-cli version on npm):
#   1. mml.xsd        the element/attribute schema  -> elements.md is regenerated from it
#   2. events.d.ts    event payload typings         -> diff printed; events.md is hand-written
#   3. mml-cli README CLI flags and ports           -> diff printed; local-dev.md is hand-written
#   4. mml-starter-project HEAD                     -> commit change reported
#
# Anything under "needs a human" must be reconciled by hand, then run with --accept.
# MML is 0.x so every minor bump can be breaking; treat any change as worth reading.

set -euo pipefail
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK="$SKILL_DIR/upstream.lock"
ACCEPT=0; [[ "${1:-}" == "--accept" ]] && ACCEPT=1
# shellcheck disable=SC1090
source "$LOCK"

WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
sha() { sha256sum "$1" | cut -c1-16; }

latest="$(npm view @mml-io/mml-cli version)"
echo "pinned CLI: $cli_npm_version   latest on npm: $latest"

git clone -q --depth 1 --branch "v$latest" "$mml_repo" "$WORK/mml" 2>/dev/null \
  || git clone -q --depth 1 "$mml_repo" "$WORK/mml"
git clone -q --depth 1 "$starter_repo" "$WORK/starter"

new_commit="$(git -C "$WORK/mml" rev-parse HEAD)"
XSD="$WORK/mml/packages/schema/src/schema-src/mml.xsd"
EVT="$WORK/mml/packages/schema/src/schema-src/events.d.ts"
CLI="$WORK/mml/packages/mml-cli/README.md"
changed=0

report() { echo; echo "== $1"; }

if [[ "$(sha "$XSD")" != "$sha_mml_xsd" ]]; then
  changed=1; report "mml.xsd changed (elements/attributes). Regenerable."
  git -C "$WORK/mml" show "$mml_commit:packages/schema/src/schema-src/mml.xsd" > "$WORK/old.xsd" 2>/dev/null \
    && diff -u "$WORK/old.xsd" "$XSD" | grep -E '^[+-].*(element name|attribute name|enumeration value)' | head -60 || true
  if [[ $ACCEPT -eq 1 ]]; then
    python3 "$SKILL_DIR/scripts/generate-elements-reference.py" "$XSD"
  fi
fi

if [[ "$(sha "$EVT")" != "$sha_events_dts" ]]; then
  changed=1; report "events.d.ts changed. NEEDS A HUMAN: update references/events.md"
  git -C "$WORK/mml" show "$mml_commit:packages/schema/src/schema-src/events.d.ts" > "$WORK/old.dts" 2>/dev/null \
    && diff -u "$WORK/old.dts" "$EVT" || true
fi

if [[ "$(sha "$CLI")" != "$sha_cli_readme" ]]; then
  changed=1; report "mml-cli README changed. NEEDS A HUMAN: check references/local-dev.md and SKILL.md workflow"
  git -C "$WORK/mml" show "$mml_commit:packages/mml-cli/README.md" > "$WORK/old.cli" 2>/dev/null \
    && diff -u "$WORK/old.cli" "$CLI" || true
fi

new_starter="$(git -C "$WORK/starter" rev-parse HEAD)"
if [[ "$new_starter" != "$starter_commit" ]]; then
  changed=1; report "mml-starter-project moved $starter_commit -> $new_starter. Check local-dev.md server section."
fi

# Behavioural smoke test: do the templates still validate with the latest CLI?
report "validating templates with @mml-io/mml-cli@$latest"
mkdir -p "$WORK/v"; cp "$SKILL_DIR"/assets/templates/*.html "$WORK/v/"
if ! (cd "$WORK" && npx -y "@mml-io/mml-cli@$latest" validate v/*.html); then
  changed=1; echo "TEMPLATES FAIL VALIDATION with $latest. NEEDS A HUMAN."
fi

if [[ $changed -eq 0 ]]; then echo; echo "No upstream drift."; exit 0; fi

if [[ $ACCEPT -eq 1 ]]; then
  cat > "$LOCK" <<LOCK
# Upstream sources this skill was built against. Updated by scripts/check-upstream.sh --accept
mml_repo=$mml_repo
mml_commit=$new_commit
mml_version=$latest
cli_npm_version=$latest
sha_mml_xsd=$(sha "$XSD")
sha_events_dts=$(sha "$EVT")
sha_cli_readme=$(sha "$CLI")
starter_repo=$starter_repo
starter_commit=$new_starter
LOCK
  echo; echo "upstream.lock updated to $latest. Review the NEEDS A HUMAN items above before committing."
  exit 0
fi
echo; echo "Drift detected. Review, fix hand-written references, then rerun with --accept."
exit 1
