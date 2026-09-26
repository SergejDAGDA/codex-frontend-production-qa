$ErrorActionPreference = "Continue"

function Require-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if ($null -eq (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found."
    }
}

function Get-RemoteHead {
    param([Parameter(Mandatory = $true)][string]$Url)

    $line = (& git ls-remote $Url HEAD 2>$null | Select-Object -First 1)
    if (-not $line) { return $null }
    return ($line -split "\s+")[0]
}

Require-Command "git"

Write-Host "Frontend Production QA - external dependency update check"
Write-Host "========================================================"
Write-Host "This operation may access upstream repositories but does not replace installed skills."
Write-Host ""

$addy = Get-RemoteHead "https://github.com/addyosmani/agent-skills.git"

Write-Host "addyosmani/agent-skills"
Write-Host "  upstream HEAD: $addy"
Write-Host "  refresh command: codex plugin marketplace upgrade agent-skills"
Write-Host ""

Write-Host "bundled frontend-visual-qa"
Write-Host "  status: managed only by the frontend-production-qa plugin repository"
Write-Host "  upstream daymade/claude-code-skills is comparison-only and is not a runtime update source"
Write-Host ""

Write-Host "Motion AI Kit"
Write-Host "  status: recommended conditional specialist, independently maintained"
Write-Host "  install/update: npx motion-ai@latest"
Write-Host "  note: this script does not run the interactive Motion installer"
Write-Host ""

Write-Host "Impeccable"
Write-Host "  explicit check: npx impeccable check"
Write-Host "  note: npx may populate its package cache"
Write-Host ""

Write-Host "No installed dependency was replaced."
