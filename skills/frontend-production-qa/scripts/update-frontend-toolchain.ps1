param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

if (-not $Apply) {
    Write-Host "No changes made."
    Write-Host "Run check-frontend-updates.ps1 first."
    Write-Host "Use -Apply for explicit maintenance."
    exit 0
}

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if ($null -eq (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

function Test-SkillName {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ExpectedName
    )

    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $content = Get-Content -LiteralPath $Path -Raw
    if ($content.Length -lt 16 -or -not $content.StartsWith("---")) { return $false }

    $match = [regex]::Match(
        $content,
        "(?ms)\A---\s*.*?^\s*name\s*:\s*['`"]?(?<name>[^'`"\r\n#]+)"
    )

    return $match.Success -and $match.Groups["name"].Value.Trim() -eq $ExpectedName
}

function Get-TreeManifest {
    param([Parameter(Mandatory = $true)][string]$Root)

    $items = @{}
    if (-not (Test-Path -LiteralPath $Root)) { return $items }

    $resolved = (Resolve-Path -LiteralPath $Root).Path

    Get-ChildItem -LiteralPath $Root -File -Recurse |
        Where-Object { $_.Name -ne ".frontend-production-qa-source.json" } |
        ForEach-Object {
            $relative = $_.FullName.Substring($resolved.Length).TrimStart([char[]]@('\','/'))
            $items[$relative] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }

    return $items
}

function Show-TreeDiff {
    param(
        [Parameter(Mandatory = $true)][string]$Installed,
        [Parameter(Mandatory = $true)][string]$Proposed
    )

    $old = Get-TreeManifest $Installed
    $new = Get-TreeManifest $Proposed
    $keys = @($old.Keys + $new.Keys | Sort-Object -Unique)

    foreach ($key in $keys) {
        if (-not $old.ContainsKey($key)) {
            Write-Host "ADDED    $key"
        }
        elseif (-not $new.ContainsKey($key)) {
            Write-Host "REMOVED  $key"
        }
        elseif ($old[$key] -ne $new[$key]) {
            Write-Host "CHANGED  $key"
        }
    }
}

Require-Command "codex"
Require-Command "git"
Require-Command "npx"

Write-Host "Frontend Production QA - explicit update"
Write-Host "========================================"
Write-Host ""

Write-Host "1. addyosmani/agent-skills marketplace"
& codex plugin marketplace upgrade agent-skills
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARN] marketplace-specific upgrade failed; trying all configured Git marketplaces"
    & codex plugin marketplace upgrade
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARN] marketplace upgrade did not complete successfully"
    }
}
else {
    Write-Host "[OK] agent-skills marketplace refreshed"
}

Write-Host ""
Write-Host "2. frontend-production-qa plugin"
& codex plugin marketplace upgrade codex-frontend-production-qa
if ($LASTEXITCODE -ne 0) {
    throw "Unable to refresh the frontend-production-qa marketplace."
}
Write-Host "[OK] frontend-production-qa refreshed; bundled frontend-visual-qa updated with the plugin"

Write-Host ""
Write-Host "3. Impeccable"

$globalImpeccable = Join-Path $HOME ".agents\skills\impeccable\SKILL.md"
if (Test-Path -LiteralPath $globalImpeccable) {
    & npx -y impeccable update
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARN] Impeccable update returned non-zero"
    }
    else {
        Write-Host "[OK] Impeccable update completed"
        Write-Host "[ACTION] Review /hooks if hook definitions changed."
    }
}
else {
    Write-Host "[OPTIONAL MISSING] Impeccable not updated"
}

Write-Host ""
Write-Host "4. Readiness"
& (Join-Path $PSScriptRoot "check-frontend-toolchain.ps1")

Write-Host ""
Write-Host "Start a fresh Codex session after plugin or skill changes."
