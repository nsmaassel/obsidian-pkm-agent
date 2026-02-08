<#
.SYNOPSIS
    Obsidian PKM Agent Hub — One-time setup script (Windows)
.DESCRIPTION
    Checks prerequisites, downloads Obsidian community plugins, and pre-warms
    MCP server packages so everything is ready on first launch.
    Run this once after cloning the repo.
.EXAMPLE
    .\setup.ps1
#>

$ErrorActionPreference = "Continue"

# Colors
function Write-Step($msg) { Write-Host "`n▸ $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  ✗ $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║   Obsidian PKM + VS Code Agent Hub — Setup      ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta

# ── 1. Check prerequisites ──────────────────────────────────────────────────

Write-Step "Checking prerequisites..."

$missing = @()

# Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Ok "Git $(git --version 2>&1)"
} else {
    Write-Err "Git not found"; $missing += "git"
}

# Python
$python = if (Get-Command python -ErrorAction SilentlyContinue) { "python" }
          elseif (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" }
          else { $null }
if ($python) {
    $pyVer = & $python --version 2>&1
    Write-Ok "$pyVer"
} else {
    Write-Err "Python 3.10+ not found"; $missing += "python"
}

# uv
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Ok "uv $(uv --version 2>&1)"
} else {
    Write-Warn "uv not found — installing..."
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        Write-Ok "uv installed"
    } catch {
        Write-Err "Failed to install uv. Install manually: https://docs.astral.sh/uv/"
        $missing += "uv"
    }
}

# Node.js
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Ok "Node.js $(node --version 2>&1)"
} else {
    Write-Err "Node.js 18+ not found"; $missing += "node"
}

# npx
if (Get-Command npx -ErrorAction SilentlyContinue) {
    Write-Ok "npx available"
} else {
    Write-Err "npx not found (comes with Node.js)"; $missing += "npx"
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Warn "Missing: $($missing -join ', '). Install them before continuing."
    Write-Warn "The script will continue but some steps may fail."
}

# ── 2. Download Obsidian plugins ────────────────────────────────────────────

Write-Step "Setting up Obsidian plugins..."

$plugins = @(
    @{ id = "templater-obsidian";    repo = "SilentVoid13/Templater";                 files = @("main.js", "manifest.json", "styles.css") },
    @{ id = "dataview";              repo = "blacksmithgu/obsidian-dataview";          files = @("main.js", "manifest.json", "styles.css") },
    @{ id = "smart-connections";     repo = "brianpetro/obsidian-smart-connections";   files = @("main.js", "manifest.json", "styles.css") },
    @{ id = "obsidian-git";          repo = "Vinzent03/obsidian-git";                  files = @("main.js", "manifest.json", "styles.css") },
    @{ id = "calendar";             repo = "liamcain/obsidian-calendar-plugin";       files = @("main.js", "manifest.json", "styles.css") }
)

$pluginsDir = Join-Path $PSScriptRoot ".obsidian" "plugins"

foreach ($plugin in $plugins) {
    $pluginDir = Join-Path $pluginsDir $plugin.id
    if (-not (Test-Path $pluginDir)) {
        New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
    }

    $manifestPath = Join-Path $pluginDir "manifest.json"
    if (Test-Path $manifestPath) {
        Write-Ok "$($plugin.id) already installed"
        continue
    }

    Write-Host "  ↓ Downloading $($plugin.id)..." -ForegroundColor Gray
    foreach ($file in $plugin.files) {
        $url = "https://github.com/$($plugin.repo)/releases/latest/download/$file"
        $dest = Join-Path $pluginDir $file
        try {
            Invoke-WebRequest -Uri $url -OutFile $dest -ErrorAction Stop 2>$null
        } catch {
            # styles.css is optional for many plugins
            if ($file -ne "styles.css") {
                Write-Warn "Failed to download $($plugin.id)/$file"
            }
        }
    }

    if (Test-Path $manifestPath) {
        Write-Ok "$($plugin.id) installed"
    } else {
        Write-Err "$($plugin.id) failed to download"
    }
}

# ── 3. Configure Templater to use _templates/ folder ────────────────────────

Write-Step "Configuring Templater templates folder..."

$templaterDataPath = Join-Path $pluginsDir "templater-obsidian" "data.json"
if (-not (Test-Path $templaterDataPath)) {
    $templaterConfig = @{
        templates_folder = "_templates"
        trigger_on_file_creation = $true
        auto_jump_to_cursor = $true
        command_timeout = 5
    } | ConvertTo-Json -Depth 3
    Set-Content -Path $templaterDataPath -Value $templaterConfig -Encoding UTF8
    Write-Ok "Templater configured to use _templates/"
} else {
    Write-Ok "Templater already configured"
}

# ── 4. Pre-warm MCP server packages ─────────────────────────────────────────

Write-Step "Pre-warming MCP server packages (so first launch is faster)..."

# obsidian-mcp via uv
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "  ↓ Caching obsidian-mcp..." -ForegroundColor Gray
    try {
        $null = uv pip install --dry-run obsidian-mcp 2>&1
        Write-Ok "obsidian-mcp cached"
    } catch {
        Write-Warn "Could not pre-cache obsidian-mcp (will download on first use)"
    }
}

# npm packages via npx
if (Get-Command npx -ErrorAction SilentlyContinue) {
    $npmPackages = @(
        "@playwright/mcp@latest",
        "@brave/brave-search-mcp-server",
        "@upstash/context7-mcp@latest"
    )
    foreach ($pkg in $npmPackages) {
        Write-Host "  ↓ Caching $pkg..." -ForegroundColor Gray
        try {
            $null = npx -y $pkg --help 2>&1
            Write-Ok "$pkg cached"
        } catch {
            Write-Warn "Could not pre-cache $pkg (will download on first use)"
        }
    }
}

# ── 5. Verify vault structure ───────────────────────────────────────────────

Write-Step "Verifying vault folder structure..."

$folders = @("00-Inbox", "10-Projects", "20-Areas", "30-Resources", "40-Archive", "_templates")
foreach ($folder in $folders) {
    $path = Join-Path $PSScriptRoot $folder
    if (Test-Path $path) {
        Write-Ok "$folder/"
    } else {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Ok "$folder/ (created)"
    }
}

# ── Done ────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Setup complete!                                ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open this folder as an Obsidian vault" -ForegroundColor Gray
Write-Host "     (Obsidian → Open folder as vault → select this repo)" -ForegroundColor Gray
Write-Host "  2. In Obsidian: Settings → Community Plugins → Turn on" -ForegroundColor Gray
Write-Host "  3. The plugins are already downloaded — just enable them" -ForegroundColor Gray
Write-Host "  4. Open this folder in VS Code and start Agent Mode" -ForegroundColor Gray
Write-Host "  5. VS Code will prompt for your Brave Search API key on first use" -ForegroundColor Gray
Write-Host ""
