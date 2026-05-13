#!/usr/bin/env bash
# Juggle installer
# https://github.com/JJwilkin/juggle

set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
BIN_DIR="$HOME/.local/bin"
JT_CONFIG="$HOME/.jt-config"
DEFAULT_TICKETS_DIR="$HOME/juggle-tickets"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}!${NC} $*"; }

echo ""
echo "Installing Juggle..."
echo ""

# Detect script location (works whether run via curl | bash or directly)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# 1. Install Claude Code skills
mkdir -p "$SKILLS_DIR"
for skill in jt-init jt-update jt-switch; do
  mkdir -p "$SKILLS_DIR/$skill"
  cp "$SCRIPT_DIR/skills/$skill/SKILL.md" "$SKILLS_DIR/$skill/SKILL.md"
  info "Skill installed: $SKILLS_DIR/$skill/SKILL.md"
done

# 2. Install jt CLI
mkdir -p "$BIN_DIR"
cp "$SCRIPT_DIR/bin/jt" "$BIN_DIR/jt"
chmod +x "$BIN_DIR/jt"
info "CLI installed:   $BIN_DIR/jt"

# 3. Add ~/.local/bin to PATH if not already present
add_to_path() {
  local rc_file="$1"
  local path_line='export PATH="$HOME/.local/bin:$PATH"'
  if [[ -f "$rc_file" ]] && grep -q '\.local/bin' "$rc_file"; then
    return 0
  fi
  if [[ -f "$rc_file" ]]; then
    echo "" >> "$rc_file"
    echo "# juggle (jt)" >> "$rc_file"
    echo "$path_line" >> "$rc_file"
    info "Added ~/.local/bin to PATH in $rc_file"
  fi
}

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  add_to_path "$HOME/.zshrc"
  add_to_path "$HOME/.bashrc"
  warning "~/.local/bin was added to PATH. Restart your shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 4. Create default config and tickets dir if not set
if [[ ! -f "$JT_CONFIG" ]]; then
  echo "$DEFAULT_TICKETS_DIR" > "$JT_CONFIG"
  mkdir -p "$DEFAULT_TICKETS_DIR"
  info "Tickets dir:     $DEFAULT_TICKETS_DIR"
  info "Config:          $JT_CONFIG"
else
  existing=$(cat "$JT_CONFIG")
  info "Config exists:   $existing (unchanged)"
fi

echo ""
echo "Juggle installed successfully."
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to load the new skills"
echo "  2. Run /jt-init <ticket-id> inside Claude Code to create your first ticket"
echo "  3. Run 'jt help' in your terminal for CLI usage"
echo ""
echo "Docs: https://github.com/JJwilkin/juggle"
