---
name: jt-project-init
description: Creates a juggle project (epic) directory at <TICKETS_DIR>/projects/<id>/, fetches details from Linear if a URL/ID is given, populates PROJECT.md and README.md, and updates the PROJECTS.md index. Use when the user invokes "/jt-project-init", wants to "start a new project / epic", "create an initiative", "set up a project", or provides a Linear project URL.
argument-hint: <PROJECT-ID or Linear project URL>
allowed-tools: Bash(*) Read Write mcp__claude_ai_Linear__get_project mcp__claude_ai_Linear__list_projects
---

# jt-project-init: Initialize Project / Epic Context

The user invoked this with: $ARGUMENTS

Parse `$ARGUMENTS` to extract a project identifier. Accept any of these:
- Plain project ID (slug or all-caps): `platform-rework`, `EPIC-1`, `q1-observability`
- Linear project URL: `https://linear.app/<org>/project/<slug>-<uuid>` — extract the slug portion as the project ID
- Empty: ask the user

## Steps

### 0. Resolve tickets directory

Run: `cat ~/.jt-config 2>/dev/null`

- If the file has a non-empty path, use it as `TICKETS_DIR`.
- Otherwise default to `~/juggle-task`.

Ensure `<TICKETS_DIR>/projects/` exists: `mkdir -p <TICKETS_DIR>/projects`

### 1. Fetch project details

**Try Linear first**: call `mcp__claude_ai_Linear__get_project` with the parsed ID. If it succeeds, capture: name, description, status (state name), url, content.

**If Linear is unavailable or the fetch fails**, ask the user:
- "Project title?"
- "What's the goal? (1-3 sentences)"
- "Any shared technical context tickets in this project need? (optional)"

Set status to `active` if not from Linear; set url to the argument if it was a URL.

### 2. Determine project ID

- If Linear returned a slug, use it (lowercased, hyphens preserved).
- Otherwise use whatever the user typed (or asked for).
- Reject IDs containing `/` or whitespace — ask for a valid one.

Store as `<PROJECT_ID>`.

### 3. Check if project dir exists

If `<TICKETS_DIR>/projects/<PROJECT_ID>/` already exists, stop and tell the user — they can use `jt project show <PROJECT_ID>` to view it.

```bash
mkdir -p <TICKETS_DIR>/projects/<PROJECT_ID>
```

### 4. Write PROJECT.md

Write `<TICKETS_DIR>/projects/<PROJECT_ID>/PROJECT.md`. Populate Goal from the Linear description (or user input); Architecture from any structured content blocks Linear returned, or leave with a placeholder.

```markdown
# <PROJECT_ID>: <title>

> Read this for the big-picture context before working on any ticket in this project.

## Current State

**Status**: <status>
**Linear URL**: <url or "(none)">
**Last updated**: <today YYYY-MM-DD>

## Goal

<1-3 sentence summary of what we're trying to achieve and why>

## Architecture / Shared Context

<technical context, constraints, conventions every ticket needs to know — or "(to be filled)">

## Key Decisions

(none yet)

## Tickets

| Ticket | Title | Status | Last Session |
|--------|-------|--------|--------------|

## Open Questions

(none yet)
```

### 5. Write project README.md

Write `<TICKETS_DIR>/projects/<PROJECT_ID>/README.md`:

```markdown
# <PROJECT_ID>: <title>

| Field | Value |
|-------|-------|
| **URL** | <url or "(none)"> |
| **Status** | <status> |
| **Created** | <today YYYY-MM-DD> |

## Description

<description, first 500 chars>

## Quick view

`jt project show <PROJECT_ID>`
```

### 6. Update PROJECTS.md index

Read `<TICKETS_DIR>/PROJECTS.md`. If it doesn't exist, create it:

```markdown
# Juggle Projects

| Project | Title | Status | Created |
|---------|-------|--------|---------|
```

Append a row:

```
| [<PROJECT_ID>](./projects/<PROJECT_ID>/PROJECT.md) | <title> | <status> | <today> |
```

### 7. Report to user

```
<PROJECT_ID> initialized.
  Title:   <title>
  Dir:     <TICKETS_DIR>/projects/<PROJECT_ID>/

Files created:
  <TICKETS_DIR>/projects/<PROJECT_ID>/PROJECT.md
  <TICKETS_DIR>/projects/<PROJECT_ID>/README.md

Updated:
  <TICKETS_DIR>/PROJECTS.md

Next: link tickets to this project with `jt init <ticket> --project <PROJECT_ID>` or pick it from the prompt during `/jt-init`.
```
