param(
    [switch]$InstallImpeccable
)

$ErrorActionPreference = "Stop"

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

Require-Command "codex"
Require-Command "git"
Require-Command "npx"

Write-Host "Frontend Production QA - bootstrap"
Write-Host "=================================="
Write-Host ""

Write-Host "1. addyosmani/agent-skills"

$pluginList = (& codex plugin list 2>&1 | Out-String)
if ($pluginList -notmatch "agent-skills") {
    & codex plugin marketplace add addyosmani/agent-skills
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[INFO] marketplace add returned non-zero; continuing in case it is already registered."
    }

    & codex plugin add agent-skills@agent-skills
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to install agent-skills plugin."
    }
}
else {
    Write-Host "[OK] agent-skills already appears in codex plugin list"
}

Write-Host ""
Write-Host "2. bundled frontend-visual-qa"
Write-Host "[INFO] frontend-visual-qa is bundled with frontend-production-qa."
Write-Host "[INFO] Refresh the frontend-production-qa marketplace to update it."

Write-Host ""
Write-Host "3. Chrome DevTools MCP"

$mcp = (& codex mcp list 2>&1 | Out-String)
if ($mcp -notmatch "chrome-devtools") {
    & codex mcp add chrome-devtools -- npx chrome-devtools-mcp@latest
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to register Chrome DevTools MCP."
    }
    Write-Host "[OK] chrome-devtools MCP registered"
}
else {
    Write-Host "[OK] chrome-devtools MCP already registered"
}

Write-Host ""
Write-Host "4. Impeccable"

if ($InstallImpeccable) {
    & npx -y impeccable install --providers=codex --scope=global
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to install Impeccable."
    }
    Write-Host "[OK] Impeccable install command completed"
    Write-Host "[ACTION] Review hook trust with /hooks when applicable."
}
else {
    Write-Host "[SKIPPED] use -InstallImpeccable to install it"
}

Write-Host ""
Write-Host "5. Local readiness"
$check = Join-Path $PSScriptRoot "check-frontend-toolchain.ps1"
& $check

Write-Host ""
Write-Host "Start a fresh Codex session after bootstrap so the skill list is reloaded."
