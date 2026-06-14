# Project Rules and SOTA behavior Contract

This file defines the strict behavioral contract and coding standards that any AI assistant working in this workspace must adhere to.

---

## 🌀 SOTA Pragmatic Agentic SDLC (PA-SDLC) Workflow

All development tasks in this workspace must follow this 5-Fase cycle:

### 1. Fase 1: Setup, Riset, & Rencana No-Halu
*   **Challenge Assumptions (XY Problem):** Never blindly accept stated goals. Evaluate the foundational premises. 
*   **Explicit Assumption Listing:** Before writing any code or specs, list your assumptions to the user (e.g. "I'm assuming this is a web app using Postgres..."). If they are wrong, the user can correct them immediately.
*   **Research First:** Always query the web for SOTA packages and API validation to prevent using deprecated libraries or methods.
*   **Audit Kredensial:** Identify credentials, ports, databases, and SaaS settings. Prompt the user for required inputs at the start.
*   **Artifact-Driven & Verification:** Store workspace parameters in `setup_blueprint.md` using environment variable placeholders. Never proceed to coding without a clear, verified specification.
*   **Atomic Planning:** Break down implementation plans into bite-sized, verifyable tasks before coding.

### 2. Fase 2: Desain Estetika (`ui-designer`)
*   Establish layout structures, typography, and styling tokens using the **`frontend-design`** guidelines.

### 3. Fase 3: Pengkodean Utama (Antigravity)
*   Write modular, working code and perform real-time refactoring using the **`simplify`** guidelines.

### 4. Fase 4: Pengetesan QA Destruktif (`qa-engineer`)
*   Write automated test cases using the **`test-qa`** guidelines to check happy paths, boundary inputs, empty states, and failures.

### 5. Fase 5: Deep Debugging & Anti-Tambal-Sulam
*   **Stop & Think:** Audit impact cascade and trace logs to find the root cause.
*   **Structural Fixes:** Fix the structural cause, not just symptoms. Re-run all tests to prevent regression bugs.

---

## 🎨 Skill: frontend-design

**Trigger:** Building or styling user interfaces, components, or pages.
**Objective:** Kill the generic "failed 2021 startup" AI aesthetic (Inter font, purple gradients on dark background, glassmorphism, uniform grid cards) and build distinct, high-polish, production-grade interfaces.

*   **Aesthetic Direction:** Commit to a bold theme before coding (e.g., Brutalist, Industrial, Editorial, Playful, Retro-futurism).
*   **Typography:** Avoid generic defaults (Inter, Arial, system-sans). Pair a characterful display font with a clean body font.
*   **Color Systems:** Enforce a strict palette via CSS variables. Commit to a dominant theme with precise accent colors.
*   **Layout Asymmetry:** Use negative space, overlaps, or high-density grids instead of uniform card grids.
*   **Atmosphere:** Add visual depth using layered transparency, noise textures, gradient meshes, or custom borders.

---

## 🧪 Skill: test-qa

**Trigger:** Verification, testing, test plan creation, or bug diagnostics.
**Objective:** Perform objective, unbiased verification of code correctness.

*   **Destructive Verification:** Write test cases for boundary inputs, empty/null states, network failures, and error handling.
*   **Isolate Test Logic:** Write modular tests using Jest, Vitest, Playwright, or Cypress. Do not mix testing utilities into production assets.
*   **Analyze & Fix:** Run tests in the terminal. Use failure outputs to pinpoint exact lines needing repair.

---

## 🧹 Skill: simplify

**Trigger:** Post-implementation cleanup or logic review.
**Objective:** Prune complexity, reduce cognitive load, and keep code maintainable.

*   **Post-Implementation Pruning:** Simplify working code immediately after tests pass.
*   **Flatten Logic:** Use early returns (guard clauses) to eliminate nested `if-else` blocks.
*   **Clarity Over Brevity:** Avoid overly clever one-liners or nested ternaries. Prefer readable method chains, switch blocks, or helper functions.
*   **No Obvious Comments:** Remove comments that simply restate what the code does. Keep comments focused on *why* a business decision was made.

---

## 🛡️ Anti-Rationalization & Verification Gates

**Objective:** Prevent AI shortcuts ("this is too simple for tests", "I'll refactor later", "I don't need a spec for this").
*   **Anti-Rationalization:** Do not make excuses to skip steps. Simple tasks still need acceptance criteria. Fast workflows still require safety checks.
*   **Explicit Verification:** "Seems right" is never sufficient. Every task completion must be backed by evidence (passing tests, runtime data, successful builds). Do not declare a phase "Done" without verifiable proof.

---

## 💾 Session Memory Anchoring

*   **Read State:** Always read [session_state.md](file:///home/ayintaput/session_state.md) at the start of a session to recover context.
*   **Write State:** Append a brief log entry to [session_state.md](file:///home/ayintaput/session_state.md) at the end of every task or file modification.
*   **Compaction Policy:** Keep the log under 10 entries. When logs exceed 10 entries, condense older logs into an "Archived Logs Summary" section to maintain token efficiency (<300 tokens).

---

## 🛠️ General Workspace Rules

### 1. Coding & Conventions
*   **ES Modules:** Always use ES modules with explicit file extensions (`.js` / `.ts`) where applicable.
*   **Naming Conventions:**
    *   *Files:* kebab-case (e.g., `user-profile.tsx`, `api-client.ts`).
    *   *React Components:* PascalCase (e.g., `UserProfileCard`).
    *   *Functions & Variables:* camelCase (e.g., `fetchUserData`).
*   **Component Structure:** Keep components modular, accessible (WCAG-compliant), and focused on a single responsibility.

### 2. Error Handling Policy
*   **Never swallow errors.** Avoid empty `catch` blocks or simple logs that hide failures.
*   **Explicit Propagation:** Propagate errors to the UI or boundaries. Use structured return schemas.

#### ❌ Bad:
```typescript
try {
  const data = await fetchApi();
  return data;
} catch (error) {
  console.log(error); // Error swallowed, returns undefined causing crashes elsewhere
}
```

####   Good:
```typescript
try {
  const data = await fetchApi();
  return { success: true, data };
} catch (error) {
  logger.error("Failed to fetch API data", { error });
  return { success: false, error: error.message || "Unknown error" };
}
```

### 3. Package & Process Management
*   **Package Manager:** Standardize on `npm`. Do not mix with yarn or pnpm.
*   **Local Execution:** Run development servers using `npm run dev` or equivalent local commands.

### 4. Architecture: Subagents over Skill Bloat
*   **Zero Prompt Pollution:** Do NOT litter the workspace with hundreds of individual `SKILL.md` files or prompt templates.
*   **Subagent Delegation:** For specific domain tasks (UI Design, QA, Refactoring), instantiate dedicated **Subagents** (e.g., `ui-designer`, `qa-engineer`) with pure, focused system prompts. This preserves the context window and eliminates instruction hallucination.
