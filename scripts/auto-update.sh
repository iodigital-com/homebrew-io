#!/usr/bin/env bash
# Locally replicate the .github/workflows/auto-update.yml logic:
# check each formula's upstream repo for a newer release, update the
# Formula/*.rb file, and open a PR via a feature branch.
#
# Usage: scripts/auto-update.sh [formula-name ...]
#   With no args, checks all formulas below.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# name|repo|asset_type|asset_pattern (asset_pattern empty for source_tarball)
FORMULAS=(
  "claudio|iodigital-com/claudio|source_tarball|"
  "lokex|iodigital-com/lokex|zip|lokex-{version}.zip"
  "figex|iodigital-com/figex|zip|figex-{version}.zip"
)

ONLY_NAMES=("$@")

want() {
  local name="$1"
  [ ${#ONLY_NAMES[@]} -eq 0 ] && return 0
  for n in "${ONLY_NAMES[@]}"; do
    [ "$n" = "$name" ] && return 0
  done
  return 1
}

git fetch origin main >/dev/null 2>&1 || true

for entry in "${FORMULAS[@]}"; do
  IFS='|' read -r NAME REPO ASSET_TYPE ASSET_PATTERN <<<"$entry"
  want "$NAME" || continue

  echo "== $NAME =="
  FORMULA_FILE="Formula/${NAME}.rb"

  LATEST_TAG=$(gh api "repos/${REPO}/releases/latest" --jq '.tag_name')
  LATEST_VERSION="${LATEST_TAG#v}"

  if grep -q '^\s*version\s' "$FORMULA_FILE"; then
    CURRENT_VERSION=$(grep -m1 '^\s*version\s' "$FORMULA_FILE" | sed -E 's/^[^"]*"([^"]+)".*/\1/')
  else
    URL_LINE=$(grep -m1 '^\s*url\s' "$FORMULA_FILE" | sed -E 's/^[^"]*"([^"]+)".*/\1/')
    if echo "$URL_LINE" | grep -q '/download/'; then
      CURRENT_VERSION=$(echo "$URL_LINE" | sed -E 's#.*/download/([^/]+)/.*#\1#')
    else
      CURRENT_VERSION=$(basename "$URL_LINE" | sed 's/\.tar\.gz$//')
    fi
    CURRENT_VERSION="${CURRENT_VERSION#v}"
  fi

  echo "  current: $CURRENT_VERSION  latest: $LATEST_VERSION"

  if [ "$LATEST_VERSION" = "$CURRENT_VERSION" ]; then
    echo "  up to date, skipping"
    continue
  fi

  if [ "$ASSET_TYPE" = "source_tarball" ]; then
    URL="https://github.com/${REPO}/archive/refs/tags/${LATEST_TAG}.tar.gz"
  else
    ASSET_NAME="${ASSET_PATTERN//\{version\}/$LATEST_VERSION}"
    URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/${ASSET_NAME}"
  fi

  echo "  downloading $URL for sha256..."
  SHA=$(curl -sL "$URL" | shasum -a 256 | cut -d ' ' -f1)
  if [ -z "$SHA" ]; then
    echo "  ERROR: failed to compute sha256, skipping $NAME"
    continue
  fi

  BRANCH="auto-update/${NAME}-${LATEST_VERSION}"

  # Make sure we start from a clean, up-to-date main for this formula's branch
  git checkout main >/dev/null
  git pull --ff-only origin main >/dev/null 2>&1 || true

  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git branch -D "$BRANCH" >/dev/null
  fi
  git checkout -b "$BRANCH" >/dev/null

  sed -i '' -E "s|^([[:space:]]*url[[:space:]]+)\".*\"|\\1\"${URL}\"|" "$FORMULA_FILE"
  sed -i '' -E "s|^([[:space:]]*sha256[[:space:]]+)\".*\"|\\1\"${SHA}\"|" "$FORMULA_FILE"
  if grep -q '^\s*version\s' "$FORMULA_FILE"; then
    sed -i '' -E "s|^([[:space:]]*version[[:space:]]+)\".*\"|\\1\"${LATEST_VERSION}\"|" "$FORMULA_FILE"
  fi

  git add "$FORMULA_FILE"
  git commit -m "Update ${NAME} to ${LATEST_VERSION}" >/dev/null
  git push -u origin "$BRANCH"

  gh pr create \
    --title "Update ${NAME} to ${LATEST_VERSION}" \
    --body "Automated update of \`${NAME}\` formula to version \`${LATEST_VERSION}\`." \
    --base main \
    --head "$BRANCH"

  git checkout main >/dev/null
  echo "  PR created for $NAME -> $LATEST_VERSION"
done
