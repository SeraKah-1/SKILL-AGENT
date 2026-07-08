# SKILL-AGENT (lean)

Pragmatic **PA-SDLC** contract for **Grok** (and other agents that read project rules). Distilled from the original Antigravity config — process kept, shell/dashboard cruft removed.

## What's in here

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Project contract: workflow, design/QA/simplify rules, verification gates, coding standards |
| `session_state.md` | Short memory anchor (≤10 entries, compact older logs) |
| `.grok/agents/` | Optional subagent prompts: `ui-designer`, `qa-engineer`, `code-simplifier` |
| `docs/setup_blueprint.template.md` | Phase-1 blueprint template for greenfield work |

## What was removed (on purpose)

- `install.sh` (home symlinks / Claude-Gemini path pollution)
- `token-monitor*.sh` + `dashboard/` (Antigravity brain paths only)
- Thin `/token` and `/dashboard` skills & commands
- `brain/*.metadata.json` and path-hardcoded research dumps

Ideas from research (subagents over skill bloat, destructive QA, no-halu planning) live in `AGENTS.md` and `.grok/agents/`.

## How to use on a real project

```bash
# From this repo, copy the contract into a product repo:
cp AGENTS.md session_state.md /path/to/project/
mkdir -p /path/to/project/.grok/agents
cp .grok/agents/*.md /path/to/project/.grok/agents/
# optional blueprint when starting greenfield:
mkdir -p /path/to/project/docs
cp docs/setup_blueprint.template.md /path/to/project/docs/setup_blueprint.md
```

Open the product repo in Grok. Grok loads `AGENTS.md` automatically.

### Workflow reminder

- **Small:** criteria → code → evidence → update `session_state.md`
- **Large:** Phase 1 no-halu → (UI design) → code → destructive QA → deep debug if needed
- Process skills (Superpowers, etc.) handle *how*; `AGENTS.md` is the non-negotiable *what*

### Subagents

When spawning a specialist, paste or attach the matching file under `.grok/agents/`. On-demand only — not every task.

## License

MIT (same spirit as upstream)
