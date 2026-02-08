# Obsidian PKM + VS Code Agent Hub — Implementation Spec

## Overview

A shareable, git-backed Obsidian vault with VS Code Agent Mode as the orchestration layer. The repo **is** the vault — clone it, open in VS Code and Obsidian, and you have a fully-wired PKM system with AI agent access to your notes, web search, browser automation, and GitHub.

All MCP servers are pre-configured in `.vscode/mcp.json`. API keys use VS Code's `${input:...}` prompt pattern so each user is prompted on first use — nothing is hardcoded.

This spec is designed to be run through Spec Kit for agent-driven implementation.

---

## Goals

1. Obsidian vault as the "persistent context layer" for all personal knowledge management.
2. VS Code Agent Mode as the agent hub — all MCP servers, CLI tools, and LLM interactions orchestrated here.
3. Agents can read/write/search the vault, browse the web (Playwright), research topics (Brave Search), and pull in knowledge automatically.
4. Bidirectional links, frontmatter, and semantic search prevent orphaned/forgotten documents.
5. Git-backed vault for version control, portability, and easy sharing with collaborators.
6. Clone-and-go setup — a new user clones the repo, opens it, and everything connects after signing into GitHub and entering their Brave API key.

---

## Phase 1: Obsidian Vault Setup

### 1.1 Install Obsidian (Manual)
- Download and install Obsidian from https://obsidian.md (free for personal and commercial use).
- Open this repo as a vault: Obsidian → "Open folder as vault" → select this repo root.
- Enable Community Plugins in Settings → Community Plugins → Turn on.

### 1.2 Vault Folder Structure
This repo root is the vault root. Create the following top-level folders (coexisting with `.github/`, `.vscode/`, `.specify/`):

```
/
├── 00-Inbox/                  # Quick capture, unsorted notes, agent-generated drafts
├── 10-Projects/               # Active projects (one subfolder per project)
├── 20-Areas/                  # Ongoing areas of responsibility (home, work, health, etc.)
├── 30-Resources/              # Reference material, clipped articles, how-tos
├── 40-Archive/                # Completed/inactive items moved here
└── _templates/                # Note templates (Templater format)
```

The PARA method (Projects/Areas/Resources/Archive) with an Inbox for quick capture. Users create their own project subfolders under `10-Projects/` as needed.

### 1.3 Frontmatter Schema
All notes MUST include YAML frontmatter. Standard schema:

```yaml
---
type: note | project | area | resource | meeting | reference
status: active | planned | done | archived
tags: []
created: {{date}}
modified: {{date}}
related: []           # wiki-links to related notes
---
```

- `type` enables structured queries and agent filtering via `search_by_property`.
- `status` prevents orphaned docs (agents can query for stale/planned items).
- `related` supplements wiki-links for explicit cross-references.
- `tags` for freeform categorization (agent uses `list_tags` for consistency).

### 1.4 Templates (Templater plugin)
Create templates in `_templates/`:

- **Meeting Note** (`_templates/meeting.md`):
  ```markdown
  ---
  type: meeting
  status: planned
  tags: []
  created: {{date}}
  modified: {{date}}
  related: []
  ---
  # {{title}}
  ## Attendees
  -
  ## Agenda
  -
  ## Notes
  -
  ## Action Items
  - [ ]
  ```

- **Project** (`_templates/project.md`):
  ```markdown
  ---
  type: project
  status: active
  tags: []
  created: {{date}}
  modified: {{date}}
  related: []
  ---
  # {{title}}
  ## Goal
  -
  ## Key Decisions
  -
  ## Tasks
  - [ ]
  ## Related Notes
  - [[]]
  ```

- **Resource / Reference** (`_templates/resource.md`):
  ```markdown
  ---
  type: resource
  status: active
  tags: []
  source:
  created: {{date}}
  modified: {{date}}
  related: []
  ---
  # {{title}}
  ## Summary
  -
  ## Key Points
  -
  ## Source
  -
  ```

