#!/usr/bin/env bash
# Verify the agent roster against the live model registry and the review
# skill: every agents/*.md `model:` value must exist in `opencode models`,
# and every executor agent must appear in the Roster section of
# skills/review-orchestration/SKILL.md (verifier-*/researcher-* are
# intentionally absent — single-model tiers, not reviewers).
# Variants (#low, #max, ...) are not checked: `opencode models` does not
# list them.
set -u
cd "$(dirname "$0")/.." || exit 2

skill=skills/review-orchestration/SKILL.md
fail=0

if ! models=$(opencode models 2>/dev/null); then
  echo "ERROR: 'opencode models' failed — is the opencode service running?" >&2
  exit 2
fi

echo "== agent model IDs vs registry =="
for f in agents/*.md; do
  id=$(sed -n 's/^model: *//p' "$f" | head -n1 | sed 's/#.*//')
  if [ -z "$id" ]; then
    echo "FAIL $f: no model: field"
    fail=1
  elif printf '%s\n' "$models" | grep -qxF -- "$id"; then
    echo "ok   $f -> $id"
  else
    echo "FAIL $f -> $id (missing from registry)"
    fail=1
  fi
done

echo
echo "== executor agents vs $skill Roster section =="
for f in agents/*.md; do
  name=$(basename "$f" .md)
  case "$name" in verifier-*|researcher-*) continue ;; esac
  if grep -qF -- "$name" "$skill"; then
    echo "ok   $name"
  else
    echo "FAIL $name missing from the Roster section"
    fail=1
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "roster OK"
else
  echo "roster check FAILED" >&2
fi
exit "$fail"
