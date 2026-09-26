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

### frontend-visual-qa

The plugin bundles the maintained Codex-adapted copy in:

```text
skills/frontend-visual-qa/
```

The original upstream source is retained only as a comparison reference:

https://github.com/daymade/claude-code-skills

Do not install, bootstrap, or update `frontend-visual-qa` as a floating runtime dependency from the upstream repository.

Changes to the bundled copy must be reviewed and committed to this repository so `frontend-production-qa` and `frontend-visual-qa` remain package-version-consistent.

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

### Chrome DevTools MCP

Current Codex registration:

```powershell
codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
```

Upstream:

https://github.com/ChromeDevTools/chrome-devtools-mcp

Registration alone proves configuration, not successful MCP process startup or Chrome connectivity. Those are runtime checks during actual frontend work.

## Recommended conditional specialists

### Motion AI Kit

Use the official `/motion` skill when animation, gestures, layout motion, springs, scroll-linked effects, or animation performance are material to the task.

Official source:

https://github.com/motiondivision/ai-kit

Official install/update entry point:

```powershell
npx motion-ai@latest
```

The Motion installer is intentionally external to this repository. It may configure the `/motion` skill and Motion's hosted MCP integration for the selected agent/scope.

Do not vendor or maintain another copy of the Motion skill here. Do not add the `motion` runtime package to an application merely because the specialist is installed. See `motion-specialist.md` for routing and verification rules.

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

### Related skills

The bundled `frontend-visual-qa` documentation may refer to these optional adjacent skills:

- `ui-designer` for extracting design systems from reference images;
- `qa-expert` for broader QA strategy and test-program setup.

They are not required to run the production frontend workflow. When installed, use a Codex-compatible copy or an explicitly maintained fork.

## Optional integrations

The orchestrator may use already installed:

- `taste-skill`
- `karpathy-guidelines`
- `context-engineering`
- `maintain-project-memory`

Their installation and upstream sources are intentionally unmanaged here.
