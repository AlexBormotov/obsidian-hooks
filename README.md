# Obsidian Docs Hooks for Claude Code

Self-documenting project setup for [Claude Code](https://claude.com/claude-code): an Obsidian-based documentation vault plus three portable hooks that keep it up to date automatically.

## What it does

- **SessionStart hook** — at the start of every session, injects the documentation hub (`INDEX.md`) into Claude's context. Claude immediately knows the project structure and the rule: *check the code map before writing new code — adapt existing code instead of duplicating it.*
- **PostToolUse hook** — silently records every source file Claude creates or edits during a turn.
- **Stop hook** — if source files changed, blocks Claude from finishing its reply until it documents the changes: a note per file in the code map (purpose, classes, methods), links to the relevant section, and a dated entry in `Timeline.md`.

The result: a living documentation graph. Open `.claude/docs/obsidian/` as an Obsidian vault and use Graph View to see your whole project — code, design, marketing, finance, planning — as connected notes.

## Structure

```
.claude/
├── settings.json                        # hooks wiring (merge into yours if it exists)
├── hooks/
│   ├── obsidian-docs-sessionstart.sh    # SessionStart: inject INDEX.md into context
│   ├── obsidian-docs-track.sh           # PostToolUse: record changed source files
│   └── obsidian-docs-stop.sh            # Stop: require docs update before finishing
└── docs/
    └── obsidian/                        # the Obsidian vault
        ├── INDEX.md                     # hub — every section links from here
        ├── Backend.md  Frontend.md  Design.md  Marketing.md
        ├── SEO.md  Finance.md  Analytics.md  Planning.md
        ├── Timeline.md                  # dated log of what was done and when
        └── code-map/
            ├── backend/                 # one note per source file
            └── frontend/
```

## Installation

1. Copy the `.claude/` directory into your project root.
2. If your project already has `.claude/settings.json`, merge the `"hooks"` block from this template into it instead of overwriting.
3. Restart Claude Code (or run `/hooks` once) so it picks up the new hooks.
4. Open `.claude/docs/obsidian/` as a vault in Obsidian (File → Open folder as vault).

That's it. No per-project configuration: the scripts use only relative paths and plain bash (no `jq` or other dependencies). If the vault directory is missing, all three hooks silently do nothing — safe to keep in projects that don't use it.

## Requirements

- Claude Code CLI
- `bash` available on PATH (on Windows: Git Bash, installed with Git for Windows)
- Obsidian (optional — only for viewing the graph; the vault is plain Markdown)

## How the update loop works

1. Claude edits `backend/app/api/auth.py` during a turn.
2. The PostToolUse hook appends the path to a marker file.
3. When Claude tries to finish, the Stop hook sees the marker, clears it, and blocks once with instructions: document the file in `code-map/backend/app-api-auth.md`, link it from `Backend.md`, add a `Timeline.md` entry.
4. Claude updates the docs and finishes. The second stop passes (guarded by `stop_hook_active` — no infinite loops).

Edits inside `.claude/` (including the vault itself) are ignored, so documenting doesn't re-trigger the hook.

## When exactly docs get updated

- **Regular request:** the Stop hook fires at the end of a *turn* (when Claude finishes its reply), not after every single edit. One documentation pass per turn that touched source files; turns with no source changes stay silent.
- **Iterative / goal-driven runs (loops, autonomous agents):** each iteration is a separate turn, so docs are updated at the end of every iteration — documentation grows alongside the work instead of one big dump at the end. Within a single long turn (many steps without stopping), documentation happens once, at the end of that turn.
- **Subagents (Task/Agent tool):** the PostToolUse hook also sees files edited by subagents, so their changes accumulate in the marker. The *main* agent documents everything when it stops, with full visibility of what its subagents did. Subagents themselves don't trigger the docs pass (their stop is a separate `SubagentStop` event, intentionally not hooked) — otherwise every subagent would run its own redundant pass.
- **Agent teams / teammates:** a teammate is a full Claude Code session in the same project, so it gets the same hooks: the docs hub in context at start, and its own documentation pass on stop for its own changes. Caveat: teammates working in parallel may append to `Timeline.md` and the marker files concurrently — rare interleaved entries are possible. Nothing breaks, but it's worth skimming `Timeline.md` after a heavy team session.

## Managing sections

Sections are just notes — add or remove them freely. The hooks are not tied to section names; only two paths are hardcoded: `INDEX.md` (read by the SessionStart hook) and `Timeline.md` (mentioned in the Stop hook's instructions).

- **Add a section:** create the note, link it from `INDEX.md`. Done.
- **Remove a section:** delete the note, remove its link from `INDEX.md`.
- **Claude creating sections on its own:** nothing forbids it — the Stop hook says "update the relevant section note", and when no section fits, Claude will usually create one. To make this behavior explicit rather than incidental, add a line to the Conventions in `INDEX.md`, e.g.: *"Claude may create new sections when a topic doesn't fit existing ones — add the note and link it from INDEX."*

## Conventions

- Code map note names: relative source path with `/` → `-` (e.g. `src/routes/index.tsx` → `code-map/frontend/routes-index.md`)
- Note filenames in ASCII; content in any language
- Every note links back to its section; sections link back to `[[INDEX]]`
- New entries in `Timeline.md` go on top

## Customization

- **Too noisy?** The Stop hook fires once per turn that changed source files. To relax it, edit `obsidian-docs-stop.sh` — e.g. exit 0 unless the changed list contains certain paths.
- **Different vault location?** Change the `DOCS` variable at the top of all three scripts and the paths in `INDEX.md`.
- **More sections?** Add a note, link it from `INDEX.md`. The hooks don't care about section names.
