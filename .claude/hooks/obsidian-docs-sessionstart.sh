#!/usr/bin/env bash
# SessionStart hook: inject the Obsidian docs hub into Claude's context.
# Portable: relies only on cwd == project root; silently no-ops if the vault is absent.
DOCS=".claude/docs/obsidian"
[ -f "$DOCS/INDEX.md" ] || exit 0

echo "PROJECT DOCUMENTATION GRAPH: this project keeps its full documentation as an Obsidian vault at $DOCS/ (hub: INDEX.md). Before writing new code, consult the code map notes (code-map/) to check whether a similar file/class/function/method already exists — prefer adapting existing code over creating duplicates. Keep the vault updated as you work."
echo ""
echo "--- $DOCS/INDEX.md ---"
cat "$DOCS/INDEX.md"
exit 0
