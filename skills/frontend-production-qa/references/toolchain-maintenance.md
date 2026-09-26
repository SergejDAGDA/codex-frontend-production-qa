# Toolchain Maintenance

Plugin self-updates and external specialist-toolchain maintenance are separate operations.

## Update frontend-production-qa itself

The canonical source is the GitHub repository registered as a Codex marketplace.

```powershell
codex plugin marketplace upgrade codex-frontend-production-qa
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

Start a fresh Codex session afterward.

The release version is declared only in:

```text
plugin.json
```

Every published plugin change must bump that version and update `CHANGELOG.md` in the same repository change.

Do not keep a second manually copied `frontend-production-qa` under `~/.agents/skills` when using plugin distribution.

The bundled `frontend-visual-qa` is updated only by updating this plugin repository. Do not bootstrap or replace it from `daymade/claude-code-skills` at runtime.

## Local readiness of external dependencies

```powershell
.\scripts\check-frontend-toolchain.ps1
```

This checks local command availability, required external specialist skill files, the bundled `frontend-visual-qa` payload, and Chrome DevTools MCP registration.

It may also report recommended specialists such as `/motion` when they are locally discoverable, but their absence does not make the core runtime unready.

It does not intentionally perform upstream network update checks.

It also does not claim that an already-running Codex session loaded a skill installed after that session started.

The bundled Inspo MCP and bundled `frontend-visual-qa` are owned by the plugin package and are not managed by the external-toolchain scripts.

## First-time external toolchain bootstrap

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1
```

This bootstrap handles required external dependencies only. It verifies that the bundled `frontend-visual-qa` is present in the installed plugin instead of fetching another copy.

Optional Impeccable install:

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1 -InstallImpeccable
```

After bootstrap, start a fresh Codex session.

## Motion AI Kit

Motion is a recommended conditional specialist and is intentionally maintained by its own official installer rather than these scripts.

Install or update it with:

```powershell
npx motion-ai@latest
```

The installer is interactive and may configure both the `/motion` skill and Motion's hosted MCP integration for the chosen agent/scope.

Do not add a bundled/forked Motion skill to this repository merely to avoid that external installer.

## Network update check for external dependencies

```powershell
.\scripts\check-frontend-updates.ps1
```

This may access upstream metadata for managed external dependencies but must not replace installed skills.

It does not compare or update the bundled `frontend-visual-qa` against Daymade. That upstream is comparison-only.

## Explicit external dependency update

```powershell
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Managed external dependencies are intentionally limited to:

- `addyosmani/agent-skills`;
- Impeccable, when already installed.

Motion, `ui-designer`, `qa-expert`, and the other optional integrations remain independently managed.

## Safety

Do not:

- update dependencies because an ordinary frontend task started;
- edit the local Codex plugin cache directly;
- fetch or replace `frontend-visual-qa` from Daymade during runtime maintenance;
- silently trust hooks;
- replace project-specific design/project-memory systems;
- treat inspiration as project design authority;
- treat the presence of `/motion` as permission to add the Motion runtime dependency;
- treat build success as browser proof;
- treat MCP registration as Chrome connectivity proof.
