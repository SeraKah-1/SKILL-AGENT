# Project Rules — PA-SDLC (Grok)

Contract for AI assistants in this workspace. Prefer Superpowers process skills (brainstorming, TDD, debugging, verification) for *how*; this file sets *what must never be skipped*.

User instructions always win on conflict.

---

## Workflow (scaled to task size)

### Small tasks (1 file, clear bug, copy tweak)
1. State acceptance criteria in one line.
2. Implement.
3. Verify with evidence (command output / test / screenshot of behavior).
4. Update `session_state.md`.

### Medium / large (feature, new UI, multi-file, ambiguous)
Follow PA-SDLC:

| Phase | Do | Skip when |
|-------|-----|-----------|
| **1. Setup & no-halu** | Challenge XY-problem; list explicit assumptions; research deps/APIs via web; audit credentials; atomic plan. For greenfield: write `docs/setup_blueprint.md` (env placeholders only). | Trivial one-liners |
| **2. UI design** | Only for user-facing UI. Bold aesthetic OR clean internal-tool UI (see frontend-design). Optional: spawn `ui-designer` using `.grok/agents/ui-designer.md`. | No UI / pure backend |
| **3. Code** | Modular implementation; simplify as you go. Prefer TDD when adding behavior. | — |
| **4. Destructive QA** | Happy path + boundaries + empty/null + failures. Optional: spawn `qa-engineer` using `.grok/agents/qa-engineer.md`. | Pure docs / config |
| **5. Deep debug** | Stop & think → cascade → root cause → structural fix → re-run full suite. No symptom patches. | Tests green |

**Subagents over skill bloat:** do not add dozens of SKILL.md files for roles. Use focused subagents on demand.

---

## Frontend design

**Trigger:** building or styling user-facing UI.

- Commit to a bold theme before coding (Brutalist, Industrial, Editorial, Playful, Retro-futurism, etc.).
- Avoid generic AI slop: Inter + purple gradients + glassmorphism + uniform card grids.
- Characterful display font + clean body font; palette via CSS variables.
- Layout with intentional negative space / density, not cookie-cutter grids.

**Exception — internal tools / admin / data-heavy UI:** prioritize clarity and scanability over bold aesthetics. Neutral palette, dense tables, standard viz.

---

## Test & QA

- Destructive mindset: boundaries, empty states, network failures, error paths.
- Keep tests out of production modules.
- Run tests in the terminal; fix from real failure output.

---

## Simplify (post-green)

- Flatten nested conditionals with early returns.
- Clarity over cleverness (no nested ternary forests).
- Comments explain *why*, not *what*.
- Optional: spawn `code-simplifier` using `.grok/agents/code-simplifier.md` after tests pass.

---

## Research & anti-obsolence

1. Web-search technical claims, APIs, and library versions — do not trust stale model memory.
2. Recurring bugs: Research → Understand → Design → Implement → Verify. No patch loops.
3. Prefer current non-deprecated APIs from official docs.

---

## Anti-rationalization & verification

Forbidden excuses: "too simple for tests", "refactor later", "no spec needed", "seems right".

**Done = evidence:** passing tests, successful build, or observed runtime behavior. Never mark a phase complete without proof.

---

## Session memory

- **Start of session / task:** read `session_state.md` in project root.
- **End of task:** append a brief log entry.
- **Compaction:** keep ≤10 recent entries; fold older ones into "Archived Logs Summary" (aim under 300 tokens for the log body).

---

## Coding conventions

- **Modules:** ES modules with explicit extensions where the runtime expects them (`.js` / `.ts`).
- **Names:** files `kebab-case`; React components `PascalCase`; functions/vars `camelCase`.
- **Components:** single responsibility, accessible (WCAG-minded).
- **Package manager:** `npm` unless the project already standardizes on something else — do not mix managers in one project.
- **Dev servers:** project scripts (`npm run dev`, etc.).

### Errors

Never swallow errors. Prefer structured results or rethrow with context.

```typescript
// bad
try {
  return await fetchApi();
} catch (error) {
  console.log(error);
}

// good
try {
  const data = await fetchApi();
  return { success: true, data };
} catch (error) {
  logger.error("Failed to fetch API data", { error });
  return {
    success: false,
    error: error instanceof Error ? error.message : "Unknown error",
  };
}
```

---

## Credentials

- Never hardcode secrets. Use env vars / `.env` (gitignored).
- Ask for missing keys early in Phase 1.
