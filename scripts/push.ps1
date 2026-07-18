# push.ps1 — commit + push den AKTUELLEN feature-Branch. Verweigert geschützte Branches.
# Usage: .\scripts\push.ps1 ["msg"] [-ForceWithLease]
param(
  [string]$Message = "",
  [Alias('f')][switch]$ForceWithLease
)
. "$PSScriptRoot\lib\common.ps1"

if ([string]::IsNullOrWhiteSpace($Message)) {
  $Message = "chore: update " + (Get-Date -Format 'yyyy-MM-dd HH:mm')
}

Clean-Locks; Ensure-Origin
$branch = Current-Branch
if (Is-Protected $branch) {
  Die "✖ '$branch' ist geschützt. Feature-Branch: .\scripts\start.ps1 <name>  (oder dev-ship.ps1 für den Solo-Workflow)"
}

Info "▶ [$ProjectKey] SSH-Check ($SshTarget)…"
if (-not (Ssh-Check)) { exit 1 }
Ok "✔ SSH ok."

& git add -A
& git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  Info "▶ Keine Änderungen."
} else {
  & git commit -m $Message
  Ok "✔ Committed: $Message"
}

if ($ForceWithLease) {
  Info "▶ Push --force-with-lease → origin/$branch"
  & git push --force-with-lease -u origin $branch
} else {
  Info "▶ Push → origin/$branch"
  & git push -u origin $branch
  if ($LASTEXITCODE -ne 0) {
    Die "✖ Abgelehnt. .\scripts\sync.ps1 ; .\scripts\push.ps1 -ForceWithLease"
  }
}
$web = Repo-WebUrl
if ($web) { Ok "✔ PR: $web/pull-requests/new?source=$branch&dest=$BaseBranch" }
else      { Ok "✔ PR '$branch → $BaseBranch' in Bitbucket öffnen/aktualisieren." }
