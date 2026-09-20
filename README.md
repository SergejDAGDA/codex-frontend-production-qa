# Frontend Production QA

[Русская версия](README.ru.md)

A reusable Codex skill for production-grade frontend implementation and QA.

It does not replace specialist skills. It orchestrates them and defines when a browser-facing task can be considered complete.

## Why this exists

A frontend change can compile and still be wrong:

- a fix for desktop breaks mobile;
- one screenshot looks right while another viewport overflows;
- a shared component regresses on another route;
- screenshots are generated but never inspected;
- visual baselines are updated instead of fixing the regression;
- a plugin is registered but the required skill payload is not actually available.

`frontend-production-qa` adds an evidence-based completion workflow around those failure modes.

## Core workflow

```text
project rules
  -> understand/reproduce
  -> frontend implementation
  -> design-quality layer when relevant
  -> code checks
  -> real browser
  -> responsive verification
  -> rendered visual QA
  -> regression closure
  -> conditional review/security/performance/release gates
  -> completion evidence
```

## Verification classes

| Class | Typical change | Required verification |
|---|---|---|
| A | layout, responsive, typography wrapping, shared UI, navigation, release prep | real browser + full 8-viewport matrix + visual QA + regression closure |
| B | small visual change with no plausible geometry impact | real browser + reduced 3-viewport matrix + visual inspection |
| C | nonvisual browser-facing change | targeted browser verification |
| D | backend/non-UI | no frontend workflow unless rendered browser behavior changes |

Full matrix:

```text
320x568
375x812
390x844
768x1024
1024x768
1280x800
1440x900
1920x1080
```

Reduced matrix:

```text
390x844
768x1024
1440x900
```

If breakpoint `B` changes or is suspected, also test `B-1`, `B`, and `B+1`.

## Required specialist stack

The workflow expects:

- `frontend-ui-engineering`
- `browser-testing-with-devtools`
- `frontend-visual-qa`
- Chrome DevTools MCP

The first two come from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

`frontend-visual-qa` comes from [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills).

Chrome DevTools MCP comes from [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp).

Recommended design-quality layer:

- [Impeccable](https://github.com/pbakaus/impeccable)

Optional existing integrations:

- `taste-skill`
- `karpathy-guidelines`
- `context-engineering`
- `maintain-project-memory`

The orchestrator does not install or update optional integrations.

## Install this skill

Install/copy only:

```text
skills/frontend-production-qa/
```

For a user-wide Codex install, place it under:

```text
~/.agents/skills/frontend-production-qa/
```

Then start a fresh Codex session.

## Project routing

Do not copy the whole skill into a project's `AGENTS.md`.

Use the short routing fragment:

```text
skills/frontend-production-qa/assets/AGENTS.frontend.fragment.md
```

Project-specific architecture, legal constraints, design decisions and memory remain authoritative in the project itself.

## Toolchain operations

From the installed skill directory:

```powershell
.\scripts\check-frontend-toolchain.ps1
.\scripts\bootstrap-frontend-toolchain.ps1
.\scripts\check-frontend-updates.ps1
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Normal frontend work must not silently install or update third-party dependencies.

See:

- [Dependencies](skills/frontend-production-qa/references/dependencies.md)
- [Verification matrix](skills/frontend-production-qa/references/verification-matrix.md)
- [Toolchain maintenance](skills/frontend-production-qa/references/toolchain-maintenance.md)

## Central completion rule

Any later CSS/layout/spacing/typography/positioning/sizing/visibility/breakpoint/shared-style change invalidates the previous visual verification for the affected surface.

Re-run the applicable browser and responsive checks after the fix.

Do not report `done`, `fixed`, or `ready` when required verification is incomplete.

## License

MIT.
