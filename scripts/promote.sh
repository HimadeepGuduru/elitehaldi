#!/bin/bash
# ─────────────────────────────────────────────────────────
#  EliteHaldi — promote.sh
#  Promotes a dev version to STABLE
#  The old stable is kept as "archived" — never deleted
#
#  Usage:
#    ./scripts/promote.sh v21
# ─────────────────────────────────────────────────────────

set -e

PROMOTE_VER="$1"

if [ -z "$PROMOTE_VER" ]; then
  echo "❌  Usage: ./scripts/promote.sh v21"
  exit 1
fi

PROMOTE_FILE="versions/${PROMOTE_VER}.html"

if [ ! -f "$PROMOTE_FILE" ]; then
  echo "❌  File not found: $PROMOTE_FILE"
  echo "    Run ./scripts/new-version.sh ${PROMOTE_VER} first"
  exit 1
fi

# Get current stable
OLD_STABLE=$(python3 -c "import json; d=json.load(open('versions.json')); print(d['stable'])")

if [ "$OLD_STABLE" = "$PROMOTE_VER" ]; then
  echo "⚠️   $PROMOTE_VER is already stable!"
  exit 0
fi

echo ""
echo "🚀  Promoting $PROMOTE_VER → STABLE"
echo "   Old stable: $OLD_STABLE (will be archived, not deleted)"
echo ""
echo "Continue? [y/N]"
read -r confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

TODAY=$(date +%Y-%m-%d)

python3 - <<PYEOF
import json

with open('versions.json') as f:
    d = json.load(f)

# Archive old stable
for v in d['versions']:
    if v['version'] == '${OLD_STABLE}':
        v['status'] = 'archived'
        v['tag'] = 'archived'

# Promote new version
for v in d['versions']:
    if v['version'] == '${PROMOTE_VER}':
        v['status'] = 'stable'
        v['tag'] = 'production'
        v['date'] = '${TODAY}'

d['stable'] = '${PROMOTE_VER}'
d['latest'] = '${PROMOTE_VER}'

with open('versions.json', 'w') as f:
    json.dump(d, f, indent=2)

print('✅  versions.json updated')
PYEOF

echo ""
echo "✅  $PROMOTE_VER is now STABLE!"
echo "   Old stable ($OLD_STABLE) is archived at versions/${OLD_STABLE}.html"
echo ""
echo "📦  Deploy:"
echo "   Netlify / GitHub Pages → just git push"
echo "   Manual → run: ./scripts/deploy.sh"
echo ""
