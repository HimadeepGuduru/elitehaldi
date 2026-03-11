#!/bin/bash
# ─────────────────────────────────────────────────────────
#  EliteHaldi — deploy.sh
#  Deploy to GitHub Pages or Netlify (auto-detects)
#  Can also do a manual rsync to a VPS
#
#  Usage:
#    ./scripts/deploy.sh               # auto-detect
#    ./scripts/deploy.sh github        # force GitHub Pages
#    ./scripts/deploy.sh netlify       # force Netlify CLI
#    ./scripts/deploy.sh manual        # rsync to VPS
# ─────────────────────────────────────────────────────────

set -e

MODE="${1:-auto}"

# ── Read stable version ──────────────────────────────────
STABLE=$(python3 -c "import json; d=json.load(open('versions.json')); print(d['stable'])")
LATEST=$(python3 -c "import json; d=json.load(open('versions.json')); print(d['latest'])")
echo ""
echo "🌿  EliteHaldi Deploy"
echo "   Stable : $STABLE"
echo "   Latest : $LATEST"
echo ""

# ── AUTO-DETECT ──────────────────────────────────────────
if [ "$MODE" = "auto" ]; then
  if git remote -v 2>/dev/null | grep -q "github.com"; then
    MODE="github"
  elif command -v netlify &>/dev/null; then
    MODE="netlify"
  else
    MODE="github"
    echo "ℹ️  Defaulting to GitHub Pages (git push)"
  fi
fi

# ── GITHUB PAGES ─────────────────────────────────────────
if [ "$MODE" = "github" ]; then
  echo "🚀  Deploying via GitHub Pages..."
  git add -A
  git commit -m "deploy: promote $STABLE as stable [$(date +%Y-%m-%d)]" || echo "  (nothing new to commit)"
  git push origin main
  echo ""
  echo "✅  Pushed to GitHub!"
  echo "   GitHub Pages URL: https://$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git//' | tr '[:upper:]' '[:lower:]' | sed 's|/|.github.io/|')"
  echo "   (Pages may take 1-2 minutes to rebuild)"

# ── NETLIFY ──────────────────────────────────────────────
elif [ "$MODE" = "netlify" ]; then
  echo "🚀  Deploying via Netlify CLI..."
  netlify deploy --prod --dir .
  echo ""
  echo "✅  Deployed to Netlify!"

# ── MANUAL VPS ───────────────────────────────────────────
elif [ "$MODE" = "manual" ]; then
  # Edit these:
  VPS_USER="ubuntu"
  VPS_HOST="your-vps-ip-or-domain.com"
  VPS_PATH="/var/www/elitehaldi"

  echo "🚀  Deploying via rsync to $VPS_HOST..."
  rsync -avz --delete \
    --exclude '.git' \
    --exclude 'scripts' \
    --exclude '.github' \
    ./ "${VPS_USER}@${VPS_HOST}:${VPS_PATH}/"
  echo ""
  echo "✅  Deployed to VPS at $VPS_HOST:$VPS_PATH"
fi

echo ""
echo "🔗  Version Panel: your-url/?panel=true"
echo "🔗  Stable direct: your-url/versions/${STABLE}.html"
echo "🔗  Latest direct: your-url/versions/${LATEST}.html"
echo ""
