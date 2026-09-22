# Changelog

## 1.1.1 - 2026-09-22

Packaging correction release.

- Added the portable root `plugin.json` manifest.
- Moved the bundled Inspo configuration to root `mcp.json`.
- Removed legacy manifest files that duplicated the plugin version and MCP configuration.
- Made the portable root manifest the only release-version source.

## 1.1.0 - 2026-09-22

Git-backed Codex plugin distribution.

- Packaged the repository as a native Codex plugin.
- Added a Git-backed marketplace for direct installation and updates from GitHub.
- Bundled the hosted Inspo MCP endpoint for selective production-site design references.
- Made the plugin manifest the only release-version source.
- Removed duplicate release-version declarations from the skill and dependency manifest.
- Documented migration away from manual copies under `~/.agents/skills`.
- Kept project design and existing UI as authoritative over inspiration sources.
- Kept specialist toolchain maintenance separate from plugin self-updates.

## 1.0.0 - 2026-09-20

Initial public version.

- Added frontend workflow orchestration.
- Added Class A/B/C/D verification model.
- Added full and reduced responsive matrices.
- Added breakpoint boundary checks.
- Added regression-closure rule after CSS/layout changes.
- Added shared-component cross-page verification.
- Added real-browser and screenshot-inspection requirements.
- Added required specialist-stack documentation.
- Added project AGENTS routing fragment.
- Added explicit bootstrap/check/update maintenance scripts.
- Added English and Russian documentation.
