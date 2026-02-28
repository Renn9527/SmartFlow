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

if (!(Test-Path $asset)) {
  throw "Release asset not found: $asset"
}

gh auth status -h github.com | Out-Null

$originUrl = ""
try {
  $originUrl = git -C $root remote get-url origin 2>$null
} catch {
  $originUrl = ""
}

if ([string]::IsNullOrWhiteSpace($originUrl)) {
  Write-Host "[SmartFlow] Creating GitHub repo $Repo ($Visibility) and pushing source..."
  gh repo create $Repo --$Visibility --source $root --remote origin --push
} else {
  Write-Host "[SmartFlow] Pushing source to existing origin..."
  git -C $root push -u origin HEAD
}

if ([string]::IsNullOrWhiteSpace($Tag)) {
  $Tag = "v0.1.0-$(Get-Date -Format 'yyyyMMdd-HHmm')"
}

$tagExists = git -C $root tag -l $Tag
if ([string]::IsNullOrWhiteSpace($tagExists)) {
  git -C $root tag -a $Tag -m "SmartFlow release $Tag"
}

git -C $root push origin $Tag

Write-Host "[SmartFlow] Creating GitHub release $Tag with asset: $asset"
gh release create $Tag $asset --title "SmartFlow $Tag" --notes "Automated release package."

Write-Host "[SmartFlow] Done."
