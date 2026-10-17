param(
    [ValidateSet("all", "agent-skills", "frontend-production-qa")]
    [string]$Component = "all",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

# This script NEVER performs installs, updates, removals, or configuration writes.
# Native Codex Desktop owns the final installation approval and mutation.
$targets = @(
    [pscustomobject]@{
        Component = "agent-skills"
        PluginId = "agent-skills@agent-skills"
        Marketplace = "agent-skills"
        Source = "addyosmani/agent-skills"
        RequiredSkillIds = @("frontend-ui-engineering", "browser-testing-with-devtools")
    },
    [pscustomobject]@{
        Component = "frontend-production-qa"
        PluginId = "frontend-production-qa@codex-frontend-production-qa"
        Marketplace = "codex-frontend-production-qa"
        Source = "SergejDAGDA/codex-frontend-production-qa"
        RequiredSkillIds = @("frontend-visual-qa")
    }
)

function Invoke-CodexReadOnly {
    param([string[]]$Arguments)
    try {
        $output = (& codex @Arguments 2>&1 | Out-String)
        if ($LASTEXITCODE -ne 0 -or -not $output.Trim()) { return $null }
        return ($output | ConvertFrom-Json -ErrorAction Stop)
    }
    catch {
        return $null
    }
}

function Get-CollisionPaths {
    param([string[]]$SkillIds)
    $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
    $bases = @(
        (Join-Path $codexHome "skills"),
        (Join-Path $HOME ".agents\skills"),
        (Join-Path (Get-Location).Path ".codex\skills"),
        (Join-Path (Get-Location).Path ".agents\skills")
    )
    $hits = @()
    foreach ($id in $SkillIds) {
        foreach ($base in ($bases | Sort-Object -Unique)) {
            $candidate = Join-Path (Join-Path $base $id) "SKILL.md"
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                $hits += [pscustomobject]@{ Id = $id; Path = (Resolve-Path -LiteralPath $candidate).Path }
            }
        }
    }
    return @($hits)
}

$plugins = Invoke-CodexReadOnly -Arguments @("plugin", "list", "--available", "--json")
$marketplaces = Invoke-CodexReadOnly -Arguments @("plugin", "marketplace", "list", "--json")

$rows = @()
foreach ($target in $targets) {
    if ($Component -ne "all" -and $Component -ne $target.Component) { continue }
    $status = "UNKNOWN"
    $reason = ""
    $version = $null
    $marketplaceRoot = $null
    $collisions = @(Get-CollisionPaths -SkillIds $target.RequiredSkillIds)

    if ($null -eq $plugins -or $null -eq $marketplaces -or
        $null -eq $plugins.installed -or $null -eq $plugins.available -or
        $null -eq $marketplaces.marketplaces) {
        $reason = "Codex CLI inventory unavailable/incomplete; may differ from Codex Desktop runtime."
    }
    else {
        $installed = @($plugins.installed | Where-Object { $_.pluginId -eq $target.PluginId })
        $available = @($plugins.available | Where-Object { $_.pluginId -eq $target.PluginId })
        $market = @($marketplaces.marketplaces | Where-Object { $_.name -eq $target.Marketplace })

        if ($market.Count -gt 1 -or $installed.Count -gt 1 -or $available.Count -gt 1) {
            $status = "CONFLICT"
            $reason = "Multiple native records for a single expected plugin or marketplace."
        }
        elseif ($installed.Count -eq 1) {
            $version = $installed[0].version
            $status = if ($installed[0].enabled -eq $true) { "INSTALLED" } else { "DISABLED" }
            $reason = "Native Codex CLI registration only; active Desktop session not verified."
        }
        elseif ($market.Count -eq 0) {
            $status = "MARKETPLACE_MISSING"
            $reason = "Marketplace registration is absent; require separate source review and approval."
        }
        elseif ($available.Count -eq 1) {
            $status = "MISSING"
            $version = $available[0].version
            $reason = "Native CLI reports an available but uninstalled plugin."
        }
        else {
            $reason = "Plugin absent from native installed and available records; source cannot be established."
        }
        if ($market.Count -eq 1) { $marketplaceRoot = $market[0].root }

        # Never tell users to install an allegedly missing plugin over a
        # known direct skill with the same ID. This is a conservative gate;
        # it does not prove there are no other overlapping IDs in the bundle.
        if ($status -eq "MISSING" -and $collisions.Count -gt 0) {
            $status = "CONFLICT"
            $reason = "Required skill IDs already exist in direct user/project paths."
        }
    }

    $rows += [pscustomobject]@{
        Component = $target.Component
        PluginId = $target.PluginId
        Source = $target.Source
        Status = $status
        Version = $version
        MarketplaceRoot = $marketplaceRoot
        Reason = $reason
        DirectIdCollisions = @($collisions)
        InstallLink = if ($status -eq "MISSING") {
            "codex://plugins/install/$($target.PluginId.Split('@')[0])?marketplace=$($target.Marketplace)"
        } else { $null }
    }
}

if ($Json) {
    # Structured reporting is read-only; no opaque change/approval tokens.
    ConvertTo-Json -InputObject @($rows) -Depth 6
    exit 0
}

Write-Host "Frontend Production QA — guided dependency installation (READ ONLY)"
Write-Host "================================================================="
foreach ($row in $rows) {
    Write-Host ""
    Write-Host "$($row.Component): $($row.Status)"
    Write-Host "  plugin: $($row.PluginId)"
    Write-Host "  expected source: $($row.Source)"
    if ($row.Version) { Write-Host "  reported version: $($row.Version)" }
    if ($row.MarketplaceRoot) { Write-Host "  marketplace root: $($row.MarketplaceRoot)" }
    Write-Host "  evidence: $($row.Reason)"
    foreach ($collision in $row.DirectIdCollisions) {
        Write-Host "  [COLLISION] $($collision.Id): $($collision.Path)"
    }
    if ($row.InstallLink) {
        Write-Host "  NEXT: Review source, affected bundled skill IDs and permissions in Codex Desktop."
        Write-Host "  THEN: Open the native installation page; click Install only after approving."
        Write-Host "  $($row.InstallLink)"
    }
    elseif ($row.Status -eq "MARKETPLACE_MISSING") {
        Write-Host "  NEXT: Independently approve and register ONLY the expected marketplace source."
        Write-Host "  No marketplace has been added by this script."
    }
    else {
        Write-Host "  NEXT: No installation recommended from this evidence."
    }
}
Write-Host ""
Write-Host "Chrome DevTools MCP: separate required capability; this planner does not register MCP."
Write-Host "Impeccable and all recommended/optional integrations: not installed or updated."
Write-Host "No changes made. Installed/enablement/runtime state must be rechecked after native approval."