- **Generic Note** (`_templates/note.md`):
  ```markdown
  ---
  type: note
  status: active
  tags: []
  created: {{date}}
  modified: {{date}}
  related: []
  ---
  # {{title}}

  ```

### 1.5 Core Obsidian Plugins to Install (Manual)
Install via Obsidian Settings → Community Plugins → Browse:

| Plugin | Purpose |
|--------|---------|
| **Templater** | Template engine for note creation with dynamic variables |
| **Dataview** | Query vault content using frontmatter (e.g., "all meetings with status: planned") |
| **Smart Connections** | Local embeddings + semantic search + AI-powered note linking suggestions |
| **Obsidian Git** | Auto-commit and sync vault to git on interval or manually |
| **Calendar** | Calendar view for daily/meeting notes |
| **Kanban** | Optional: board view for tracking tasks/status |

> **Note**: The "Local REST API" plugin is **not needed**. The `obsidian-mcp` server (v2+) uses direct filesystem access.

### 1.6 Smart Connections Configuration (Manual)
- After installing Smart Connections, let it build local embeddings of the entire vault.
- Configure it to use a local embedding model (runs on-device, no data leaves machine).
- This enables: semantic search, "similar notes" suggestions, and smart chat (RAG over vault).
- Smart Connections surfaces orphaned or weakly-linked notes inside Obsidian itself.

---

## Phase 2: MCP Server — Obsidian ↔ VS Code Bridge

### 2.1 Obsidian MCP Server (`obsidian-mcp` v2)
The `obsidian-mcp` package (PyPI) provides direct filesystem access to the vault — no Obsidian plugins required, works offline, and doesn't need Obsidian to be running.

Prerequisites:
- Python 3.10+ and `uv` installed.

The server is configured in `.vscode/mcp.json` (created in Phase 3) with `OBSIDIAN_VAULT_PATH` pointing to the repo root (i.e., `${workspaceFolder}`).

### 2.2 Available Obsidian MCP Tools
Once connected, the VS Code agent gains these tools:

**Note Management:**
- `read_note` — read content and metadata of a note
- `create_note` — create a new note (with overwrite protection)
- `update_note` — replace or append to existing note content
- `edit_note_section` — edit a specific section by heading (insert, replace, append)
- `delete_note` — delete a note

**Search & Discovery:**
- `search_notes` — full-text search with tag/path/property syntax
- `search_by_date` — find notes by creation or modification date
- `search_by_regex` — regex pattern search across vault
- `search_by_property` — query by frontmatter properties with operators (=, >, <, contains, exists)
- `list_notes` — list notes in a directory (optionally recursive)
- `list_folders` — list folder structure

**Organization:**
- `create_folder` — create folders (including parent hierarchy)
- `move_note` — move a note with automatic link updates
- `rename_note` — rename with automatic backlink updates across vault
- `move_folder` — move entire folders with contents
- `add_tags` / `update_tags` / `remove_tags` — manage note tags
- `batch_update_properties` — bulk update frontmatter across multiple notes
- `get_note_info` — get metadata and stats without reading full content

**Link Management:**
- `get_backlinks` — find all notes linking to a given note
- `get_outgoing_links` — list all links from a note
- `find_broken_links` — identify broken wiki-links
- `find_orphaned_notes` — find notes with no backlinks, no tags, or no metadata

**Image Management:**
- `read_image` — view an image from the vault
- `view_note_images` — extract and view all images in a note
- `list_tags` — list all tags with usage counts

---

## Phase 3: MCP Servers & CLI Tools Configuration

All MCP servers are configured in `.vscode/mcp.json`. API keys use VS Code input prompts — users are asked on first connection.

### 3.1 Complete `.vscode/mcp.json`

