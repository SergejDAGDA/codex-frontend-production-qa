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

Every published plugin change must bump that version.

Do not keep a second manually copied `frontend-production-qa` under `~/.agents/skills` when using plugin distribution.

## Local readiness of external dependencies

```powershell
.\scripts\check-frontend-toolchain.ps1
```

This checks local command availability, required specialist skill files and Chrome DevTools MCP registration.

It does not intentionally perform upstream network update checks.

It also does not claim that an already-running Codex session loaded a skill installed after that session started.

The bundled Inspo MCP is owned by the plugin package and is not managed by these scripts.

## First-time external toolchain bootstrap

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1
```

Optional Impeccable install:

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1 -InstallImpeccable
```

After bootstrap, start a fresh Codex session.

## Network update check for external dependencies

```powershell
.\scripts\check-frontend-updates.ps1
```

This may access upstream repositories and package metadata but must not replace installed managed skills.

## Explicit external dependency update

```powershell
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Managed external dependencies only:

- addyosmani/agent-skills;
- frontend-visual-qa;
- Impeccable if already installed.

The frontend-visual-qa copy is backed up before replacement.

Optional integrations remain unmanaged.

## Safety

Do not:

- update dependencies because an ordinary frontend task started;
- silently trust hooks;
- replace project-specific design/project-memory systems;
- treat inspiration as project design authority;
- treat build success as browser proof;
- treat MCP registration as Chrome connectivity proof.
