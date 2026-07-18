# pull.ps1 — lokalen BaseBranch auffrischen.
. "$PSScriptRoot\lib\common.ps1"

Clean-Locks; Ensure-Origin; Require-Clean
& git fetch origin --prune
& git checkout $BaseBranch 2>$null
if ($LASTEXITCODE -ne 0) { & git checkout -b $BaseBranch --track "origin/$BaseBranch" }
& git pull --rebase origin $BaseBranch
if ($LASTEXITCODE -ne 0) { Die "✖ Rebase nicht sauber — Konflikte lösen (git rebase --continue) oder 'git rebase --abort'." }
Ok "✔ [$ProjectKey] '$BaseBranch' aktuell. Feature: .\scripts\start.ps1 <name>"
