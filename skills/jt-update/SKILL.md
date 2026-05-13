---
name: jt-update
description: Updates CONTEXT.md for the current ticket with what was accomplished in this session, appends to the session log, and updates INDEX.md. Use when the user invokes "/jt-update", wants to "save session context", "checkpoint this session", "log what was done", "record session progress", or "update CONTEXT.md before finishing".
allowed-tools: Bash(*) Read Write Edit
---

# jt-update: Save Session Context

## Resolve tickets directory

Run: `cat ~/.jt-config 2>/dev/null`

Use the path from the file as `TICKETS_DIR`. If missing or empty, fall back to `~/juggle-tickets`.

## Detect current ticket

Run `git branch --show-current`. Extract the ticket ID by finding any `[a-z]+-[0-9]+` segment (case-insensitive), e.g. `proj-123`, `feat-42`. Normalize to uppercase (e.g. `my-branch/proj-123-my-feature` → `PROJ-123`).

Verify `<TICKETS_DIR>/<ID>/` exists. If not, tell the user to run `/jt-init <ID>` first.

If no ticket ID can be determined from the branch, ask: "Which ticket are you updating? (e.g. PROJ-123)"

## Gather session info

If the user described what was done in their invocation message (`$ARGUMENTS`), use that directly — do not ask again. Otherwise ask:
- "What did you accomplish in this session?"
- "What are the next steps?"
- "Any blockers or open questions?" (optional)

Get current datetime: `date "+%Y-%m-%d %H:%M"`

## Read CONTEXT.md

Read `<TICKETS_DIR>/<ID>/CONTEXT.md` in full before editing.

## Update CONTEXT.md

Edit `<TICKETS_DIR>/<ID>/CONTEXT.md` with these changes:

1. Update **"Last updated"** to the current datetime.

2. Update **"Status"** if the user mentioned a status change (e.g. now blocked, now in review).

3. **Prepend** a new entry under "What Has Been Done" (most recent first):
   ```
   ### <today> (Session: <short description or 'unnamed'>)
   - <bullet for each thing accomplished>
   - Files modified: <list key files touched>
   ```

4. **Replace** the "Next Steps" section with the updated list from the user.

5. **Update** "Current Blockers" if changed.

6. **Update** "Key Files" table if new important files were mentioned.

7. **Append** a row to the "Session Log" table:
   ```
   | <today> | <short description> | <1-sentence summary of what was done> |
   ```

## Update INDEX.md

Read `<TICKETS_DIR>/INDEX.md`. Find the row for `<ID>` and update:
- The **Status** column if changed
- The **Last Session** column to today's date

## Confirm to user

```
Context saved for <ID>.
  File: <TICKETS_DIR>/<ID>/CONTEXT.md
  Next steps recorded: <N> items

To resume later:
  Terminal:  jt switch <ID>
  In Claude: /jt-switch <ID>
  With Claude pre-loaded: jt open <ID>
```
