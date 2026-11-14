#!/usr/bin/env bash
# Usage: diff-since.sh <base-sha> <out-file>
# Writes the diff from <base-sha> to the current working tree into <out-file>:
# committed and uncommitted changes, plus untracked (not ignored) files shown as new files.
# Read-only on the repo: it does not touch the index or the working tree.
set -euo pipefail

base="${1:?base sha required}"
out="${2:?output file required}"

git rev-parse --verify --quiet "${base}^{commit}" >/dev/null || { echo "diff-since: unknown commit '$base'" >&2; exit 2; }

# Workflow artifacts (plans, reviews) are not code under review.
cd "$(git rev-parse --show-toplevel)"
scope=(-- . ':(exclude)docs/features')

git diff --no-color "$base" "${scope[@]}" > "$out"

# git diff --no-index exits 1 when files differ, which is expected here.
git ls-files --others --exclude-standard -z "${scope[@]}" | while IFS= read -r -d '' f; do
  git diff --no-color --no-index -- /dev/null "$f" >> "$out" || true
done

if [ ! -s "$out" ]; then
  echo "diff-since: empty diff since $base" >&2
  exit 3
fi
echo "diff-since: wrote $(wc -l < "$out") lines to $out"
