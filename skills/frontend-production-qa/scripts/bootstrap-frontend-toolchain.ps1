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

$skillsRoot = Join-Path $HOME ".agents\skills"
New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null

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
Write-Host "2. frontend-visual-qa"

$target = Join-Path $skillsRoot "frontend-visual-qa"
$targetSkill = Join-Path $target "SKILL.md"

if (-not (Test-SkillName -Path $targetSkill -ExpectedName "frontend-visual-qa")) {
    $temp = Join-Path ([IO.Path]::GetTempPath()) ("fpqa-bootstrap-" + [guid]::NewGuid().ToString("N"))
    $repo = Join-Path $temp "daymade"

    try {
        New-Item -ItemType Directory -Force -Path $temp | Out-Null
        & git clone --depth 1 https://github.com/daymade/claude-code-skills.git $repo
        if ($LASTEXITCODE -ne 0) { throw "Unable to clone daymade/claude-code-skills." }

        $source = Join-Path $repo "frontend-visual-qa"
        $sourceSkill = Join-Path $source "SKILL.md"

        if (-not (Test-SkillName -Path $sourceSkill -ExpectedName "frontend-visual-qa")) {
            throw "Upstream frontend-visual-qa payload failed validation."
        }

        if (Test-Path -LiteralPath $target) {
            $backup = Join-Path $skillsRoot ("frontend-visual-qa.bootstrap-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
            Move-Item -LiteralPath $target -Destination $backup
            Write-Host "[BACKUP] $backup"
        }

        Copy-Item -Recurse -Force -LiteralPath $source -Destination $target

        $commit = (& git -C $repo rev-parse HEAD).Trim()
        @{
            source = "https://github.com/daymade/claude-code-skills"
            source_path = "frontend-visual-qa"
            upstream_commit = $commit
            installed_at_utc = (Get-Date).ToUniversalTime().ToString("o")
        } |
            ConvertTo-Json -Depth 4 |
            Set-Content -LiteralPath (Join-Path $target ".frontend-production-qa-source.json") -Encoding UTF8

        Write-Host "[OK] frontend-visual-qa installed"
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -Recurse -Force -LiteralPath $temp -ErrorAction SilentlyContinue
        }
    }
}
else {
    Write-Host "[OK] frontend-visual-qa already valid"
}

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
