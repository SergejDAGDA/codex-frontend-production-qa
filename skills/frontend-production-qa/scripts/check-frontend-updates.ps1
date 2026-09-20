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
$daymade = Get-RemoteHead "https://github.com/daymade/claude-code-skills.git"

Write-Host "addyosmani/agent-skills"
Write-Host "  upstream HEAD: $addy"
Write-Host "  refresh command: codex plugin marketplace upgrade agent-skills"
Write-Host ""

$visualDir = Join-Path $HOME ".agents\skills\frontend-visual-qa"
$metadata = Join-Path $visualDir ".frontend-production-qa-source.json"
$installed = $null

if (Test-Path -LiteralPath $metadata) {
    try {
        $installed = (Get-Content -LiteralPath $metadata -Raw | ConvertFrom-Json).upstream_commit
    }
    catch {
        Write-Host "[WARN] installed frontend-visual-qa metadata could not be parsed"
    }
}

Write-Host "daymade/claude-code-skills"
Write-Host "  installed recorded commit: $installed"
Write-Host "  upstream HEAD:             $daymade"

if ($installed -and $daymade) {
    if ($installed -eq $daymade) {
        Write-Host "  status: CURRENT"
    }
    else {
        Write-Host "  status: UPDATE AVAILABLE"
    }
}
else {
    Write-Host "  status: UNKNOWN"
}

Write-Host ""
Write-Host "Impeccable"
Write-Host "  explicit check: npx impeccable check"
Write-Host "  note: npx may populate its package cache"
Write-Host ""
Write-Host "No installed managed dependency was replaced."
