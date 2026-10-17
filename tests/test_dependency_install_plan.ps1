$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$planner = Join-Path $root "skills\frontend-production-qa\scripts\plan-frontend-dependencies.ps1"
$bootstrap = Join-Path $root "skills\frontend-production-qa\scripts\bootstrap-frontend-toolchain.ps1"
$pwsh = (Get-Command pwsh -ErrorAction Stop).Source
$fixture = Join-Path ([IO.Path]::GetTempPath()) ("frontend-install-fixture-" + [guid]::NewGuid().ToString("N"))
$oldPath = $env:PATH
$oldHome = $env:HOME
$oldProfile = $env:USERPROFILE
$oldCodexHome = $env:CODEX_HOME
$oldPluginJson = $env:MOCK_PLUGIN_JSON
$oldMarketJson = $env:MOCK_MARK_JSON
$oldMockLog = $env:MOCK_CODEX_LOG

function Invoke-Child {
    param([string]$Script, [string[]]$Arguments = @())
    $output = (& $pwsh -NoProfile -NonInteractive -File $Script @Arguments 2>&1 | Out-String)
    return [pscustomobject]@{ Output = $output; Code = $LASTEXITCODE }
}
function Set-PluginInventory {
    param([string]$Text)
    Set-Content -LiteralPath $env:MOCK_PLUGIN_JSON -Value $Text -Encoding utf8
}

try {
    New-Item -ItemType Directory -Force -Path $fixture | Out-Null
    $fakeBin = Join-Path $fixture "bin"
    New-Item -ItemType Directory -Force -Path $fakeBin | Out-Null
    $env:HOME = Join-Path $fixture "home"
    $env:USERPROFILE = $env:HOME
    $env:CODEX_HOME = Join-Path $fixture "codex"
    $env:PATH = "$fakeBin;$oldPath"
    $env:MOCK_PLUGIN_JSON = Join-Path $fixture "plugins.json"
    $env:MOCK_MARK_JSON = Join-Path $fixture "marketplaces.json"
    $env:MOCK_CODEX_LOG = Join-Path $fixture "codex-calls.log"
    New-Item -ItemType Directory -Force -Path $env:HOME, $env:CODEX_HOME | Out-Null

    # Mock every native CLI interaction; real Codex commands are never invoked.
    $mock = @'
@echo off
echo %*>>"%MOCK_CODEX_LOG%"
if "%1"=="plugin" (
  if "%2"=="list" (
    type "%MOCK_PLUGIN_JSON%"
    exit /b 0
  )
  if "%2"=="marketplace" (
    if "%3"=="list" (
      type "%MOCK_MARK_JSON%"
      exit /b 0
    )
  )
)
exit /b 9
'@
    Set-Content -LiteralPath (Join-Path $fakeBin "codex.cmd") -Value $mock -Encoding ascii
    Set-Content -LiteralPath $env:MOCK_MARK_JSON -Encoding utf8 -Value @'
{"marketplaces":[{"name":"agent-skills","root":"C:\\fixture\\marketplace"},{"name":"codex-frontend-production-qa","root":"C:\\fixture\\frontend"}]}
'@
    Set-PluginInventory -Text @'
{"installed":[],"available":[{"pluginId":"agent-skills@agent-skills","version":"0.6.13"},{"pluginId":"frontend-production-qa@codex-frontend-production-qa","version":"1.2.3"}]}
'@

    $missing = Invoke-Child -Script $planner -Arguments @("-Component", "agent-skills", "-Json")
    if ($missing.Code -ne 0) { throw "MISSING planner exit: $($missing.Code): $($missing.Output)" }
    $row = $missing.Output | ConvertFrom-Json
    if ($row.Status -ne "MISSING" -or $row.InstallLink -notmatch "^codex://plugins/install/agent-skills") {
        throw "Expected safe MISSING state with native install link: $($missing.Output)"
    }

    Set-PluginInventory -Text @'
{"installed":[{"pluginId":"agent-skills@agent-skills","version":"0.6.13","enabled":true}],"available":[]}
'@
    $installed = Invoke-Child -Script $planner -Arguments @("-Component", "agent-skills", "-Json")
    if ($installed.Code -ne 0) { throw "Installed state runner exit: $($installed.Code)" }
    $row = $installed.Output | ConvertFrom-Json
    if ($row.Status -ne "INSTALLED" -or $row.InstallLink) {
        throw "Installed plugin must not receive installation link: $($installed.Output)"
    }

    Set-PluginInventory -Text @'
{"installed":[],"available":[{"pluginId":"agent-skills@agent-skills","version":"0.6.13"}]}
'@
    $direct = Join-Path $env:CODEX_HOME "skills\frontend-ui-engineering\SKILL.md"
    New-Item -ItemType Directory -Force -Path (Split-Path $direct) | Out-Null
    Set-Content -LiteralPath $direct -Value ("---" + [Environment]::NewLine + "name: frontend-ui-engineering" + [Environment]::NewLine + "---")
    $conflict = Invoke-Child -Script $planner -Arguments @("-Component", "agent-skills", "-Json")
    if ($conflict.Code -ne 0) { throw "Collision runner exit: $($conflict.Code)" }
    $row = $conflict.Output | ConvertFrom-Json
    if ($row.Status -ne "CONFLICT" -or $row.InstallLink -or @($row.DirectIdCollisions).Count -lt 1) {
        throw "Existing required skill ID must block install recommendation: $($conflict.Output)"
    }

    Remove-Item -LiteralPath (Split-Path $direct) -Recurse -Force
    Set-Content -LiteralPath $env:MOCK_PLUGIN_JSON -Value "NOT JSON" -Encoding ascii
    $unknown = Invoke-Child -Script $planner -Arguments @("-Component", "agent-skills", "-Json")
    if ($unknown.Code -ne 0) { throw "Unknown evidence runner exit: $($unknown.Code)" }
    $row = $unknown.Output | ConvertFrom-Json
    if ($row.Status -ne "UNKNOWN" -or $row.InstallLink) {
        throw "Malformed CLI evidence must stay UNKNOWN: $($unknown.Output)"
    }

    $unsafe = Invoke-Child -Script $bootstrap -Arguments @("-Apply")
    if ($unsafe.Code -eq 0 -or $unsafe.Output -notmatch "\[BLOCKED\]") {
        throw "Legacy bootstrap mutation flag must be refused"
    }

    foreach ($line in @(Get-Content -LiteralPath $env:MOCK_CODEX_LOG)) {
        if ($line -notmatch '^plugin list --available --json$' -and
            $line -notmatch '^plugin marketplace list --json$') {
            throw "Planner issued unexpected Codex command: $line"
        }
    }
}
finally {
    $env:PATH = $oldPath
    $env:HOME = $oldHome
    $env:USERPROFILE = $oldProfile
    $env:CODEX_HOME = $oldCodexHome
    $env:MOCK_PLUGIN_JSON = $oldPluginJson
    $env:MOCK_MARK_JSON = $oldMarketJson
    $env:MOCK_CODEX_LOG = $oldMockLog
    if (Test-Path -LiteralPath $fixture) {
        Remove-Item -LiteralPath $fixture -Recurse -Force
    }
}
Write-Host "Guided dependency installation fixtures PASS."
exit 0
