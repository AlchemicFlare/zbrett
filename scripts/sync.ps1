# sync.ps1 — aktuellen feature-Branch auf origin/<BaseBranch> rebasen.
. "$PSScriptRoot\lib\common.ps1"

$branch = Current-Branch
if ($branch -eq $BaseBranch) { Die "✖ Auf '$branch' — sync ist für feature-Branches (Base: pull.ps1)." }
Clean-Locks; Ensure-Origin; Require-Clean
Info "▶ [$ProjectKey] Fetching origin…"; & git fetch origin --prune
Info "▶ Rebase '$branch' auf origin/$BaseBranch…"
& git rebase "origin/$BaseBranch"
if ($LASTEXITCODE -eq 0) {
  Ok "✔ aktuell. Falls vorher gepusht: .\scripts\push.ps1 -ForceWithLease"
} else {
  Die "⚠ Konflikte: lösen → git add <datei> → git rebase --continue (oder --abort)"
}
