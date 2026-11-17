## Wayfinding operations

This repo uses **local markdown** for issue tracking (alternative to GitHub/GitLab).

### Map
- The map issue is labelled `wayfinder:map` and lives as a markdown file in this repo
- Its child tickets are sibling markdown files linked from the map
- Ticket IDs are their filenames (without extension)

### Ticket types and labels
Each ticket carries a `wayfinder:<type>` label, one of:
- `wayfinder:research` - Reading docs/APIs to surface facts
- `wayfinder:prototype` - Building a rough artifact to react to
- `wayfinder:grilling` - Conversation-based decision
- `wayfinder:task` - Manual work blocking a decision

### Blocking / frontier
- A ticket is **blocked** when another ticket it depends on is open
- The **frontier** = open, unblocked, unclaimed child tickets of the map
- A session claims a ticket by assigning it to themselves before working
- **Unblocked** = every ticket blocking it is closed

### How wayfinder expresses them here
- The **map** is `docs/agents/wayfinder-map.md` (label: `wayfinder:map`)
- Child tickets are markdown files anywhere in the repo, referenced by relative path
- Blocking edges are written as `blocks: <ticket-path>` in the ticket body
- The **frontier** is discovered by querying: open tickets whose blocking tickets are all closed
- The map body lists closed tickets in **Decisions so far** with `- [ticket title](link): gist`
- **Not yet specified** contains fog: decisions you can tell are coming but can't phrase sharply yet
- **Out of scope** contains work ruled beyond the destination

### Creating tickets
1. Create the ticket markdown file
2. Add `wayfinder:<type>` label in the body (not as a triage label - there are no triage labels in local markdown mode)
3. If it blocks another ticket, add `blocks: <path-to-blocking-ticket>` in the body
4. The map creator wires cross-references in a second pass using real ticket ids (e.g., `#scripts/destructible_object` auto-links)

### Research subagents
- For `wayfinder:research` tickets, spin up a subagent calling the Skill tool with "research"
- Capture findings on a `research/<name>` branch - push but open no PR: never merged