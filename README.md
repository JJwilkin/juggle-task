# Juggle-Task (jt)

> Persistent ticket context for Claude Code. Never lose your place when switching between tasks.

When you work across multiple tickets and Claude sessions, context disappears every time you switch branches. Juggle fixes that by creating a persistent `CONTEXT.md` for each ticket — a living document that any Claude session can read to immediately pick up where you left off.

## How it works

```
jt init PROJ-123         ← creates ~/juggle-task/PROJ-123/ from your ticket tracker
  ... do work ...
/jt-update               ← saves what you did + next steps to CONTEXT.md
  ... close session ...
jt open PROJ-123         ← checks out the branch, launches Claude with full context pre-loaded
```

Each ticket directory contains:
- **`CONTEXT.md`** — the key file: current state, what was done, decisions, next steps
- **`README.md`** — ticket metadata (URL, branch, priority, session history)
- **`IMPLEMENTATION.md`** — planning doc stub

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/JJwilkin/juggle-task/main/install.sh | bash
```

This installs:
- Two Claude Code skills (`/jt-init`, `/jt-update`) to `~/.claude/skills/`
- The `jt` CLI to `~/.local/bin/jt`

**Then restart Claude Code** to load the new skills.

To pin a specific version:
```bash
JUGGLE_VERSION=v0.2.0 curl -fsSL https://raw.githubusercontent.com/JJwilkin/juggle-task/main/install.sh | bash
```

## Commands

### Terminal (`jt`)

| Command | What it does |
|---------|-------------|
| `jt init <ticket>` | Create ticket context, launch Claude to run `/jt-init` |
| `jt open [ticket]` | Checkout branch + launch Claude with context pre-loaded |
| `jt update` | Launch Claude to save session progress via `/jt-update` |
| `jt ls` | List all tracked tickets |
| `jt config [set <path>]` | View or change the tickets directory |
| `jt upgrade` | Upgrade to the latest version |

### Claude skills (`/jt-*`)

| Skill | What it does |
|-------|-------------|
| `/jt-init <ticket>` | Create ticket context from ID or URL, check out branch, name the session |
| `/jt-update` | Save session progress, next steps, and session log to `CONTEXT.md` |

### `jt init`

Accepts a ticket ID or URL:
```bash
jt init PROJ-123
jt init https://linear.app/myorg/issue/PROJ-123/my-ticket-title
```

Launches Claude and automatically runs `/jt-init` — no manual typing required. With [Linear MCP](#linear-integration) configured, it auto-populates title, description, priority, and branch name. Without it, Claude will ask — works with any tracker or none.

### `jt open`

The primary way to resume work. Checks out the branch and launches an interactive Claude session with `CONTEXT.md` pre-loaded as context. The session is automatically named after the ticket.

```bash
jt open PROJ-123
jt open              # interactive picker if no argument
```

### `/jt-update`

Run inside a Claude session at the end of your work to checkpoint progress:

```
/jt-update
```

Claude detects the current ticket from the branch name, summarises what was accomplished, and updates `CONTEXT.md` with session notes, decisions, and new next steps. Also updates the ticket index.

## Typical workflow

```
# Start a new ticket
jt init PROJ-123

# ... do work across one or more sessions ...

# End of session — save context
/jt-update

# Resume later (new Claude session, full context pre-loaded)
jt open PROJ-123
```

Each `jt open` starts a fresh Claude session named after the ticket. Each `/jt-update` appends to the session history so you always have a complete record.

## Configuration

Juggle stores your tickets directory in `~/.jt-config` (a single line containing the path). Default: `~/juggle-task`.

```bash
# View current config
jt config

# Change tickets directory
jt config set /path/to/your/tickets
```

On first `/jt-init`, if no config exists, Juggle will ask where you want to store tickets.

## Linear integration

Juggle optionally integrates with [Linear](https://linear.app) via the Claude AI Linear MCP server. When configured, `/jt-init` auto-populates the ticket title, description, priority, status, and branch name from Linear.

To set up Linear MCP in Claude Code, follow the [Claude AI MCP setup guide](https://www.anthropic.com/news/model-context-protocol) and connect your Linear workspace.

Without Linear, `/jt-init` simply asks for a title and description — it works with any issue tracker or no tracker at all.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/JJwilkin/juggle-task/main/uninstall.sh | bash
```

This removes the Claude skills and `jt` binary. Your tickets directory and `~/.jt-config` are left untouched.

## License

MIT