```jsonc
{
  "inputs": [
    {
      "type": "promptString",
      "id": "brave-api-key",
      "description": "Brave Search API Key (free at https://brave.com/search/api/)",
      "password": true
    }
  ],
  "servers": {
    "obsidian": {
      "command": "uvx",
      "args": ["obsidian-mcp"],
      "env": {
        "OBSIDIAN_VAULT_PATH": "${workspaceFolder}"
      }
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@brave/brave-search-mcp-server"],
      "env": {
        "BRAVE_API_KEY": "${input:brave-api-key}"
      }
    },
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

### 3.2 Server Details

| Server | Package | Purpose | Auth |
|--------|---------|---------|------|
| **obsidian** | `obsidian-mcp` (PyPI, v2+) | Read/write/search vault notes via filesystem | None (local filesystem) |
| **playwright** | `@playwright/mcp` (npm, by Microsoft) | Browser automation — navigate, click, fill forms, screenshot | None |
| **brave-search** | `@brave/brave-search-mcp-server` (npm) | Web search, news, images, local search | `BRAVE_API_KEY` (free tier: 2k queries/mo) |
| **github** | Remote MCP endpoint | Issues, PRs, repos, code search, users | OAuth via GitHub Copilot sign-in (automatic) |
| **context7** | `@upstash/context7-mcp` (npm) | Up-to-date library docs and code examples | Optional `CONTEXT7_API_KEY` for higher rate limits |

### 3.3 Built-in VS Code Agent Tools
These require no configuration:
- **`#fetch`** — grab web page content for quick clipping into vault notes
- **Terminal** — run any CLI tool (`pandoc`, `gh`, `git`, custom scripts)

### 3.4 Useful CLI Tools (Optional)
- `pandoc` — document conversion (PDF → Markdown for importing into vault)
- `gh` — GitHub CLI for repo/issue management from terminal
- Custom PowerShell/bash scripts for vault maintenance

---

## Phase 4: Agent Configuration & Workflows

### 4.1 Copilot Agent Instructions
Create `.github/copilot-instructions.md` with comprehensive agent behavior rules. This file is automatically loaded by GitHub Copilot in Agent Mode.

The instructions must cover:
1. **Vault conventions** — folder structure, frontmatter schema, where to put different note types
2. **Tool reference** — every MCP tool available, grouped by server, with when/how to use each
3. **Core behaviors** — always search before creating, always include frontmatter, link aggressively, use Inbox for uncertain placement
4. **Workflows** — web research → vault note, orphan detection, inbox triage, maintenance

### 4.2 Reusable Prompt Files
Store reusable agent prompts in `.github/prompts/` (alongside Spec Kit prompts):

- `pkm.research.prompt.md` — Research a topic, summarize into vault, link to related notes
- `pkm.orphan-sweep.prompt.md` — Find orphaned notes, suggest connections
- `pkm.inbox-triage.prompt.md` — Review Inbox, suggest proper filing locations
- `pkm.maintenance.prompt.md` — Run frontmatter lint, stale check, broken link scan

### 4.3 Periodic Vault Maintenance
Use prompt files or ask the agent directly:
- **Orphan sweep**: `find_orphaned_notes` → for each, `search_notes` for related content → suggest links
- **Stale note check**: `search_by_property("status", "planned")` + `search_by_date` to find old planned items
- **Frontmatter lint**: `list_notes` → `get_note_info` for each → report missing fields
- **Inbox triage**: `list_notes("00-Inbox")` → `read_note` each → suggest target folder and tags
- **Broken link scan**: `find_broken_links` → report with suggested fixes

---

## Phase 5: Git & Sync

### 5.1 Obsidian Git Plugin (Manual Configuration)
- Configure auto-commit interval (e.g., every 10 minutes or on vault close).
- Push to a private GitHub repo for backup and history.
- Each collaborator pushes to the same repo or their own fork.

### 5.2 .gitignore
```
# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json
.obsidian/mcp-search-index.db

# Smart Connections (embeddings cache, regenerable)
.smart-connections/

# OS
Thumbs.db
.DS_Store
```

---

## Phase 6: Validation & Testing

### 6.1 Smoke Tests
After setup, verify these workflows end-to-end:

1. **Create a note via agent**: Ask: "Create a new project note for 'Home Renovation' in 10-Projects/ with tags home and planning." Verify correct folder, frontmatter, and wiki-links.

