param(
    [switch]$Apply,
    [switch]$ConfirmFrontendVisualQaReplace
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
Write-Host "2. frontend-visual-qa"

$skillsRoot = Join-Path $HOME ".agents\skills"
$target = Join-Path $skillsRoot "frontend-visual-qa"
$temp = Join-Path ([IO.Path]::GetTempPath()) ("fpqa-update-" + [guid]::NewGuid().ToString("N"))
$repo = Join-Path $temp "daymade"
$proposed = Join-Path $repo "frontend-visual-qa"

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    & git clone --depth 1 https://github.com/daymade/claude-code-skills.git $repo
    if ($LASTEXITCODE -ne 0) { throw "Unable to clone daymade/claude-code-skills." }

    $proposedSkill = Join-Path $proposed "SKILL.md"
    if (-not (Test-SkillName -Path $proposedSkill -ExpectedName "frontend-visual-qa")) {
        throw "Proposed frontend-visual-qa failed validation."
    }

    $proposedCommit = (& git -C $repo rev-parse HEAD).Trim()
    $metadataPath = Join-Path $target ".frontend-production-qa-source.json"
    $installedCommit = $null

    if (Test-Path -LiteralPath $metadataPath) {
        try {
            $installedCommit = (Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json).upstream_commit
        }
        catch {}
    }

    Write-Host "Installed recorded commit: $installedCommit"
    Write-Host "Proposed upstream commit:  $proposedCommit"
    Write-Host ""

    if (Test-Path -LiteralPath $target) {
        Show-TreeDiff -Installed $target -Proposed $proposed
    }
    else {
        Write-Host "[INFO] no installed frontend-visual-qa copy; proposed tree is entirely new"
    }

    if (-not $ConfirmFrontendVisualQaReplace) {
        Write-Host ""
        Write-Host "[SKIPPED] frontend-visual-qa replacement requires a second explicit authorization."
        Write-Host "Re-run with:"
        Write-Host "  .\scripts\update-frontend-toolchain.ps1 -Apply -ConfirmFrontendVisualQaReplace"
    }
    else {
        $backup = $null
        $hadInstalled = Test-Path -LiteralPath $target

        if ($hadInstalled) {
            $backup = Join-Path $skillsRoot ("frontend-visual-qa.backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
            Copy-Item -Recurse -Force -LiteralPath $target -Destination $backup
            Write-Host "[BACKUP] $backup"
        }

        try {
            if (Test-Path -LiteralPath $target) {
                Remove-Item -Recurse -Force -LiteralPath $target
            }

            Copy-Item -Recurse -Force -LiteralPath $proposed -Destination $target

            $installedSkill = Join-Path $target "SKILL.md"
            if (-not (Test-SkillName -Path $installedSkill -ExpectedName "frontend-visual-qa")) {
                throw "Post-install frontend-visual-qa validation failed."
            }

            @{
                source = "https://github.com/daymade/claude-code-skills"
                source_path = "frontend-visual-qa"
                upstream_commit = $proposedCommit
                installed_at_utc = (Get-Date).ToUniversalTime().ToString("o")
            } |
                ConvertTo-Json -Depth 4 |
                Set-Content -LiteralPath $metadataPath -Encoding UTF8

            Write-Host "[COMMIT] frontend-visual-qa replacement validated"
        }
        catch {
            Write-Host "[FAIL] replacement failed: $($_.Exception.Message)"
            Write-Host "[ROLLBACK] restoring previous state"

            if (Test-Path -LiteralPath $target) {
                Remove-Item -Recurse -Force -LiteralPath $target -ErrorAction SilentlyContinue
            }

            if ($hadInstalled -and $backup -and (Test-Path -LiteralPath $backup)) {
                Copy-Item -Recurse -Force -LiteralPath $backup -Destination $target

                if (-not (Test-SkillName -Path (Join-Path $target "SKILL.md") -ExpectedName "frontend-visual-qa")) {
                    throw "Rollback restored files but validation failed. Inspect backup manually: $backup"
                }

                Write-Host "[ROLLBACK OK] previous frontend-visual-qa restored"
            }
            elseif (-not $hadInstalled) {
                Write-Host "[ROLLBACK OK] no previous copy existed; failed new copy removed"
            }

            throw
        }
    }
}
finally {
    if (Test-Path -LiteralPath $temp) {
        Remove-Item -Recurse -Force -LiteralPath $temp -ErrorAction SilentlyContinue
    }
}

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
