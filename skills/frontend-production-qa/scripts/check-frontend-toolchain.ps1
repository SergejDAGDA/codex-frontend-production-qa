$ErrorActionPreference = "Continue"

function Test-CommandAvailable {
    param([Parameter(Mandatory = $true)][string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-SkillCandidates {
    param([Parameter(Mandatory = $true)][string]$Name)

    $paths = New-Object System.Collections.Generic.List[string]
    $projectRoot = (Get-Location).Path

    $direct = @(
        (Join-Path $projectRoot ".agents\skills\$Name\SKILL.md"),
        (Join-Path $HOME ".agents\skills\$Name\SKILL.md")
    )

    foreach ($path in $direct) {
        if (Test-Path -LiteralPath $path) {
            $paths.Add((Resolve-Path -LiteralPath $path).Path)
        }
    }

    $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
    $cacheRoot = Join-Path $codexHome "plugins\cache"

    if (Test-Path -LiteralPath $cacheRoot) {
        Get-ChildItem -LiteralPath $cacheRoot -Filter "SKILL.md" -File -Recurse -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Directory.Name -eq $Name -and
                $_.Directory.Parent -and
                $_.Directory.Parent.Name -eq "skills"
            } |
            ForEach-Object {
                if (-not $paths.Contains($_.FullName)) {
                    $paths.Add($_.FullName)
                }
            }
    }

    return @($paths)
}

function Test-SkillFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ExpectedName
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    try {
        $content = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
        if ($content.Length -lt 16) { return $null }
        if (-not $content.StartsWith("---")) { return $null }

        $match = [regex]::Match(
            $content,
            "(?ms)\A---\s*.*?^\s*name\s*:\s*['`"]?(?<name>[^'`"\r\n#]+)"
        )

        if (-not $match.Success) { return $null }
        if ($match.Groups["name"].Value.Trim() -ne $ExpectedName) { return $null }

        return [PSCustomObject]@{
            Path = $Path
            Sha256 = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
        }
    }
    catch {
        return $null
    }
}

function Find-ValidatedSkill {
    param([Parameter(Mandatory = $true)][string]$Name)

    foreach ($path in @(Get-SkillCandidates -Name $Name)) {
        $result = Test-SkillFile -Path $path -ExpectedName $Name
        if ($result) {
            Write-Host "[VALID] $Name"
            Write-Host "        path: $($result.Path)"
            Write-Host "        sha256: $($result.Sha256)"
            return $result
        }
    }

    return $null
}

Write-Host "Frontend Production QA - local readiness"
Write-Host "========================================"
Write-Host ""

$runtimeReady = $true
$maintenanceReady = $true

foreach ($command in @("codex", "npx")) {
    if (Test-CommandAvailable $command) {
        Write-Host "[OK] $command"
    }
    else {
        Write-Host "[MISSING] $command"
        $runtimeReady = $false
        $maintenanceReady = $false
    }
}

if (Test-CommandAvailable "git") {
    Write-Host "[OK] git"
}
else {
    Write-Host "[MISSING] git"
    $maintenanceReady = $false
}

Write-Host ""
Write-Host "Required external specialist skills"
Write-Host "-----------------------------------"

foreach ($skill in @(
    "frontend-ui-engineering",
    "browser-testing-with-devtools"
)) {
    if (-not (Find-ValidatedSkill -Name $skill)) {
        Write-Host "[MISSING] no valid $skill payload found"
        $runtimeReady = $false
    }
}

Write-Host ""
Write-Host "Bundled specialist skill"
Write-Host "------------------------"

$orchestratorRoot = Split-Path $PSScriptRoot -Parent
$pluginSkillsRoot = Split-Path $orchestratorRoot -Parent
$bundledVisualQaPath = Join-Path $pluginSkillsRoot "frontend-visual-qa\SKILL.md"
$bundledVisualQa = Test-SkillFile -Path $bundledVisualQaPath -ExpectedName "frontend-visual-qa"

if ($bundledVisualQa) {
    Write-Host "[VALID] bundled frontend-visual-qa"
    Write-Host "        path: $($bundledVisualQa.Path)"
    Write-Host "        sha256: $($bundledVisualQa.Sha256)"
}
else {
    Write-Host "[MISSING] bundled frontend-visual-qa is missing or invalid"
    Write-Host "          Reinstall/update frontend-production-qa; do not substitute a floating Daymade copy."
    $runtimeReady = $false
}

Write-Host ""
Write-Host "Recommended conditional specialists"
Write-Host "-----------------------------------"

$motion = Find-ValidatedSkill -Name "motion"
if (-not $motion) {
    Write-Host "[OPTIONAL MISSING] motion"
    Write-Host "                   Install/update with: npx motion-ai@latest"
    Write-Host "                   Core readiness is unaffected."
}

Write-Host ""
Write-Host "Chrome DevTools MCP"
Write-Host "-------------------"

$mcpRegistered = $false
if (Test-CommandAvailable "codex") {
    try {
        $mcp = (& codex mcp list 2>&1 | Out-String)
        if ($mcp -match "chrome-devtools") {
            $mcpRegistered = $true
            Write-Host "[REGISTERED] chrome-devtools"
            Write-Host "             Registration does not prove MCP startup or Chrome connectivity."
        }
        else {
            Write-Host "[MISSING] chrome-devtools MCP registration"
            $runtimeReady = $false
        }
    }
    catch {
        Write-Host "[ERROR] unable to inspect MCP registrations"
        $runtimeReady = $false
    }
}

Write-Host ""
Write-Host "Readiness summary"
Write-Host "-----------------"
Write-Host ("FRONTEND TOOLCHAIN FILES: " + $(if ($runtimeReady) { "READY" } else { "NOT READY" }))
Write-Host ("BROWSER MCP CONFIG: " + $(if ($mcpRegistered) { "REGISTERED" } else { "NOT READY" }))
Write-Host "MOTION SPECIALIST: OPTIONAL / CONDITIONAL"
Write-Host "CURRENT CODEX SESSION LOAD: NOT VERIFIED BY THIS SCRIPT"
Write-Host "BROWSER PROCESS/CONNECTION: VERIFY DURING THE FRONTEND TASK"
Write-Host ("TOOLCHAIN MAINTENANCE: " + $(if ($maintenanceReady) { "READY" } else { "NOT READY" }))

if (-not $runtimeReady) {
    exit 1
}
