# 🧠 Obsidian PKM + VS Code Agent Hub

A shareable, git-backed [Obsidian](https://obsidian.md) vault with VS Code Agent Mode as the AI orchestration layer. Clone it, run setup, and you have a fully-wired personal knowledge management system with AI agents that can read/write/search your notes, browse the web, and automate tasks.

> **Two apps, one folder.** This repo is both a VS Code workspace and an Obsidian vault.
> **VS Code Agent Mode** is the brain — it orchestrates AI tools, MCP servers, web research, and vault automation.
> **Obsidian** is the UI — it renders your notes beautifully, provides graph view, and has its own AI chat sidebar (Copilot for Obsidian) for quick vault Q&A.
> Both apps point at the same folder, so changes from either side appear instantly in the other.

## Quick Start

### 1. Create Your Private Vault

This is a **template repository**. Click the button below to create your own private copy:

[![Use this template](https://img.shields.io/badge/Use%20this%20template-238636?logo=github&logoColor=white)](https://github.com/nsmaassel/obsidian-pkm-agent/generate)

1. Click **"Use this template"** → **"Create a new repository"**
2. Set the owner to your GitHub account
3. Name it whatever you want (e.g., `my-pkm`, `brain`, `vault`)
4. **Set it to Private** — your notes are personal!
5. Clone your new private repo:

```bash
git clone https://github.com/YOU/your-vault-name.git
cd your-vault-name
```

> **Why a template?** The template repo stays public with the scaffolding, setup scripts, and docs. Your private repo gets all of that plus your personal notes — which only you can see.

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
2. Obsidian will ask **"Do you trust the author?"** → click **"Trust author and enable plugins"**
3. The plugins are already downloaded and will activate automatically
4. Let **Smart Connections** build its initial embeddings index (takes a minute on first run)

### 4. Connect Copilot for Obsidian

The Copilot plugin gives you an AI chat sidebar inside Obsidian, powered by your GitHub Copilot subscription (no extra API keys):

1. Open **Settings → Community Plugins → Copilot → Settings** (or click the gear icon next to Copilot)
2. Scroll to **GitHub Copilot** and click **"Setup"**
3. Go to the GitHub device URL shown and enter the code
4. Once connected, click **"Add Model"** to add models from your Copilot subscription (e.g., `claude-opus-4.6`, `gpt-4o`)
5. Open the **Copilot sidebar** (brain icon in the left ribbon) — you're ready to chat with your vault

### 5. Open VS Code Agent Mode

1. Open this folder in **VS Code** (or it may already be open from step 1)
2. Press **Ctrl+Shift+I** (or Cmd+Shift+I on Mac) to open Agent Mode
3. The MCP servers in `.vscode/mcp.json` start automatically — you'll see them in the chat panel
4. VS Code may prompt you to approve the MCP servers on first launch — click "Allow"

### 6. Verify Everything Works

Try these in VS Code Agent Mode to confirm the setup:

| Test | What it verifies |
|------|------------------|
| `"List all notes in the vault"` | Obsidian MCP server can read the vault |
| `"Create a test note in 00-Inbox called Hello World"` | Obsidian MCP can write (check it appears in Obsidian too!) |
| `"Open github.com in the browser"` | Playwright MCP server works |
| `"What are my GitHub repos?"` | GitHub MCP server + Copilot auth works |

Then flip to **Obsidian** and try the Copilot sidebar:
- Ask: `"What notes are in the vault?"` — tests vault-aware RAG
- Ask: `"Summarize the inbox"` — tests note reading

### 7. Start Using

**In VS Code Agent Mode** (the heavy lifter):
- `"Research best practices for [topic] and save to vault"` — web research → vault note
- `"Triage my inbox"` — reviews `00-Inbox/` and suggests where to file notes
- `/pkm.research`, `/pkm.inbox-triage`, `/pkm.maintenance` — reusable prompt commands

**In Obsidian Copilot sidebar** (quick questions while browsing notes):
- `"Summarize this note"` — quick summaries
- `"What notes are related to [topic]?"` — vault-aware semantic search
- `"Find action items across my meeting notes"` — cross-note queries

---

## What's Included

### MCP Servers (pre-configured in `.vscode/mcp.json`)

| Server | What it does | Auth |
|--------|-------------|------|
| **Obsidian** (`obsidian-mcp`) | Read/write/search vault notes — 28 tools | None (filesystem) |
| **Playwright** (`@playwright/mcp`) | Browser automation — navigate, click, fill, screenshot | None |
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
| **Copilot for Obsidian** | In-vault AI chat sidebar for quick vault Q&A, summarization, and RAG over your notes |

---

## Prerequisites

| Tool | Required | Install |
|------|----------|---------|
| [Obsidian](https://obsidian.md) | Yes | Free download |
| [VS Code](https://code.visualstudio.com) + [GitHub Copilot](https://github.com/features/copilot) | Yes | Copilot subscription required |
| [Python 3.10+](https://python.org) | Yes | For obsidian-mcp |
| [uv](https://docs.astral.sh/uv/) | Yes | Setup script installs it |
| [Node.js 18+](https://nodejs.org) | Yes | For Playwright, Context7 |
| [Git](https://git-scm.com) | Yes | For vault version control |

---

## How It Works

**This repo is both the Obsidian vault and the VS Code workspace.** The vault folders (`00-Inbox/`, `10-Projects/`, etc.) coexist with configuration directories (`.github/`, `.vscode/`, `.specify/`).

### The Two-App Workflow

| | VS Code Agent Mode | Obsidian |
|---|---|---|
| **Role** | AI orchestration hub | Note reading & writing UI |
| **AI chat** | Full agent with MCP tools, web browsing, GitHub | Copilot sidebar for quick vault Q&A |
| **When to use** | Complex tasks: research, multi-note updates, web scraping, automation | Browsing notes, quick questions, graph view, daily workflows |
| **Vault access** | Via `obsidian-mcp` server (filesystem) | Direct (it's an Obsidian vault) |

Both apps point at the **same folder**. A note created by the VS Code agent appears instantly in Obsidian, and vice versa. Obsidian doesn't even need to be running for the agent to work.

Your notes stay local. External calls go through GitHub Copilot (your existing sign-in) and any web searches you ask the agent to perform.

---

## Customization

- **Add project folders**: Create subfolders under `10-Projects/` for each project
- **Add templates**: Drop new `.md` templates in `_templates/`
- **Add tags**: Use any tags you like — the agent checks `list_tags` to stay consistent
- **Configure Smart Connections**: Tune the embedding model and settings in Obsidian
- **Configure Obsidian Git**: Set auto-commit interval in Obsidian plugin settings

---

## Sharing & Privacy

This repo is designed as a **GitHub template**:

| Repo | Visibility | Contains |
|------|-----------|----------|
| `obsidian-pkm-agent` (this template) | **Public** | Setup scripts, config, templates, docs — no personal data |
| Your vault (created from template) | **Private** | Everything above + your personal notes, projects, research |

**To share the template with someone:**
- Send them the link to this repo
- They click "Use this template" → create their own private vault
- They run `setup.ps1`/`setup.sh` → done

**To pull template updates into your vault:**
```bash
git remote add template https://github.com/nsmaassel/obsidian-pkm-agent.git
git fetch template
git merge template/main --allow-unrelated-histories
```

---

## License

MIT
