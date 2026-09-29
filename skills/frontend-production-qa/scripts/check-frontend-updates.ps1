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

Write-Host "Frontend Production QA - update check"
Write-Host "===================================="
Write-Host "This operation may access upstream repositories but does not replace managed skills."
Write-Host ""

$addy = Get-RemoteHead "https://github.com/addyosmani/agent-skills.git"
Write-Host "addyosmani/agent-skills"
Write-Host "  upstream HEAD: $addy"
Write-Host "  refresh command: codex plugin marketplace upgrade agent-skills"
Write-Host ""

Write-Host "frontend-production-qa"
Write-Host "  frontend-visual-qa: bundled in this plugin"
Write-Host "  refresh command:    codex plugin marketplace upgrade codex-frontend-production-qa"
Write-Host "  source of truth:    https://github.com/SergejDAGDA/codex-frontend-production-qa"

Write-Host ""
Write-Host "Impeccable"
Write-Host "  explicit check: npx impeccable check"
Write-Host "  note: npx may populate its package cache"
Write-Host ""
Write-Host "No installed managed dependency was replaced."
