#!/bin/bash
# install.sh — Single-command setup for antigravity-configuration
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/SeraKah-1/antigravity-configuration/main/install.sh)"
# Or after cloning: ./install.sh

set -e

REPO_URL="https://github.com/SeraKah-1/SKILL-AGENT.git"
CONFIG_DIR="$HOME/.antigravity-config"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[antigravity-config]${NC} Installing..."

# 1. Clone or update
if [ -d "$CONFIG_DIR/.git" ]; then
  echo -e "${YELLOW}→${NC} Config already exists. Pulling latest..."
  git -C "$CONFIG_DIR" pull --ff-only origin main 2>/dev/null || echo "  (pull skipped, using local copy)"
else
  echo -e "${YELLOW}→${NC} Cloning config repo..."
  git clone --depth 1 "$REPO_URL" "$CONFIG_DIR"
fi

# 2. Symlink CLAUDE.md to home (for Claude Code / Antigravity)
ln -sf "$CONFIG_DIR/CLAUDE.md" "$HOME/CLAUDE.md"
echo -e "${GREEN}✓${NC} Linked CLAUDE.md → $HOME/CLAUDE.md"

# 3. Symlink as GEMINI.md too (same contract, different agent)
ln -sf "$CONFIG_DIR/CLAUDE.md" "$HOME/GEMINI.md"
echo -e "${GREEN}✓${NC} Linked GEMINI.md → $HOME/GEMINI.md"

# 4. Initialize session_state.md (don't overwrite if exists)
if [ ! -f "$HOME/session_state.md" ]; then
  cp "$CONFIG_DIR/session_state.md" "$HOME/session_state.md"
  echo -e "${GREEN}✓${NC} Created session_state.md"
else
  echo -e "${YELLOW}→${NC} session_state.md already exists, skipping (won't overwrite your logs)"
fi

# 5. Setup .env template if not present
if [ ! -f "$HOME/.env" ]; then
  echo "GITHUB_USERNAME=" > "$HOME/.env"
  echo "GITHUB_PAT=" >> "$HOME/.env"
  echo -e "${GREEN}✓${NC} Created .env template (fill in your credentials)"
else
  echo -e "${YELLOW}→${NC} .env already exists, skipping"
fi

# 6. Symlink token-monitor-dashboard.sh to home
ln -sf "$CONFIG_DIR/token-monitor-dashboard.sh" "$HOME/token-monitor-dashboard.sh"
echo -e "${GREEN}✓${NC} Linked token-monitor-dashboard.sh → $HOME/token-monitor-dashboard.sh"

# 7. Symlink executable scripts to ~/.local/bin for global CLI access
mkdir -p "$HOME/.local/bin"
chmod +x "$CONFIG_DIR/token-monitor.sh" "$CONFIG_DIR/token-monitor-dashboard.sh"
ln -sf "$CONFIG_DIR/token-monitor.sh" "$HOME/.local/bin/token-monitor"
ln -sf "$CONFIG_DIR/token-monitor-dashboard.sh" "$HOME/.local/bin/token-monitor-dashboard"
echo -e "${GREEN}✓${NC} Linked token-monitor → $HOME/.local/bin/token-monitor"
echo -e "${GREEN}✓${NC} Linked token-monitor-dashboard → $HOME/.local/bin/token-monitor-dashboard"

# 8. Setup slash functions in ~/.bash_aliases
BASH_ALIASES="$HOME/.bash_aliases"
echo -e "${YELLOW}→${NC} Configuring slash commands (/token, /dashboard)..."
if [ -f "$BASH_ALIASES" ] && grep -q "Antigravity Token Monitor" "$BASH_ALIASES"; then
  echo -e "${GREEN}✓${NC} Slash commands already configured in ~/.bash_aliases"
else
  cat << 'EOF' >> "$BASH_ALIASES"

# Custom slash functions for Antigravity Token Monitor
/token-monitor() {
    token-monitor "$@"
}

/token-monitor-dashboard() {
    token-monitor-dashboard "$@"
}

# Short aliases
/token() {
    token-monitor "$@"
}

/dashboard() {
    token-monitor-dashboard "$@"
}
EOF
  echo -e "${GREEN}✓${NC} Added slash commands to ~/.bash_aliases"
fi

# 9. Install Antigravity/Claude Code Agent Slash Commands (Skills & Commands)
echo -e "${YELLOW}→${NC} Installing agent slash commands..."
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/commands"
mkdir -p "$HOME/.gemini/skills" "$HOME/.gemini/commands"

cp -rf "$CONFIG_DIR/skills/"* "$HOME/.claude/skills/" 2>/dev/null || true
cp -rf "$CONFIG_DIR/skills/"* "$HOME/.gemini/skills/" 2>/dev/null || true
cp -rf "$CONFIG_DIR/commands/"* "$HOME/.claude/commands/" 2>/dev/null || true
cp -rf "$CONFIG_DIR/commands/"* "$HOME/.gemini/commands/" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Agent slash commands installed in ~/.claude and ~/.gemini"


echo ""
echo -e "${GREEN}Done!${NC} Configuration installed at $CONFIG_DIR"
echo "  CLAUDE.md & GEMINI.md symlinked to $HOME"
echo "  token-monitor-dashboard.sh symlinked to $HOME"
echo "  token-monitor and token-monitor-dashboard symlinked to $HOME/.local/bin"
echo "  Slash commands (/token, /dashboard) configured in ~/.bash_aliases"
echo "  Edit $HOME/.env to add your credentials"
echo ""
echo "To run the token monitor: token-monitor  (or simply: /token)"
echo "To run the real-time token dashboard: token-monitor-dashboard  (or simply: /dashboard)"
echo "To update later: git -C $CONFIG_DIR pull"
echo ""
