#!/usr/bin/env bash
# Juggle uninstaller
# https://github.com/JJwilkin/juggle-task

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
BIN_DIR="$HOME/.local/bin"

RED='\033[0;31m'
NC='\033[0m'
removed() { echo -e "${RED}✗${NC} Removed: $*"; }
skipped() { echo "  Skipped (not found): $*"; }

echo ""
echo "Uninstalling Juggle..."
echo ""

# Remove Claude skills
for skill in jt-init jt-update jt-switch; do
  skill_path="$SKILLS_DIR/$skill"
  if [[ -d "$skill_path" ]]; then
    rm -rf "$skill_path"
    removed "$skill_path"
  else
    skipped "$skill_path"
  fi
done

# Remove jt CLI
jt_bin="$BIN_DIR/jt"
if [[ -f "$jt_bin" ]]; then
  rm "$jt_bin"
  removed "$jt_bin"
else
  skipped "$jt_bin"
fi

echo ""
echo "Juggle uninstalled."
echo ""
echo "Note: ~/.jt-config and your tickets directory were NOT removed."
echo "To remove them manually:"
echo "  rm ~/.jt-config"
echo "  rm -rf \$(cat ~/.jt-config 2>/dev/null || echo ~/juggle-tickets)"
