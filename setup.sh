#!/usr/bin/env bash
#
# Obsidian PKM Agent Hub — One-time setup script (macOS/Linux)
#
# Checks prerequisites, downloads Obsidian community plugins, and pre-warms
# MCP server packages so everything is ready on first launch.
# Run this once after cloning the repo.
#
# Usage: ./setup.sh

set -euo pipefail

# Colors
step()  { printf '\n\033[36m▸ %s\033[0m\n' "$1"; }
ok()    { printf '  \033[32m✓ %s\033[0m\n' "$1"; }
warn()  { printf '  \033[33m⚠ %s\033[0m\n' "$1"; }
err()   { printf '  \033[31m✗ %s\033[0m\n' "$1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Obsidian PKM + VS Code Agent Hub — Setup      ║"
echo "╚══════════════════════════════════════════════════╝"

# ── 1. Check prerequisites ──────────────────────────────────────────────────

step "Checking prerequisites..."

missing=()

# Git
if command -v git &>/dev/null; then
    ok "$(git --version)"
else
    err "Git not found"; missing+=(git)
fi

# Python
if command -v python3 &>/dev/null; then
    ok "$(python3 --version)"
elif command -v python &>/dev/null; then
    ok "$(python --version)"
else
    err "Python 3.10+ not found"; missing+=(python)
fi

# uv
if command -v uv &>/dev/null; then
    ok "uv $(uv --version 2>&1)"
else
    warn "uv not found — installing..."
    if curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null; then
        ok "uv installed"
    else
        err "Failed to install uv. Install manually: https://docs.astral.sh/uv/"
        missing+=(uv)
    fi
fi

# Node.js
if command -v node &>/dev/null; then
    ok "Node.js $(node --version)"
else
    err "Node.js 18+ not found"; missing+=(node)
fi

# npx
if command -v npx &>/dev/null; then
    ok "npx available"
else
    err "npx not found (comes with Node.js)"; missing+=(npx)
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    warn "Missing: ${missing[*]}. Install them before continuing."
    warn "The script will continue but some steps may fail."
fi

# ── 2. Download Obsidian plugins ────────────────────────────────────────────

step "Setting up Obsidian plugins..."

declare -A PLUGIN_REPOS=(
    ["templater-obsidian"]="SilentVoid13/Templater"
    ["dataview"]="blacksmithgu/obsidian-dataview"
    ["smart-connections"]="brianpetro/obsidian-smart-connections"
    ["obsidian-git"]="Vinzent03/obsidian-git"
    ["calendar"]="liamcain/obsidian-calendar-plugin"
)

PLUGINS_DIR="$SCRIPT_DIR/.obsidian/plugins"

for plugin_id in "${!PLUGIN_REPOS[@]}"; do
    repo="${PLUGIN_REPOS[$plugin_id]}"
    plugin_dir="$PLUGINS_DIR/$plugin_id"
    mkdir -p "$plugin_dir"

    if [ -f "$plugin_dir/manifest.json" ]; then
        ok "$plugin_id already installed"
        continue
    fi

    printf '  ↓ Downloading %s...\n' "$plugin_id"
    for file in main.js manifest.json styles.css; do
        url="https://github.com/$repo/releases/latest/download/$file"
        if curl -fsSL "$url" -o "$plugin_dir/$file" 2>/dev/null; then
            :
        else
            # styles.css is optional
            if [ "$file" != "styles.css" ]; then
                warn "Failed to download $plugin_id/$file"
            fi
        fi
    done

    if [ -f "$plugin_dir/manifest.json" ]; then
        ok "$plugin_id installed"
    else
        err "$plugin_id failed to download"
    fi
done

# ── 3. Configure Templater to use _templates/ folder ────────────────────────

step "Configuring Templater templates folder..."

TEMPLATER_DATA="$PLUGINS_DIR/templater-obsidian/data.json"
if [ ! -f "$TEMPLATER_DATA" ]; then
    cat > "$TEMPLATER_DATA" << 'EOF'
{
  "templates_folder": "_templates",
  "trigger_on_file_creation": true,
  "auto_jump_to_cursor": true,
  "command_timeout": 5
}
EOF
    ok "Templater configured to use _templates/"
else
    ok "Templater already configured"
fi

# ── 4. Pre-warm MCP server packages ─────────────────────────────────────────

step "Pre-warming MCP server packages (so first launch is faster)..."

if command -v npx &>/dev/null; then
    for pkg in "@playwright/mcp@latest" "@brave/brave-search-mcp-server" "@upstash/context7-mcp@latest"; do
        printf '  ↓ Caching %s...\n' "$pkg"
        if npx -y "$pkg" --help &>/dev/null; then
            ok "$pkg cached"
        else
            warn "Could not pre-cache $pkg (will download on first use)"
        fi
    done
fi

# ── 5. Verify vault structure ───────────────────────────────────────────────

step "Verifying vault folder structure..."

for folder in 00-Inbox 10-Projects 20-Areas 30-Resources 40-Archive _templates; do
    if [ -d "$SCRIPT_DIR/$folder" ]; then
        ok "$folder/"
    else
        mkdir -p "$SCRIPT_DIR/$folder"
        ok "$folder/ (created)"
    fi
done

# ── Done ────────────────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   Setup complete!                                ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Open this folder as an Obsidian vault"
echo "     (Obsidian → Open folder as vault → select this repo)"
echo "  2. In Obsidian: Settings → Community Plugins → Turn on"
echo "  3. The plugins are already downloaded — just enable them"
echo "  4. Open this folder in VS Code and start Agent Mode"
echo "  5. VS Code will prompt for your Brave Search API key on first use"
echo ""
