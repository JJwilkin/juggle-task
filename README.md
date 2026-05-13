# Juggle

> Persistent ticket context for Claude Code. Never lose your place when switching between tasks.

When you work across multiple tickets and Claude sessions, context disappears every time you switch branches. Juggle fixes that by creating a persistent `CONTEXT.md` for each ticket — a living document that any Claude session can read to immediately pick up where you left off.

## How it works

```
/jt-init JUD-4908        ← creates ~/juggle-tickets/JUD-4908/ from your ticket tracker
  ... do work ...
/jt-update               ← saves what you did + next steps to CONTEXT.md
  ... switch tickets ...
jt open JUD-4908         ← checks out the branch, launches Claude with full context
```

Each ticket directory contains:
- **`CONTEXT.md`** — the key file: current state, what was done, decisions, next steps
- **`README.md`** — ticket metadata (URL, branch, priority, session history)
- **`IMPLEMENTATION.md`** — planning doc stub

## Install

```bash
git clone https://github.com/JJwilkin/juggle && cd juggle && bash install.sh
```

This installs:
- Three Claude Code skills (`/jt-init`, `/jt-update`, `/jt-switch`) to `~/.claude/skills/`
- The `jt` CLI to `~/.local/bin/jt`

**Then restart Claude Code** to load the new skills.

## Claude Code skills

Run these inside a Claude Code session:

| Command | What it does |
|---------|-------------|
| `/jt-init <ticket>` | Create ticket context from a ticket ID or URL |
| `/jt-update` | Save this session's progress to `CONTEXT.md` |
| `/jt-switch <ticket>` | Checkout branch + load context into current session |

### `/jt-init`

Accepts a ticket ID or URL:
```
/jt-init JUD-4908
/jt-init https://linear.app/myorg/issue/JUD-4908/my-ticket-title
/jt-init PROJ-42
```

With [Linear MCP](#linear-integration) configured, it auto-populates from your issue tracker. Without it, it asks for a title and description.

### `/jt-update`

Run at the end of a session to checkpoint your work:
```
/jt-update
```
Claude detects the current ticket from your branch name, asks what you accomplished, and updates `CONTEXT.md` with the session notes and new next steps.

### `/jt-switch`

Load a ticket's context into the current Claude session:
```
/jt-switch JUD-4908
```
Checks out the branch and prints a structured summary so Claude can immediately resume.

## Terminal CLI

```bash
jt ls                      # list all tracked tickets
jt switch JUD-4908         # checkout branch + print CONTEXT.md
jt open JUD-4908           # checkout branch + launch claude with context pre-loaded
jt config                  # show tickets directory
jt config set ~/my-tickets # change tickets directory
jt help                    # show all commands
```

`jt open` is the fastest way to resume work: it checks out the branch and launches Claude Code with your `CONTEXT.md` as the opening message.

## Configuration

Juggle stores your tickets directory path in `~/.jt-config` (a single line containing the path). Default: `~/juggle-tickets`.

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
bash uninstall.sh
```

This removes the Claude skills and `jt` binary. Your tickets directory and `~/.jt-config` are left untouched.

## License

MIT
