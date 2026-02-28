param(
  [string]$Bind = "127.0.0.1:46666"
)

$ErrorActionPreference = "Stop"

$vcvars = '"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"'
$cmd = "$vcvars && set PATH=%USERPROFILE%\.cargo\bin;%PATH% && cargo build --release -p smartflow-core -p smartflow-ui"

Write-Host "[SmartFlow] Building release binaries..."
cmd /c $cmd
if ($LASTEXITCODE -ne 0) {
  throw "cargo build failed"
}

$releaseDir = Join-Path $PSScriptRoot "..\release\SmartFlow"
New-Item -ItemType Directory -Force $releaseDir | Out-Null

Copy-Item (Join-Path $PSScriptRoot "..\target\release\smartflow-core.exe") (Join-Path $releaseDir "smartflow-core.exe") -Force
Copy-Item (Join-Path $PSScriptRoot "..\target\release\smartflow-ui.exe") (Join-Path $releaseDir "smartflow-ui.exe") -Force
Copy-Item (Join-Path $PSScriptRoot "..\smartflow-core\config.example.json5") (Join-Path $releaseDir "config.example.json5") -Force
Copy-Item (Join-Path $PSScriptRoot "..\README.md") (Join-Path $releaseDir "README.md") -Force

$proxifyreDir = Join-Path $PSScriptRoot "..\third_party\proxifyre\pkg"
if (Test-Path $proxifyreDir) {
  $releaseProxifyre = Join-Path $releaseDir "proxifyre"
  New-Item -ItemType Directory -Force $releaseProxifyre | Out-Null
  Copy-Item (Join-Path $proxifyreDir "*") $releaseProxifyre -Recurse -Force
  Write-Host "[SmartFlow] Bundled ProxiFyre runtime into: $releaseProxifyre"
} else {
  Write-Host "[SmartFlow] ProxiFyre runtime not found at $proxifyreDir (set SMARTFLOW_PROXIFYRE_DIR manually at runtime)"
}

Write-Host "[SmartFlow] Build output: $releaseDir"
Write-Host "[SmartFlow] Run core: .\smartflow-core.exe --bind $Bind"
Write-Host "[SmartFlow] Run ui:   .\smartflow-ui.exe"
