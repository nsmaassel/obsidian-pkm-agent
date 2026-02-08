# 🧠 Obsidian PKM + VS Code Agent Hub

A shareable, git-backed [Obsidian](https://obsidian.md) vault with VS Code Agent Mode as the AI orchestration layer. Clone it, run setup, and you have a fully-wired personal knowledge management system with AI agents that can read/write/search your notes, browse the web, and automate tasks.

## Quick Start

### 1. Clone & Open

[![Open in VS Code](https://img.shields.io/badge/Open%20in-VS%20Code-007ACC?logo=visual-studio-code&logoColor=white)](vscode://vscode.git/clone?url=https://github.com/YOUR_USERNAME/obsidian-pkm-agent.git) [![Open in VS Code Insiders](https://img.shields.io/badge/Open%20in-VS%20Code%20Insiders-24bfa5?logo=visual-studio-code&logoColor=white)](vscode-insiders://vscode.git/clone?url=https://github.com/YOUR_USERNAME/obsidian-pkm-agent.git)

Or clone manually:
```bash
git clone https://github.com/YOUR_USERNAME/obsidian-pkm-agent.git
cd obsidian-pkm-agent
```

### 2. Run Setup

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**macOS / Linux:**
```bash
chmod +x setup.sh && ./setup.sh
```

The setup script will:
- ✅ Check prerequisites (Git, Python, uv, Node.js)
- ✅ Download and install Obsidian community plugins
- ✅ Configure Templater to use the `_templates/` folder
- ✅ Pre-download MCP server packages for faster first launch

### 3. Open as Obsidian Vault

1. Open **Obsidian** → "Open folder as vault" → select this repo folder
2. Go to **Settings → Community Plugins → Turn on community plugins**
3. The plugins are already downloaded — they'll appear in the list, just enable them

### 4. Start Using

Open **VS Code Agent Mode** (Ctrl/Cmd+Shift+I) and try:
- `"Create a note about my new project idea"` — creates a note with proper frontmatter and links
- `"Research best practices for [topic] and save to vault"` — searches the web and creates a resource note
- `"Are there any orphaned notes?"` — finds disconnected notes
- `"Triage my inbox"` — reviews `00-Inbox/` and suggests where to file notes

---

## What's Included

### MCP Servers (pre-configured in `.vscode/mcp.json`)

| Server | What it does | Auth |
|--------|-------------|------|
| **Obsidian** (`obsidian-mcp`) | Read/write/search vault notes — 28 tools | None (filesystem) |
| **Playwright** (`@playwright/mcp`) | Browser automation — navigate, click, fill, screenshot | None |
| **Brave Search** (`@brave/brave-search-mcp-server`) | Web search, news, images | API key (free tier) |
| **GitHub** (remote endpoint) | Issues, PRs, repos, code search | Auto via Copilot |
| **Context7** (`@upstash/context7-mcp`) | Up-to-date library documentation | Optional API key |

### Vault Structure (PARA Method)

```
00-Inbox/          Quick capture, unsorted notes
10-Projects/       Active projects (create subfolders as needed)
20-Areas/          Ongoing responsibilities (work, home, health)
30-Resources/      Reference material, articles, how-tos
40-Archive/        Completed/inactive items
_templates/        Note templates for Templater
```

### Agent Prompt Commands

Use these in VS Code Agent Mode:

| Command | What it does |
|---------|-------------|
| `/pkm.research` | Research a topic → create a vault note with sources |
| `/pkm.orphan-sweep` | Find orphaned notes and suggest connections |
| `/pkm.inbox-triage` | Review Inbox and suggest where to file notes |
| `/pkm.maintenance` | Full vault health check (stale notes, broken links, tag cleanup) |

### Obsidian Plugins (auto-downloaded by setup)

| Plugin | Purpose |
|--------|---------|
| **Templater** | Dynamic note templates |
| **Dataview** | Query notes by frontmatter |
| **Smart Connections** | Semantic search + AI link suggestions |
| **Obsidian Git** | Auto-commit vault to git |
| **Calendar** | Calendar view for notes |

---

## Prerequisites

| Tool | Required | Install |
|------|----------|---------|
| [Obsidian](https://obsidian.md) | Yes | Free download |
| [VS Code](https://code.visualstudio.com) + [GitHub Copilot](https://github.com/features/copilot) | Yes | Copilot subscription required |
| [Python 3.10+](https://python.org) | Yes | For obsidian-mcp |
| [uv](https://docs.astral.sh/uv/) | Yes | Setup script installs it |
| [Node.js 18+](https://nodejs.org) | Yes | For Playwright, Brave Search, Context7 |
| [Git](https://git-scm.com) | Yes | For vault version control |
| [Brave Search API key](https://brave.com/search/api/) | Recommended | Free tier: 2k queries/month |

---

## How It Works

**This repo is both the Obsidian vault and the VS Code workspace.** The vault folders (`00-Inbox/`, `10-Projects/`, etc.) coexist with configuration directories (`.github/`, `.vscode/`, `.specify/`).

The AI agent in VS Code connects to the vault via the `obsidian-mcp` server, which reads and writes files directly on the filesystem — Obsidian doesn't even need to be running for the agent to work.

Your notes stay local. The only external call is Brave Search (when you ask the agent to research something) and GitHub (via your existing Copilot sign-in).

---

## Customization

- **Add project folders**: Create subfolders under `10-Projects/` for each project
- **Add templates**: Drop new `.md` templates in `_templates/`
- **Add tags**: Use any tags you like — the agent checks `list_tags` to stay consistent
- **Configure Smart Connections**: Tune the embedding model and settings in Obsidian
- **Configure Obsidian Git**: Set auto-commit interval in Obsidian plugin settings

---

## License

MIT
