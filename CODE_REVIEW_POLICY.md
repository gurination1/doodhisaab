# Code Review Policy

Use `code-review-graph` first for this repository when it is available in the current Codex session.

Default behavior:

- Start review, impact analysis, architecture tracing, and codebase exploration with `code-review-graph`.
- If `code-review-graph` MCP is not available in the current session, fall back immediately to direct repo inspection with `rg`, `find`, and targeted file reads.
- Do not block simple fixes or one-file tasks on graph availability.

Repository registration:

- Alias: `doodhisaab`
- Root: `/home/nyx/doodhisaab/work/step23/step23`

Current graph status at setup time:

- 57 files
- 664 nodes
- 1040 edges

Main intent:

- smarter reviews first
- faster impact tracing
- safe fallback when MCP is unavailable
