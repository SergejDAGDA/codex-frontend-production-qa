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

function Test-SkillPayload {
    param([Parameter(Mandatory = $true)][string]$Name)

    $candidates = @(Get-SkillCandidates -Name $Name)

    foreach ($path in $candidates) {
        try {
            $content = Get-Content -LiteralPath $path -Raw -ErrorAction Stop
            if ($content.Length -lt 16) { continue }
            if (-not $content.StartsWith("---")) { continue }

            $match = [regex]::Match(
                $content,
                "(?ms)\A---\s*.*?^\s*name\s*:\s*['`"]?(?<name>[^'`"\r\n#]+)"
            )

            if (-not $match.Success) { continue }

            $declared = $match.Groups["name"].Value.Trim()
            if ($declared -ne $Name) { continue }

            $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
            Write-Host "[VALID] $Name"
            Write-Host "        path: $path"
            Write-Host "        sha256: $hash"
            return $true
        }
        catch {
            Write-Host "[WARN] Could not validate $path"
        }
    }

    Write-Host "[MISSING] no valid $Name payload found"
    return $false
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
Write-Host "Required specialist skills"
Write-Host "--------------------------"

foreach ($skill in @(
    "frontend-ui-engineering",
    "browser-testing-with-devtools",
    "frontend-visual-qa"
)) {
    if (-not (Test-SkillPayload -Name $skill)) {
        $runtimeReady = $false
    }
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
Write-Host "CURRENT CODEX SESSION LOAD: NOT VERIFIED BY THIS SCRIPT"
Write-Host "BROWSER PROCESS/CONNECTION: VERIFY DURING THE FRONTEND TASK"
Write-Host ("TOOLCHAIN MAINTENANCE: " + $(if ($maintenanceReady) { "READY" } else { "NOT READY" }))

if (-not $runtimeReady) {
    exit 1
}
