# dev-doctor.ps1 — read-only Lagebild: wo bin ich, was ist ungesichert, was divergiert?
# Ändert NICHTS. Usage: .\scripts\dev-doctor.ps1
. "$PSScriptRoot\lib\common.ps1"

& git fetch origin --prune 2>$null | Out-Null

Write-Host "== Repo ==" -ForegroundColor Cyan
Write-Host "  $ProjectKey  ·  base: $BaseBranch  ·  remote: $GitRemote"

Write-Host "`n== Status ==" -ForegroundColor Cyan
& git status -sb

Write-Host "`n== Ahead/Behind vs. origin/$BaseBranch ==" -ForegroundColor Cyan
$cur = Current-Branch
$counts = (& git rev-list --left-right --count "origin/$BaseBranch...$cur" 2>$null)
if ($LASTEXITCODE -eq 0 -and $counts) {
  $p = $counts -split '\s+'
  Write-Host "  '$cur': $($p[1]) ahead / $($p[0]) behind origin/$BaseBranch"
} else {
  Write-Host "  (origin/$BaseBranch nicht auflösbar)" -ForegroundColor Yellow
}

Write-Host "`n== Lokale Branches ohne Upstream / mit eigenen Commits ==" -ForegroundColor Cyan
$found = $false
foreach ($b in (& git for-each-ref --format='%(refname:short)' refs/heads/)) {
  if ($b -like 'backup/*') { continue }
  $u = (& git rev-parse --abbrev-ref "$b@{upstream}" 2>$null)
  if ($LASTEXITCODE -ne 0) {
    $n = (& git rev-list --count "origin/$BaseBranch..$b" 2>$null)
    if ($n -and [int]$n -gt 0) { Write-Host "  $b — kein Upstream, $n Commit(s) nicht auf $BaseBranch" -ForegroundColor Yellow; $found = $true }
  } else {
    $n = (& git rev-list --count "$u..$b" 2>$null)
    if ($n -and [int]$n -gt 0) { Write-Host "  $b — $n Commit(s) nicht gepusht ($u)" -ForegroundColor Yellow; $found = $true }
  }
}
if (-not $found) { Write-Host "  none" -ForegroundColor Green }
Write-Host "  (delete with: git branch -D <name>)" -ForegroundColor DarkGray

Write-Host "`n== Stashes ==" -ForegroundColor Cyan
$stash = & git stash list
if ($stash) { Write-Host $stash -ForegroundColor Yellow } else { Write-Host "  none" -ForegroundColor Green }

Write-Host "`n== Backups (reset-to-remote) ==" -ForegroundColor Cyan
$bk = & git for-each-ref --format='%(refname:short)' refs/heads/backup/
if ($bk) { $bk | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow } } else { Write-Host "  none" -ForegroundColor Green }
