# Toolchain Maintenance

Normal frontend work and toolchain maintenance are separate operations.

## Local readiness

```powershell
.\scripts\check-frontend-toolchain.ps1
```

This checks local command availability, required skill files and Chrome DevTools MCP registration.

It does not intentionally perform upstream network update checks.

It also does not claim that an already-running Codex session loaded a skill installed after that session started.

## First-time bootstrap

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1
```

Optional Impeccable install:

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1 -InstallImpeccable
```

After bootstrap, start a fresh Codex session.

## Network update check

```powershell
.\scripts\check-frontend-updates.ps1
```

This may access upstream repositories and package metadata but must not replace installed managed skills.

## Explicit update

```powershell
.\scripts\update-frontend-toolchain.ps1 -Apply
```

Managed dependencies only:

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
- treat build success as browser proof;
- treat MCP registration as Chrome connectivity proof.
