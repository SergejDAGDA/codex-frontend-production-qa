---
name: frontend-production-qa
description: Orchestrates production-grade frontend implementation and verification across engineering, real-browser testing, responsive checks, visual QA, regression closure, and conditional review gates. Use for browser-facing UI work. Do not use for backend-only or non-UI tasks unless rendered browser behavior changes.
---

# Frontend Production QA

## Role

This skill is an orchestrator.

It coordinates specialist skills and defines the evidence required before a browser-facing task may be considered complete.

It does not replace the specialist skills themselves.

## Authority

Project-local `AGENTS.md`, architecture, legal constraints, accessibility requirements, design decisions, product rules and project-memory policy remain authoritative.

Do not migrate frameworks, replace build systems, redesign the product, or introduce competing project-memory/design documents unless explicitly requested.

## Required runtime stack

Expected capabilities:

- `frontend-ui-engineering`
- `browser-testing-with-devtools`
- `frontend-visual-qa`
- Chrome DevTools MCP

`frontend-visual-qa` is bundled with this plugin. Use the bundled copy as the
version-consistent visual QA layer; do not substitute a separately installed
upstream copy without reviewing the diff first.

If a required specialist skill is missing:

1. do not pretend that phase ran;
2. use an equivalent direct procedure when possible;
3. report the missing dependency and reduced coverage.

If a real browser cannot be used, full frontend verification is blocked.

## Design references with bundled Inspo

The plugin bundles an `inspo` MCP server backed by the hosted Inspo catalogue.

Use it selectively before implementation when the task involves:

- a new page or interface;
- a new visual component;
- a substantial redesign;
- visual-direction exploration;
- hierarchy or layout exploration;
- an explicit request for references or inspiration.

Prefer the high-level Inspo recommendation flow first, then inspect specific design systems or components only when useful.

Treat Inspo as reference material, not project authority.

Do not use external inspiration to override an existing approved visual language, exact screenshot target, project design system, or project-specific constraints.

For ordinary bug fixes, responsive regressions, faithful existing-design work, and minor visual corrections, skip Inspo unless it materially helps.

If the bundled Inspo MCP is unavailable, report that limitation when reference research was actually needed. Its absence does not block ordinary frontend regression work.

## Recommended and optional layers

Use Impeccable for meaningful design/layout/typography/hierarchy/responsive critique or polish when it is installed and relevant.

Optional locally available integrations may include:

- `taste-skill`
- `karpathy-guidelines`
- `context-engineering`
- `maintain-project-memory`

Never let optional tools override project rules.

## Toolchain mutation policy

Normal frontend work may perform local presence/readiness checks.

Normal frontend work must not silently:

- install dependencies;
- update dependencies;
- replace third-party skills;
- initialize Impeccable;
- approve hooks.

Bootstrap and updates are explicit maintenance operations only.

## Classify the change first

### Class A — layout/responsive/shared/release

Examples:

- layout or spacing geometry;
- width/height changes;
- grid/flex behavior;
- breakpoints;
- typography affecting wrapping;
- visibility or positioning;
- shared UI;
- header/footer/navigation;
- modal/drawer geometry;
- responsive media;
- release preparation.

Required:

- real browser;
- full viewport matrix;
- rendered visual QA;
- regression closure.

### Class B — minor visual

Use only when there is no plausible effect on geometry, wrapping, sizing, visibility, or responsive behavior.

Examples:

- color-only correction;
- border color;
- icon color.

Required:

- real browser;
- reduced viewport matrix;
- visual inspection.

If uncertain, promote to Class A.

### Class C — nonvisual browser-facing

Examples:

- link target;
- metadata;
- accessible name;
- browser-side logic with no layout effect.

Required:

- targeted browser verification;
- relevant functional/accessibility check.

### Class D — backend/non-UI

Do not use the frontend workflow unless the change directly alters rendered browser behavior.

## Phase 1 — Understand and reproduce

Before editing:

1. read project instructions;
2. inspect the relevant implementation;
3. identify affected routes/states;
4. identify layout system and breakpoints;
5. identify shared components;
6. identify existing tests/browser tooling;
7. reproduce the defect when practical.

Do not assume the visible symptom is the root cause.

## Phase 2 — Establish design direction when warranted

For new UI, redesign, or substantial visual exploration, use the bundled Inspo reference layer before implementation.

Extract transferable patterns such as hierarchy, composition, spacing logic, navigation structure, component archetypes, and responsive strategy.

Do not copy branding, proprietary content, or another site's visual identity.

If the task is an existing-design bug fix or regression, preserve the existing project instead of inventing a new direction.

## Phase 3 — Implement

Use `frontend-ui-engineering`.

Prefer root-cause fixes and existing project conventions.

Avoid:

- arbitrary offsets;
- unexplained negative margins;
- unnecessary absolute positioning;
- one-screenshot breakpoint hacks;
- duplicate responsive exceptions;
- unrelated cleanup;
- framework migration without approval.

## Phase 4 — Code-level checks

Run applicable existing checks:

- lint;
- type checking;
- unit/component/integration tests;
- end-to-end tests;
- production build.

Use TDD when the changed behavior can reasonably be protected by a regression test.

A passing build is not evidence that rendered UI is correct.

## Phase 5 — Real browser

Use `browser-testing-with-devtools`.

Inspect as applicable:

- rendered DOM;
- geometry/layout;
- console;
- failed requests;
- interactions;
- accessibility structure;
- screenshots;
- viewport behavior.

New relevant console errors caused by the change are blockers.

## Phase 6 — Responsive verification

Read `references/verification-matrix.md`.

Class A uses the full matrix.

Class B uses the reduced matrix.

Class C uses targeted verification.

If breakpoint `B` changed or is suspected, also test `B-1`, `B`, and `B+1`.

## Phase 7 — Rendered visual QA

Use `frontend-visual-qa`.

Screenshots must be opened and visually inspected. Generating them is not enough.

Inspect the affected region and surrounding layout context.

For long pages, inspect below the fold.

For shared components, inspect representative consuming routes.

Do not update visual baselines merely to silence a regression.

## Regression closure

This is the central rule.

Any later change to:

- CSS;
- layout;
- spacing;
- typography;
- positioning;
- sizing;
- visibility;
- breakpoint logic;
- component structure;
- shared frontend styles

invalidates previous visual verification for the affected surface.

After the fix, rerun the applicable browser and viewport verification.

Do not retest only the originally failing viewport.

Repeat until the affected verification surface is clean.

## Shared impact

When a shared primitive changes, broaden verification.

Examples:

- global header/footer/navigation;
- page shell/container;
- typography;
- CSS variables/design tokens;
- forms/buttons/cards/modals;
- global media rules.

Verify representative consumers across routes.

## Conditional final gates

Use additional specialist skills when applicable:

- `code-review-and-quality` for substantial/shared/release work;
- `security-and-hardening` for auth, uploads, permissions, tokens, sensitive input/data;
- `performance-optimization` when loading/rendering/assets/JS cost/Core Web Vitals may change;
- `shipping-and-launch` for production release/deployment preparation.

Do not force irrelevant gates into trivial work.

## Completion evidence

Before reporting completion, state:

- what changed;
- root cause when applicable;
- routes/pages checked;
- viewport sizes checked;
- code checks run;
- browser checks run;
- console status;
- visual QA status;
- shared consumers checked;
- anything blocked or unverified.

Do not say `done`, `fixed`, `ready`, or equivalent when required verification is incomplete.

Read:

- `references/verification-matrix.md`
- `references/dependencies.md`
- `references/toolchain-maintenance.md`
