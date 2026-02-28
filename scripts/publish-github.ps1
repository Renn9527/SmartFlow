param(
  [Parameter(Mandatory = $true)]
  [string]$Repo,

  [ValidateSet("public", "private")]
  [string]$Visibility = "public",

  [string]$Tag = "",

  [string]$AssetPath = "release/SmartFlow-2026-02-28-build3.zip"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$asset = Join-Path $root $AssetPath
$rootPath = $root.Path

function Invoke-External {
  param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [string[]]$Arguments = @(),

    [switch]$CaptureOutput
  )

  if ($CaptureOutput) {
    $output = & $FilePath @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
      $detail = ($output | Out-String).Trim()
      throw "$FilePath failed with exit code $LASTEXITCODE`n$detail"
    }
    return ($output | Out-String).Trim()
  }

  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$FilePath failed with exit code $LASTEXITCODE"
  }
}

if (!(Test-Path $asset)) {
  throw "Release asset not found: $asset"
}

Invoke-External gh @("auth", "status", "-h", "github.com")

$originUrl = ""
if ((& git -C $rootPath remote get-url origin 2>$null)) {
  if ($LASTEXITCODE -eq 0) {
    $originUrl = (& git -C $rootPath remote get-url origin).Trim()
  }
}

if ([string]::IsNullOrWhiteSpace($originUrl)) {
  Write-Host "[SmartFlow] Creating GitHub repo $Repo ($Visibility) and pushing source..."
  Invoke-External gh @(
    "repo",
    "create",
    $Repo,
    "--$Visibility",
    "--source",
    $rootPath,
    "--remote",
    "origin",
    "--push"
  )
} else {
  Write-Host "[SmartFlow] Pushing source to existing origin..."
  Invoke-External git @("-C", $rootPath, "push", "-u", "origin", "HEAD")
}

if ([string]::IsNullOrWhiteSpace($Tag)) {
  $Tag = "v0.1.0-$(Get-Date -Format 'yyyyMMdd-HHmm')"
}

$tagExists = Invoke-External git @("-C", $rootPath, "tag", "-l", $Tag) -CaptureOutput
if ([string]::IsNullOrWhiteSpace($tagExists)) {
  Invoke-External git @("-C", $rootPath, "tag", "-a", $Tag, "-m", "SmartFlow release $Tag")
}

Invoke-External git @("-C", $rootPath, "push", "origin", $Tag)

Write-Host "[SmartFlow] Creating GitHub release $Tag with asset: $asset"
Invoke-External gh @(
  "release",
  "create",
  $Tag,
  $asset,
  "--title",
  "SmartFlow $Tag",
  "--notes",
  "Automated release package."
)

Write-Host "[SmartFlow] Done."
