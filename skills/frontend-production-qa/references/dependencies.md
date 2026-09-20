# Dependencies

## Required

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

### frontend-visual-qa

Expected upstream:

https://github.com/daymade/claude-code-skills

Expected source directory:

```text
frontend-visual-qa/
```

Expected user install directory:

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
