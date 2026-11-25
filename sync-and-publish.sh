#!/usr/bin/env bash
# Re-syncs this repo's content/ folder from the live Obsidian vault, then
# commits and pushes so GitHub Actions rebuilds and redeploys the site.
#
# What gets published is controlled by content-exclude.txt (same syntax
# as .gitignore) -- edit that file to include or exclude anything, then
# re-run this script.
#
# Usage: ./sync-and-publish.sh ["optional commit message"]
set -euo pipefail

VAULT_DIR="$HOME/ObsidianVault/SecondBrain"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MSG="${1:-Sync vault content: $(date '+%Y-%m-%d %H:%M')}"

echo "Syncing content from $VAULT_DIR ..."
rsync -av --delete \
  --exclude-from="$REPO_DIR/content-exclude.txt" \
  "$VAULT_DIR/" "$REPO_DIR/content/"

cd "$REPO_DIR"
git add content
if git diff --cached --quiet; then
  echo "No content changes to publish."
  exit 0
fi

git commit -m "$MSG"
git push origin main
echo "Pushed. GitHub Actions will rebuild and redeploy the site shortly."
