#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# deploy.sh — Build and deploy the blog to self-hosted server
#
# Usage:
#   ./deploy.sh [user@host] [remote-path]
#
# Defaults (override via env vars or arguments):
#   DEPLOY_HOST  — SSH host, e.g. root@ranbot.online
#   DEPLOY_PATH  — Remote path, e.g. /var/www/blog
# ---------------------------------------------------------------------------

DEPLOY_HOST="${1:-${DEPLOY_HOST:-root@ranbot.online}}"
DEPLOY_PATH="${2:-${DEPLOY_PATH:-/var/www/production}}"

echo "→ Building..."
npm run build

echo "→ Deploying to ${DEPLOY_HOST}:${DEPLOY_PATH}"
rsync -avz --delete \
  --exclude '.DS_Store' \
  dist/ \
  "${DEPLOY_HOST}:${DEPLOY_PATH}"

echo "✓ Deployed to https://blog.icmoc.com"
