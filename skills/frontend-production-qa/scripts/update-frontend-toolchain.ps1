param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

if (-not $Apply) {
    Write-Host "No changes made."
    Write-Host "Run check-frontend-updates.ps1 first."
    Write-Host "Use -Apply for explicit external-toolchain maintenance."
    exit 0
}

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if ($null -eq (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

Require-Command "codex"
Require-Command "npx"

Write-Host "Frontend Production QA - explicit external dependency update"
Write-Host "========================================================"
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
Write-Host "2. bundled frontend-visual-qa"
Write-Host "[UNCHANGED] managed by the frontend-production-qa plugin repository."
Write-Host "Do not replace it from daymade/claude-code-skills during runtime maintenance."

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
Write-Host "4. Motion AI Kit"
Write-Host "[UNCHANGED] independently maintained recommended specialist."
Write-Host "To install or update it explicitly, run:"
Write-Host "  npx motion-ai@latest"

Write-Host ""
Write-Host "5. Readiness"
& (Join-Path $PSScriptRoot "check-frontend-toolchain.ps1")

Write-Host ""
Write-Host "Start a fresh Codex session after plugin or skill changes."
