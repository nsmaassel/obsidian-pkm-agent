---
agent: copilot
---

Run a full vault maintenance check:

## 1. Stale Notes
Find notes with `status: planned` that haven't been modified in 30+ days:
- `search_by_property("status", "planned")` to get all planned notes
- Check each note's `modified` date
- Report any that are stale with their path and last modified date

## 2. Missing Frontmatter
- `list_notes` recursively across `00-Inbox/`, `10-Projects/`, `20-Areas/`, `30-Resources/`
- `get_note_info` for each to check for missing required fields (type, status, tags, created, modified)
- Report notes with incomplete frontmatter

## 3. Broken Links
- `find_broken_links` across the vault
- Report each broken link with its source note and the missing target
- Suggest fixes (create the missing note, or fix the link text)

## 4. Tag Cleanup
- `list_tags` with usage counts
- Identify near-duplicate tags (e.g., "project" vs "projects", "dev" vs "development")
- Identify rarely-used tags (count = 1)
- Suggest consolidation

Present a summary report with recommended actions for each category.
