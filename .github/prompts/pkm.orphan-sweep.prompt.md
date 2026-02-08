---
agent: agent
---

Run an orphan sweep across the vault:

1. Call `find_orphaned_notes` with type `no_backlinks` to find notes that nothing links to.
2. For each orphaned note, use `search_notes` to find potentially related content in the vault.
3. Report a summary:
   - List each orphan with its path and a one-line description
   - For each, suggest 2-3 existing notes it should be linked to (with reasoning)
4. Ask the user if they'd like you to update the orphaned notes with the suggested links.

If the user confirms, update both sides of the link:
- Add wiki-links in the orphaned note's body and `related` frontmatter
- Update the target notes' `related` fields to link back
