---
name: jt-switch
description: Switches the git branch to a ticket's branch and loads CONTEXT.md so Claude can immediately resume work. Use when the user invokes "/jt-switch", wants to "switch to a ticket", "resume ticket context", "pick up where I left off on a ticket", or "load context for a ticket".
argument-hint: <TICKET-ID>
allowed-tools: Bash(*) Read
---

# jt-switch: Switch to Ticket and Load Context

The user invoked this with: $ARGUMENTS

## Resolve tickets directory

Run: `cat ~/.jt-config 2>/dev/null`

Use the path from the file as `TICKETS_DIR`. If missing or empty, fall back to `~/juggle-tickets`.

## Parse argument

Accept formats: `PROJ-123`, `proj-123`, `123`. Normalize to uppercase (e.g. `PROJ-123`). If no argument provided, read `<TICKETS_DIR>/INDEX.md`, print the ticket list, and ask the user to choose one.

## Verify

Check that `<TICKETS_DIR>/<ID>/CONTEXT.md` exists. If not, tell the user to run `/jt-init <ID>` first.

## Read CONTEXT.md

Read `<TICKETS_DIR>/<ID>/CONTEXT.md` in full.

## Switch git branch

Extract the branch name from the "Working branch" line in CONTEXT.md (the backtick-wrapped value).
Extract the repo path from the "Repo" line in CONTEXT.md.

Check for uncommitted changes:
```bash
cd <repo-path>
git status --short
```

If there are uncommitted changes, warn the user and ask to confirm before switching. If clean (or confirmed):
```bash
git checkout <branch-name>
# if that fails because branch is only on origin:
git fetch origin <branch-name> && git checkout --track origin/<branch-name>
```

If the repo path is `(not in a git repo)` or the cd fails, skip the branch switch and note it.

## Print context summary

```
--- TICKET CONTEXT LOADED: <ID> ---

Ticket:  <ID> — <title from CONTEXT.md header>
Branch:  <branch-name> (now checked out)
Status:  <status>
Updated: <last-updated>

WHAT THIS IS:
<"What This Ticket Is About" section>

LAST SESSION:
<Most recent entry from "What Has Been Done" — the most recent ### block only>

NEXT STEPS:
<"Next Steps" list>

BLOCKERS: <"Current Blockers" content, or "None">

KEY FILES:
<"Key Files" table>

Full context: <TICKETS_DIR>/<ID>/CONTEXT.md
---
```

After printing: "Context loaded. Ready to continue work on <ID>. What would you like to start with?"
