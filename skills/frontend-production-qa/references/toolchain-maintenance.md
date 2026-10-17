# Toolchain Maintenance

Plugin self-updates and external specialist dependencies are separate operations. **Installing a plugin does not authorize installing every skill it mentions.** Required missing capabilities should be reported as one proposed plan, then installed only after explicit owner approval.

## Update frontend-production-qa itself

The canonical package is the Git-backed marketplace plugin `frontend-production-qa@codex-frontend-production-qa`. The published version is declared only in `plugin.json`; a new plugin release must bump this version. Updating the marketplace does **not** establish which cached package is enabled in the current Codex Desktop session.

When a targeted update is separately approved, the native commands are:

```powershell
codex plugin marketplace upgrade codex-frontend-production-qa
codex plugin add frontend-production-qa@codex-frontend-production-qa
```

Use these only after establishing the exact active source/installed version, duplicate IDs and an executable package-specific rollback plan. No script may upgrade unnamed/all marketplaces as a fallback. Start a new Codex Desktop session afterward and verify discovery.

## Read-only local readiness

```powershell
.\scripts\check-frontend-toolchain.ps1
```

The checker enumerates every accessible candidate for required skill IDs and identifies duplicates with identical or divergent hashes. Plugin cache candidates may be inactive or historical. An isolated CLI's `codex mcp list` output is not definitive evidence of the active Desktop MCP configuration or browser connection. Browser behavior is verified during the actual frontend task.

## Read-only upstream update evidence

```powershell
.\scripts\check-frontend-updates.ps1
```

This checks upstream Git HEAD and accessible cached package identities. A single matching Git-backed cache source may be labeled `CURRENT` **at cache level only**; multiple cache versions, unavailable Git provenance, failed network access or an unpinned runtime remain `UNKNOWN`. Different SHAs prove different revisions, not necessarily which one is newer. A cached package is not automatically an active package.

Bundled `frontend-visual-qa` is owned by the frontend plugin; **never** replace it directly with `daymade/claude-code-skills`.

## Selected update planner

```powershell
.\scripts\update-frontend-toolchain.ps1 -Component agent-skills
.\scripts\update-frontend-toolchain.ps1 -Component frontend-production-qa
.\scripts\update-frontend-toolchain.ps1 -Component impeccable
```

All three commands are read-only. The former broad `-Apply` operation is **blocked** pending proven rollback and active-owner selection. `-Apply` deliberately fails closed rather than updating multiple marketplaces or claiming that copying a cache tree can restore plugin activation.

A future update executor may be enabled only after isolated tests prove component-level selection, rollback of package **and** activation/configuration, duplicate/refusal behavior, hooks trust and post-update validation. Native component commands are not automatically rollback-safe.

## First-time external toolchain bootstrap

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1
```

**This existing bootstrap script mutates the environment.** Do not run it as a presence check or merely because the plugin was installed. The agent must first inventory required capabilities and duplicates, show one grouped plan (including MCP changes and the optional Impeccable choice), and obtain explicit approval for its entire effects. If the CLI and active Desktop configuration disagree, pause and reconcile instead of blindly installing again.

## Safety

- Do not update dependencies during ordinary frontend tasks.
- Do not silently trust hooks or initialize Impeccable.
- Do not treat a stale `frontend-visual-qa` legacy copy as the bundled owner.
- Do not assume `npx ...@latest` proves the runtime version.
- Do not replace application design/project memory authority.
- `retrospective-skill-audit` reviews retrospective performance; it does not install or update dependencies.
