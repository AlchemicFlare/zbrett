# reset-to-remote.ps1 — lokalen Branch exakt auf origin setzen (mit Backup-Ref).
# Usage: .\scripts\reset-to-remote.ps1 [branch] [-Clean]
param([string]$Branch = "", [switch]$Clean)
. "$PSScriptRoot\lib\common.ps1"

Clean-Locks; Ensure-Origin
$cur = Current-Branch
$target = if ([string]::IsNullOrWhiteSpace($Branch)) { $BaseBranch } else { $Branch }
Info "▶ [$ProjectKey] Fetching…"; & git fetch origin --prune
& git ls-remote --exit-code --heads origin $target 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Warn "✖ origin/$target fehlt."; & git branch -r; exit 1 }

$ts = Get-Date -Format 'yyyyMMdd-HHmmss'
$bk = "backup/$cur-$ts"
& git branch $bk; Info "💾 Backup (committed) → $bk"
$wip = (& git stash create 2>$null)
if (-not [string]::IsNullOrWhiteSpace($wip)) { & git tag "$bk-wip" $wip; Info "💾 Backup (uncommitted) → tag $bk-wip" }

& git checkout $target 2>$null
if ($LASTEXITCODE -ne 0) { & git checkout -b $target --track "origin/$target" }
& git reset --hard "origin/$target"; Ok "✔ '$target' == origin/$target."
if ($Clean) { & git clean -fd; Ok "✔ untracked entfernt." } else { Info "ℹ untracked behalten (-Clean zum Löschen)." }
Info "↩ Recover: git checkout $bk"
if (-not [string]::IsNullOrWhiteSpace($wip)) { Info "          git stash apply $bk-wip" }
