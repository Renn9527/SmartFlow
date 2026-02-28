param(
  [string]$Bind = "127.0.0.1:46666"
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

$core = Join-Path $root "target\release\smartflow-core.exe"
$ui = Join-Path $root "target\release\smartflow-ui.exe"

if (!(Test-Path $core) -or !(Test-Path $ui)) {
  Write-Host "Release binaries not found. Run .\scripts\build-release.ps1 first."
  exit 1
}

Write-Host "Starting smartflow-core on $Bind"
Start-Process -FilePath $core -ArgumentList "--bind", $Bind

Start-Sleep -Seconds 2

Write-Host "Starting smartflow-ui"
Start-Process -FilePath $ui