2. **Search the vault**: Ask: "Find all notes with status: planned." Verify the agent uses `search_by_property` and returns results.

3. **Web research into vault**: Ask: "Research best practices for Zettelkasten note-taking and save a summary to 30-Resources/." Verify the agent uses Brave Search, creates a note with source URLs, and links it.

4. **Orphan detection**: Ask: "Are there any orphaned notes in the vault?" Verify the agent calls `find_orphaned_notes` and reports.

5. **Browser automation**: Ask: "Open github.com and find the trending repositories page." Verify Playwright launches and navigates.

6. **Library docs**: Ask: "Look up the Context7 docs for the Dataview Obsidian plugin API." Verify Context7 MCP returns relevant documentation.

### 6.2 Acceptance Criteria
- [ ] Repo has the defined vault folder structure (`00-Inbox/`, `10-Projects/`, etc.)
- [ ] All templates exist in `_templates/` and work with Templater
- [ ] `.vscode/mcp.json` configures all 5 MCP servers
- [ ] `.github/copilot-instructions.md` contains comprehensive agent instructions
- [ ] `.gitignore` covers Obsidian cache, embeddings, and OS files
- [ ] Obsidian MCP server connects from VS Code (test: "list all notes")
- [ ] Playwright MCP server connects from VS Code (test: open a URL)
- [ ] Brave Search returns results (test: search for a topic)
- [ ] GitHub MCP connects via OAuth (test: "list my repos")
- [ ] Agent can create, read, search, and update vault notes via MCP
- [ ] Agent can browse the web and save findings to vault
- [ ] Agent follows vault conventions from copilot-instructions.md
- [ ] Git auto-commit (Obsidian Git plugin) is working
- [ ] Smart Connections has generated local embeddings

---

## Dependencies & Prerequisites

| Dependency | Version/Notes |
|-----------|---------------|
| Obsidian | Latest stable (free for personal use) |
| VS Code | Latest stable with GitHub Copilot Chat enabled |
| GitHub Copilot subscription | For VS Code Agent Mode |
| Python 3.10+ | For `obsidian-mcp` server |
| `uv` | Python package runner (`pip install uv` or via installer) |
| Node.js 18+ | For Playwright, Brave Search, and Context7 MCP servers |
| Git | For vault version control |
| Brave Search API key | Free at https://brave.com/search/api/ (2k queries/month free tier) |

---

## Getting Started (for collaborators)

1. **Clone** this repo
2. **Install prerequisites**: Obsidian, VS Code + Copilot, Python 3.10+ with `uv`, Node.js 18+
3. **Open in VS Code** — MCP servers are pre-configured in `.vscode/mcp.json`
4. **Open as Obsidian vault** — Obsidian → "Open folder as vault" → select repo root
5. **Install Obsidian plugins** (manual): Templater, Dataview, Smart Connections, Obsidian Git, Calendar
6. **First use**: VS Code will prompt for your Brave Search API key; GitHub auth is automatic via Copilot sign-in
7. **Start using**: Open Agent Mode in VS Code and use the PKM prompt commands or ask directly

---

## Notes for Spec Kit Execution

- This spec is designed for sequential phase execution.
- Phase 1 (vault structure, templates) has no external dependencies — agent creates files directly.
- Phase 2 (obsidian-mcp) is configured in Phase 3's `mcp.json` — no separate install step needed.
- Phase 3 (all MCP config) creates `.vscode/mcp.json` — single file, all servers.
- Phase 4 (agent instructions, prompts) depends on Phases 2-3 for tool references.
- Phase 5 (git/gitignore) can be done at any point after Phase 1.
- Phase 6 requires all prior phases and manual Obsidian plugin setup.

Manual steps requiring user interaction:
- Installing Obsidian and opening the vault
- Enabling Community Plugins and installing each plugin via Obsidian GUI
- Configuring Smart Connections embeddings
- Configuring Obsidian Git plugin with commit interval and remote
