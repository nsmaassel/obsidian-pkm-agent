---
agent: copilot
---

Triage the Inbox folder:

1. `list_notes("00-Inbox")` to see all notes waiting for triage.
2. `read_note` each one to understand its content.
3. For each note, suggest:
   - **Target folder**: where it should be moved (10-Projects/..., 20-Areas/..., 30-Resources/..., or 40-Archive/)
   - **Tags**: appropriate tags (check `list_tags` first for consistency)
   - **Related notes**: existing notes it should link to (use `search_notes` to find them)
   - **Missing frontmatter**: any required fields that need to be added
4. Present the suggestions as a summary table.
5. Ask the user which moves to execute, then use `move_note` and `update_tags` to carry them out.
