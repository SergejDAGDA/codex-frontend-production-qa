$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$base = Join-Path $root "skills\frontend-production-qa\scripts"
$updater = Join-Path $base "update-frontend-toolchain.ps1"
$readiness = Join-Path $base "check-frontend-toolchain.ps1"

foreach ($component in @("agent-skills", "frontend-production-qa", "impeccable")) {
    $plan = (& $updater -Component $component 2>&1 | Out-String)
    if ($plan -notmatch "\[PLAN ONLY\]") { throw "Missing plan for $component" }
    $blocked = $false
    try {
        & $updater -Component $component -Apply | Out-Null
    }
    catch {
        if ($_.Exception.Message -notmatch "\[BLOCKED\]") {
            throw "Unexpected apply failure for $component : $($_.Exception.Message)"
        }
        $blocked = $true
    }
    if (-not $blocked) { throw "Unapproved update was not blocked: $component" }
}
try {
    & $updater -Apply | Out-Null
    throw "Updater accepted an unselected component"
}
catch {
    if ($_.Exception.Message -notmatch "Specify exactly one") { throw }
}

$source = Get-Content -LiteralPath $updater -Raw
if ($source -match '(?m)^\s*&\s*codex\s+plugin\s+marketplace\s+upgrade(?:\s|$)') {
    throw "Updater must not perform marketplace mutations"
}
if ($source -match '(?m)^\s*&\s*npx(?:\s|$)') {
    throw "Updater must not update other packages implicitly"
}

$fixture = Join-Path ([IO.Path]::GetTempPath()) ("frontend-toolchain-fixture-" + [guid]::NewGuid().ToString("N"))
$originalHome = $env:CODEX_HOME
try {
    $env:CODEX_HOME = Join-Path $fixture "codex"
    $direct = Join-Path $env:CODEX_HOME "skills\frontend-visual-qa\SKILL.md"
    $plugin = Join-Path $env:CODEX_HOME "plugins\cache\codex-frontend-production-qa\frontend-production-qa\1.2.1\skills\frontend-visual-qa\SKILL.md"
    New-Item -ItemType Directory -Force -Path (Split-Path $direct), (Split-Path $plugin) | Out-Null
    $header = "---" + [Environment]::NewLine + "name: frontend-visual-qa" + [Environment]::NewLine + "---"
    Set-Content -LiteralPath $direct -Value ($header + [Environment]::NewLine + "legacy")
    Set-Content -LiteralPath $plugin -Value ($header + [Environment]::NewLine + "bundled")
    $output = (& $readiness 2>&1 | Out-String)
    if ($output -notmatch "\[AMBIGUOUS\] frontend-visual-qa") {
        throw "Divergent duplicate-ID payloads were not reported"
    }
    Set-Content -LiteralPath $direct -Value ($header + [Environment]::NewLine + "bundled")
    $output = (& $readiness 2>&1 | Out-String)
    if ($output -notmatch "\[DUPLICATE\] frontend-visual-qa") {
        throw "Identical duplicate-ID payloads were not reported"
    }
}
finally {
    $env:CODEX_HOME = $originalHome
    if (Test-Path -LiteralPath $fixture) { Remove-Item -LiteralPath $fixture -Recurse -Force }
}
Write-Host "Scoped dependency safety fixtures PASS."
