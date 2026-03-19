#!/usr/bin/env bash
# figma-plugin — one-command setup
# Usage: bash setup.sh [path/to/your/project]

set -euo pipefail

# ── colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }
step() { echo -e "\n${BOLD}${CYAN}[$1/5]${NC} ${BOLD}$2${NC}"; }

SETTINGS="$HOME/.claude/settings.json"

echo ""
echo -e "${BOLD}figma-plugin setup${NC}"
echo "────────────────────────────────────────"
echo "Installs everything into your project folder."
echo ""

# ── Step 1: Node.js ───────────────────────────────────────────────────────────
step 1 "Checking Python + uv (required for speckit)"

if ! command -v uv &>/dev/null; then
  err "uv is not installed."
  echo "   Install it with:  curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "   Then re-run this script."
  exit 1
fi

PYTHON_OK=false
for py in python3 python; do
  if command -v "$py" &>/dev/null; then
    PY_VER=$("$py" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    MAJOR=$(echo "$PY_VER" | cut -d. -f1)
    MINOR=$(echo "$PY_VER" | cut -d. -f2)
    if [ "$MAJOR" -eq 3 ] && [ "$MINOR" -ge 11 ]; then
      PYTHON_OK=true
      ok "Python $PY_VER"
      break
    fi
  fi
done

if [ "$PYTHON_OK" = false ]; then
  err "Python 3.11+ is required for speckit."
  echo "   Install it from https://www.python.org or via your package manager."
  exit 1
fi

ok "uv $(uv --version 2>/dev/null | head -1)"

# Node is still needed for @playwright/mcp
if ! command -v node &>/dev/null; then
  err "Node.js is not installed (required for @playwright/mcp)."
  echo "   Install it from https://nodejs.org (LTS version) then re-run this script."
  exit 1
fi

NODE_VER=$(node -e "process.stdout.write(process.versions.node)")
MAJOR=$(echo "$NODE_VER" | cut -d. -f1)

if [ "$MAJOR" -lt 18 ]; then
  err "Node.js $NODE_VER found — version 18 or higher is required."
  echo "   Update from https://nodejs.org then re-run."
  exit 1
fi

ok "Node.js $NODE_VER"

# ── Step 2: Project folder ────────────────────────────────────────────────────
step 2 "Project folder"

# Accept folder as first argument, or ask interactively
if [ "${1:-}" != "" ]; then
  PROJECT_DIR="$1"
else
  echo "   Where is your project? This is the folder where you'll run /speckit and /design."
  echo "   Leave blank to use the current directory ($(pwd))"
  echo ""
  read -r -p "   Project path: " INPUT_DIR
  PROJECT_DIR="${INPUT_DIR:-$(pwd)}"
fi

# Expand ~ and resolve to absolute path
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
PROJECT_DIR="$(cd "$(dirname "$PROJECT_DIR")" 2>/dev/null && pwd)/$(basename "$PROJECT_DIR")" || true

if [ ! -d "$PROJECT_DIR" ]; then
  read -r -p "   '$PROJECT_DIR' doesn't exist. Create it? [Y/n] " CREATE_DIR
  CREATE_DIR="${CREATE_DIR:-Y}"
  if [[ "$CREATE_DIR" =~ ^[Yy]$ ]]; then
    mkdir -p "$PROJECT_DIR"
    ok "Created $PROJECT_DIR"
  else
    err "Project folder is required. Exiting."
    exit 1
  fi
fi

ok "Project: $PROJECT_DIR"

EXTENSION_DIR="$PROJECT_DIR/.tools/figma-bridge"

# ── Step 3: Install npm packages locally ──────────────────────────────────────
step 3 "Installing speckit + @playwright/mcp"

# Install speckit via uv (Python tool)
echo "   Installing speckit (spec-kit) via uv..."
if uv tool install specify-cli --from git+https://github.com/github/spec-kit.git --quiet 2>/dev/null; then
  ok "speckit installed  →  specify"
else
  warn "speckit install failed — try manually: uv tool install specify-cli --from git+https://github.com/github/spec-kit.git"
fi

echo "   Installing @playwright/mcp globally..."
npm install -g @playwright/mcp@0.0.68 --silent
ok "@playwright/mcp installed  →  $(npm root -g)/../bin/playwright-mcp"

# ── Step 4: Figma token + Claude Code settings ────────────────────────────────
step 4 "Figma access token + Claude Code settings"

echo "   Your token is saved to ~/.claude/settings.json and never shared."
echo "   Get one at: Figma → Account Settings → Security → Personal access tokens"
echo ""

if [ "${FIGMA_ACCESS_TOKEN:-}" != "" ]; then
  echo -e "   Token found in environment: ${CYAN}${FIGMA_ACCESS_TOKEN:0:8}...${NC}"
  read -r -p "   Use this token? [Y/n] " USE_EXISTING
  USE_EXISTING="${USE_EXISTING:-Y}"
  if [[ "$USE_EXISTING" =~ ^[Yy]$ ]]; then
    TOKEN="$FIGMA_ACCESS_TOKEN"
  else
    read -r -p "   Paste your Figma access token: " TOKEN
  fi
else
  read -r -p "   Paste your Figma access token: " TOKEN
fi

if [ -z "$TOKEN" ]; then
  warn "No token entered — skipping. Add FIGMA_ACCESS_TOKEN to $SETTINGS manually later."
  TOKEN=""
fi

mkdir -p "$(dirname "$SETTINGS")"

node - "$SETTINGS" "$TOKEN" <<'EOF'
const fs    = require('fs');
const file  = process.argv[2];
const token = process.argv[3];

let settings = {};
if (fs.existsSync(file)) {
  try { settings = JSON.parse(fs.readFileSync(file, 'utf8')); } catch (_) {}
}

if (token) {
  settings.env = settings.env || {};
  settings.env.FIGMA_ACCESS_TOKEN = token;
}

settings.mcpServers = settings.mcpServers || {};
settings.mcpServers['design-playwright'] = {
  command: 'playwright-mcp',
  args: ['--extension']
};

fs.writeFileSync(file, JSON.stringify(settings, null, 2) + '\n');
EOF

[ -n "$TOKEN" ] && ok "FIGMA_ACCESS_TOKEN saved to $SETTINGS" \
                || warn "FIGMA_ACCESS_TOKEN not set — add it to $SETTINGS manually"
ok "design-playwright MCP server → playwright-mcp --extension"

# ── Step 5: Figma Bridge Chrome extension ─────────────────────────────────────
step 5 "Figma Bridge Chrome extension  →  $EXTENSION_DIR"

mkdir -p "$(dirname "$EXTENSION_DIR")"

if [ -d "$EXTENSION_DIR/.git" ]; then
  echo "   Already cloned — pulling latest..."
  git -C "$EXTENSION_DIR" pull --quiet && ok "Up to date" || warn "Pull failed — using existing version"
else
  echo "   Cloning into $EXTENSION_DIR ..."
  if git clone --quiet https://github.com/lukaskellerstein/figma-bridge "$EXTENSION_DIR"; then
    ok "Cloned to $EXTENSION_DIR"
  else
    err "Clone failed. Check your internet connection and try again."
    echo "   Run manually: git clone https://github.com/lukaskellerstein/figma-bridge \"$EXTENSION_DIR\""
    EXTENSION_DIR="$PROJECT_DIR/.tools/figma-bridge  (clone manually)"
  fi
fi

echo ""
echo -e "   ${YELLOW}Manual step required — load the extension in Chrome:${NC}"
echo ""
echo "   1. Open Chrome and go to:  chrome://extensions"
echo "   2. Enable 'Developer mode' (top-right toggle)"
echo "   3. Click 'Load unpacked'"
echo "   4. Select this folder: $EXTENSION_DIR"
echo "   5. Confirm 'Figma Bridge' appears and is enabled"
echo ""

if command -v cmd.exe &>/dev/null; then
  cmd.exe /c start "" "chrome://extensions" 2>/dev/null || true
elif command -v open &>/dev/null; then
  open -a "Google Chrome" "chrome://extensions" 2>/dev/null || true
fi

read -r -p "   Press Enter once you've loaded the extension (or skip with Enter now)..."

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}Setup complete!${NC}"
echo "────────────────────────────────────────"
echo ""
echo -e "  ${GREEN}✓${NC} Node.js $NODE_VER"
echo -e "  ${GREEN}✓${NC} speckit          $(command -v specify 2>/dev/null || echo 'specify (check uv tool list)')"
echo -e "  ${GREEN}✓${NC} @playwright/mcp  $(command -v playwright-mcp 2>/dev/null || echo 'playwright-mcp (global)')"
[ -n "$TOKEN" ] && echo -e "  ${GREEN}✓${NC} FIGMA_ACCESS_TOKEN saved to Claude Code settings" \
                || echo -e "  ${YELLOW}⚠${NC}  FIGMA_ACCESS_TOKEN not set"
echo -e "  ${GREEN}✓${NC} Figma Bridge     $EXTENSION_DIR"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo ""
echo "  1. Restart Claude Code to load the MCP server"
echo "  2. Open a Figma file in Chrome (with Figma Bridge extension enabled)"
echo "  3. Open any plugin in Figma once, then close it"
echo "     (this unlocks the figma global for browser automation)"
echo ""
echo -e "  ${BOLD}Start from your project folder:${NC}  cd \"$PROJECT_DIR\""
echo ""
echo -e "  ${CYAN}/speckit.specify \"My app idea\"${NC}      ← create branch + functional spec"
echo -e "  ${CYAN}/design-interview${NC}                  ← add visual design layer"
echo -e "  ${CYAN}/design \"My app\"  <figma-url>${NC}     ← build it in Figma"
echo -e "  ${CYAN}/refine \"change X to Y\"${NC}           ← iterate post-build"
echo ""
