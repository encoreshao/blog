#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# deploy.sh — Build and deploy the blog to self-hosted server
#
# Usage:
#   ./deploy.sh [user@host] [remote-path]
#
# Defaults (override via env vars or arguments):
#   DEPLOY_HOST  — SSH host, e.g. username@server.host
#   DEPLOY_PATH  — Remote path, e.g. /var/www/blog
# ---------------------------------------------------------------------------

DEPLOY_HOST="${1:-${DEPLOY_HOST:-username@server.host}}"
DEPLOY_PATH="${2:-${DEPLOY_PATH:-/var/www/production/blog}}"

echo "→ Building..."
npm run build

echo "→ Deploying to ${DEPLOY_HOST}:${DEPLOY_PATH}"
rsync -avz --delete \
  --exclude '.DS_Store' \
  dist/ \
  "${DEPLOY_HOST}:${DEPLOY_PATH}"

echo "✓ Deployed to https://blog.icmoc.com"
