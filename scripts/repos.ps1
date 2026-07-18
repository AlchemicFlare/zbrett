# repos.ps1 — get the MOST RECENT code for ALL registered repos.
# Clones missing repos, pulls (ff-only) the base branch of existing ones.
# Registry: repos.psd1 next to this script (or pass -Registry). Format:
#   @{ 'd2b-saas-hubspot' = @{ Remote = 'git@bitbucket.org:precisyn/d2b-saas-hubspot.git'; Base = 'develop' } }
# Usage: .\scripts\repos.ps1 [dev-root] [-Registry <path>]    (default root: C:\Dev)
param(
  [string]$DevRoot = 'C:\Dev',
  [string]$Registry = (Join-Path $PSScriptRoot 'repos.psd1')
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $Registry)) { [Console]::Error.WriteLine("✖ Registry fehlt: $Registry"); exit 1 }
$Projects = Import-PowerShellDataFile -Path $Registry

Write-Host "▶ Dev-Root: $DevRoot`n"
foreach ($key in ($Projects.Keys | Sort-Object)) {
  $p = $Projects[$key]
  $remote = $p.Remote
  $base = if ($p.Base) { $p.Base } else { 'develop' }
  $dir = Join-Path $DevRoot $key
  Write-Host "── $key  ($base) ──"
  if (Test-Path (Join-Path $dir '.git')) {
    & git -C $dir fetch origin --prune
    & git -C $dir show-ref --verify --quiet "refs/heads/$base"
    if ($LASTEXITCODE -eq 0) {
      & git -C $dir checkout $base
    } else {
      & git -C $dir ls-remote --exit-code --heads origin $base 2>$null | Out-Null
      if ($LASTEXITCODE -eq 0) { & git -C $dir checkout -b $base --track "origin/$base" }
    }
    & git -C $dir pull --ff-only origin $base 2>$null
    if ($LASTEXITCODE -ne 0) {
      [Console]::Error.WriteLine("  ⚠ $key`: '$base' nicht fast-forward — lokal divergiert, manuell prüfen (.\scripts\reset-to-remote.ps1 $base).")
    }
  } else {
    & git ls-remote $remote 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
      & git clone $remote $dir
      & git -C $dir checkout $base 2>$null
    } else {
      [Console]::Error.WriteLine("  ⚠ $key`: Remote nicht erreichbar / Repo existiert noch nicht: $remote")
    }
  }
  Write-Host ""
}
Write-Host "✔ Fertig. Repos unter $DevRoot."
