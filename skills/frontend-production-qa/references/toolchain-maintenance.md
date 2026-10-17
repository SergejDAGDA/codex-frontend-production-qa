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

## Guided first-time installation of required plugin packages

```powershell
.\scripts\plan-frontend-dependencies.ps1
.\scripts\plan-frontend-dependencies.ps1 -Component agent-skills -Json
.\scripts\bootstrap-frontend-toolchain.ps1
```

These commands are **read-only** and depend on structured native
`codex plugin list --available --json` and `codex plugin marketplace list --json`
evidence. They distinguish INSTALLED, DISABLED, MISSING, CONFLICT,
MARKETPLACE_MISSING and UNKNOWN. Installed/enabled in an isolated CLI is
not proof of current-session Desktop availability.

When `MISSING` is supported by native inventory and known direct skill ID
collisions are absent, the planner prints a `codex://plugins/install/...`
link. The user must inspect the package owner, all bundled skill IDs,
permissions and the native install preview, then explicitly approve the
installation **in Codex Desktop**. No PowerShell script performs the
installation, updates a marketplace, or tries to roll back partial native
installation.

If the marketplace is missing, verify the canonical source and obtain
separate permission before manually registering it. Re-run the planner
after registration. UNKNOWN, DISABLED or CONFLICT are not installation
approval. The planner checks known required IDs; it does not guarantee
that a provider bundle contains no other conflicting IDs.

After a native installation, verify exact package identity, enabled state,
materialized files and reloaded Desktop session. Handle a failed/partial
native installation as an explicit recovery task, not an automatic retry.

**Lab evidence (Codex CLI 0.163.0-alpha.10.2, 2026-10-17):**
native named marketplace refresh can immediately materialize an installed
plugin, prune its old cached version, and has no transactional rollback.
A post-materialization synthetic rollback worked, but the refresh-only
failure boundary could not be exercised. Therefore automatic updates
remain blocked. Do not claim a tested restore for production installations.

## First-time external toolchain bootstrap

```powershell
.\scripts\bootstrap-frontend-toolchain.ps1
```

The bootstrap command is now **read-only** and delegates to the guided planner. Its former bulk mutation and optional `-InstallImpeccable` path are blocked. Chrome DevTools MCP and Impeccable remain separate, permission-gated decisions. If isolated CLI and active Desktop configurations disagree, reconcile them before any native installation.

## Safety

- Do not update dependencies during ordinary frontend tasks.
- Do not silently trust hooks or initialize Impeccable.
- Do not treat a stale `frontend-visual-qa` legacy copy as the bundled owner.
- Do not assume `npx ...@latest` proves the runtime version.
- Do not replace application design/project memory authority.
- `retrospective-skill-audit` reviews retrospective performance; it does not install or update dependencies.
