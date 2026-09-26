# Frontend Production QA

[Русская версия](README.ru.md)

A reusable Codex plugin for production-grade frontend implementation and QA.

It does not replace specialist skills. It orchestrates them, defines how deeply a browser-facing change must be verified, and decides when the work has enough evidence to be considered complete.

## Why this exists

A frontend change can compile and still be wrong:

- a desktop fix breaks mobile;
- one screenshot looks right while another viewport overflows;
- a shared component regresses on another route;
- screenshots are generated but never inspected;
- a visual baseline is updated instead of fixing the regression;
- animation looks fine at rest but breaks during transition or with reduced motion;
- a plugin appears installed while the expected skill payload is unavailable.

`frontend-production-qa` adds an evidence-based completion workflow around those failure modes.

## Install from GitHub

The GitHub repository is the canonical source. Do not maintain a separate manual copy of this skill when using the plugin distribution.

```powershell
codex plugin marketplace add SergejDAGDA/codex-frontend-production-qa --ref main
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

Start a fresh Codex session after installation.

### Update from GitHub

```powershell
codex plugin marketplace upgrade codex-frontend-production-qa
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

Then start a fresh Codex session.

The second command is intentionally safe to repeat and ensures the installed plugin payload is materialized from the refreshed marketplace snapshot.

### One source of version truth

The public plugin version lives only in:

```text
plugin.json
```

Do not add separate release versions to `SKILL.md` or dependency manifests.

Every published plugin change must bump the manifest version and update `CHANGELOG.md` in the same repository change.

### Migrating from old manual installs

If `frontend-production-qa` or `frontend-visual-qa` was previously copied manually under `~/.agents/skills/`, remove or rename the stale manual copy before using plugin distribution. The maintained `frontend-visual-qa` is bundled inside this repository and must not be restored as a floating runtime dependency from Daymade.

## Bundled Inspo MCP

The plugin bundles the hosted [Inspo](https://github.com/Nutlope/inspo) MCP endpoint:

```text
https://inspomcp.dev/api/mcp
```

Inspo provides searchable references from real production websites. The orchestrator uses it selectively for:

- new UI;
- new components;
- substantial redesigns;
- visual-direction exploration;
- hierarchy/layout exploration;
- explicit requests for references or inspiration.

It is not the design authority for an existing project. For bug fixes, screenshot matching, responsive regressions, or work that must preserve an established visual language, the project itself remains the source of truth.

No separate `codex mcp add inspo ...` is needed when the plugin is installed.

## Conditional Motion specialist

For animation-heavy work, the orchestrator can route to the official Motion AI Kit `/motion` skill from [motiondivision/ai-kit](https://github.com/motiondivision/ai-kit).

Install or update it independently with:

```powershell
npx motion-ai@latest
```

Motion is **recommended and conditional**, not required for core readiness and not bundled into this repository.

Use it when the task materially involves:

- animation or transitions;
- enter/exit presence;
- layout or shared-layout animation;
- drag, swipe, reorder, or gestures;
- spring motion;
- scroll-triggered or scroll-linked effects;
- animation performance.

The routing is CSS-first. Simple hover/focus/opacity/loading effects should stay native CSS when CSS is sufficient. Installing the `/motion` skill does not authorize adding the `motion` runtime package or replacing an existing animation library.

For material motion changes the workflow verifies initial, transient, settled, repeated/interrupted, and `prefers-reduced-motion` states as applicable.

See [Motion specialist routing](skills/frontend-production-qa/references/motion-specialist.md).

## Core workflow

```text
project rules
  -> understand/reproduce
  -> optional design references when warranted
  -> conditional motion specialist when warranted
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
| A | layout, responsive, typography wrapping, shared UI, layout-affecting motion, navigation, release prep | real browser + full 8-viewport matrix + visual QA + regression closure |
| B | small visual change or non-geometric transition | real browser + reduced 3-viewport matrix + visual inspection |
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

The core workflow expects:

- `frontend-ui-engineering`
- `browser-testing-with-devtools`
- bundled `frontend-visual-qa`
- Chrome DevTools MCP

The first two come from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

`frontend-visual-qa` is bundled in this repository. Its original upstream source is [daymade/claude-code-skills](https://github.com/daymade/claude-code-skills), but the maintained Codex-adapted copy here is the version used by this plugin. Runtime maintenance must not replace it from upstream.

Chrome DevTools MCP comes from [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp).

Recommended conditional specialists/layers:

- Motion AI Kit `/motion` for material animation/gesture work;
- [Impeccable](https://github.com/pbakaus/impeccable) for design-quality critique/polish.

Related optional skills:

- `ui-designer`;
- `qa-expert`.

Optional existing integrations:

- `taste-skill`;
- `karpathy-guidelines`;
- `context-engineering`;
- `maintain-project-memory`.

The orchestrator does not silently install or update recommended/optional integrations during normal frontend work.

## Project routing

Do not copy the whole skill into a project's `AGENTS.md`.

Use the short routing fragment:

```text
skills/frontend-production-qa/assets/AGENTS.frontend.fragment.md
```

Project-specific architecture, legal constraints, design decisions and memory remain authoritative in the project itself.

## Dependency maintenance

The plugin itself is updated through the Git-backed marketplace.

The maintenance scripts inside the skill manage only the core external specialist toolchain and Impeccable when explicitly requested:

```powershell
.\scripts\check-frontend-toolchain.ps1
.\scripts\bootstrap-frontend-toolchain.ps1
.\scripts\check-frontend-updates.ps1
.\scripts\update-frontend-toolchain.ps1 -Apply
```

The bundled `frontend-visual-qa` is updated only through repository/plugin releases.

Motion is independently installed or updated with:

```powershell
npx motion-ai@latest
```

Normal frontend work must not silently install or update third-party dependencies.

See:

- [Dependencies](skills/frontend-production-qa/references/dependencies.md)
- [Motion specialist routing](skills/frontend-production-qa/references/motion-specialist.md)
- [Verification matrix](skills/frontend-production-qa/references/verification-matrix.md)
- [Toolchain maintenance](skills/frontend-production-qa/references/toolchain-maintenance.md)

## Central completion rule

Any later CSS/layout/spacing/typography/positioning/sizing/visibility/breakpoint/animation/transition/shared-style change invalidates the previous visual verification for the affected surface.

Re-run the applicable browser, responsive, motion-state, and visual checks after the fix.

Do not report `done`, `fixed`, or `ready` when required verification is incomplete.

## License

MIT.
