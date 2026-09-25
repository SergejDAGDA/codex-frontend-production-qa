# Dependencies

## Plugin-bundled

### Inspo MCP

The plugin bundles Inspo as a remote read-only design-reference MCP server.

```text
https://inspomcp.dev/api/mcp
```

Upstream:

https://github.com/Nutlope/inspo

No separate user-level MCP registration is required when `frontend-production-qa` is installed as a plugin.

Use Inspo for new UI, new components, redesigns, visual-direction exploration, or explicit requests for reference material.

Do not use inspiration results as authority over an existing project's approved visual language.

## Required external specialist stack

### addyosmani/agent-skills

Required skills:

- `frontend-ui-engineering`
- `browser-testing-with-devtools`

Current Codex plugin installation:

```powershell
codex plugin marketplace add addyosmani/agent-skills
codex plugin add agent-skills@agent-skills
```

Upstream:

https://github.com/addyosmani/agent-skills

### Bundled frontend-visual-qa

The plugin bundles the maintained Codex-adapted copy in:

```text
skills/frontend-visual-qa/
```

The original upstream source is retained only as a comparison reference:

https://github.com/daymade/claude-code-skills

Do not silently replace the bundled copy with the upstream Claude-oriented version. Changes should be reviewed and committed to this repository so the orchestrator and visual QA rules remain version-consistent.

Legacy user install directory:

```text
~/.agents/skills/frontend-visual-qa/
```

### Chrome DevTools MCP

Current Codex registration:

```powershell
codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
```

Upstream:

https://github.com/ChromeDevTools/chrome-devtools-mcp

Registration alone proves configuration, not successful MCP process startup or Chrome connectivity. Those are runtime checks during actual frontend work.

## Recommended

### Related skills

The bundled `frontend-visual-qa` documentation may refer to these optional adjacent skills:

- `ui-designer` for extracting design systems from reference images;
- `qa-expert` for broader QA strategy and test-program setup.

They are not required to run the production frontend workflow. When installed, use the Codex-compatible copies from `daymade/claude-code-skills` or an explicitly maintained fork.

### Impeccable

Install globally for Codex:

```powershell
npx impeccable install --providers=codex --scope=global
```

Check/update:

```powershell
npx impeccable check
npx impeccable update
```

After install/update, Codex users may need to review/approve the project hook with `/hooks`.

Do not automatically initialize Impeccable in mature projects with an established design/project-memory system.

## Optional integrations

The orchestrator may use already installed:

- `taste-skill`
- `karpathy-guidelines`
- `context-engineering`
- `maintain-project-memory`

Their installation and upstream sources are intentionally unmanaged here.
