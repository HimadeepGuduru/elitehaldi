#!/bin/bash
# ─────────────────────────────────────────────────────────
#  EliteHaldi — new-version.sh
#  Creates a new dev version from the current stable version
#
#  Usage:
#    ./scripts/new-version.sh v21
#    ./scripts/new-version.sh v21 "Added UV index tracker, fixed Zone B bug"
# ─────────────────────────────────────────────────────────

set -e

NEW_VER="$1"
NOTES="$2"

if [ -z "$NEW_VER" ]; then
  echo "❌  Usage: ./scripts/new-version.sh v21"
  exit 1
fi

# Read current stable from versions.json
STABLE=$(python3 -c "import json; d=json.load(open('versions.json')); print(d['stable'])")
STABLE_FILE="versions/${STABLE}.html"

if [ ! -f "$STABLE_FILE" ]; then
  echo "❌  Stable file not found: $STABLE_FILE"
  exit 1
fi

NEW_FILE="versions/${NEW_VER}.html"

if [ -f "$NEW_FILE" ]; then
  echo "⚠️   $NEW_FILE already exists. Overwrite? [y/N]"
  read -r confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
fi

# Copy stable → new version
cp "$STABLE_FILE" "$NEW_FILE"

# Update the <title> tag in the new file
sed -i "s|EliteHaldi Command Center v[0-9]*|EliteHaldi Command Center ${NEW_VER}|g" "$NEW_FILE"

# Add new version entry to versions.json
TODAY=$(date +%Y-%m-%d)
python3 - <<PYEOF
import json

with open('versions.json') as f:
    d = json.load(f)

# Don't duplicate
if any(v['version'] == '${NEW_VER}' for v in d['versions']):
    # Update existing
    for v in d['versions']:
        if v['version'] == '${NEW_VER}':
            v['status'] = 'dev'
            v['tag'] = 'dev'
            v['date'] = '${TODAY}'
else:
    d['versions'].append({
        "version": "${NEW_VER}",
        "file": "versions/${NEW_VER}.html",
        "date": "${TODAY}",
        "status": "dev",
        "tag": "dev",
        "changelog": [
            "${NOTES:-Work in progress — branched from ${STABLE}}"
        ]
    })

# Point latest to new version (but keep stable unchanged)
d['latest'] = '${NEW_VER}'

with open('versions.json', 'w') as f:
    json.dump(d, f, indent=2)

print('✅  versions.json updated')
PYEOF

echo ""
echo "✅  New dev version created!"
echo "   Source  : $STABLE_FILE"
echo "   New file: $NEW_FILE"
echo ""
echo "📝  Next steps:"
echo "   1. Edit $NEW_FILE with your changes"
echo "   2. Test at: open versions/${NEW_VER}.html"
echo "   3. When ready → run: ./scripts/promote.sh ${NEW_VER}"
echo ""
