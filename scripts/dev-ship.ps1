# dev-ship.ps1 — run this AFTER you work, to publish everything (Solo-/Trunk-Workflow).
# Commits ALL local changes, integrates others' work (rebase), pushes to the base branch.
# If direct push is blocked (branch protection), it pushes a feature branch and prints
# the PR link — your work lands on origin either way, never stranded.
# Usage: .\scripts\dev-ship.ps1 "feat: what I did"
param([Parameter(Position = 0)][string]$Message)
. "$PSScriptRoot\lib\common.ps1"

function Run { & git @args; if ($LASTEXITCODE) { Die "✖ git $($args -join ' ') failed" } }

Clean-Locks; Ensure-Origin

# if not on base: carry uncommitted work over; refuse to auto-move committed work
$current = Current-Branch
if ($current -ne $BaseBranch) {
  $ahead = (& git rev-list --count "origin/$BaseBranch..$current" 2>$null)
  if ($ahead -and [int]$ahead -gt 0) {
    Die "✖ '$current' has $ahead commit(s) not on $BaseBranch. Won't auto-move commits → dev-doctor.ps1 zeigt die Lage; sauber mergen oder push.ps1 als Feature-Branch."
  }
  Warn "⚠ Moving your work from '$current' onto '$BaseBranch'…"
  $stashed = $false
  if ((& git status --porcelain)) { Run stash push -u -m "dev-ship move"; $stashed = $true }
  Run fetch origin --prune
  Run checkout $BaseBranch
  Run pull --rebase origin $BaseBranch
  if ($stashed) { & git stash pop; if ($LASTEXITCODE) { Die "✖ conflict moving work to $BaseBranch → resolve, re-run dev-ship" } }
}

# commit everything
if ((& git status --porcelain)) {
  if (-not $Message) { $Message = Read-Host "Commit message" }
  if (-not $Message) { Die "✖ a commit message is required" }
  Run add -A
  Run commit -m $Message
} else {
  Info "▶ Nothing new to commit — will still sync + push pending commits."
}

# integrate + push
Run fetch origin --prune
& git pull --rebase origin $BaseBranch
if ($LASTEXITCODE) { Die "✖ rebase conflict → resolve → git rebase --continue → re-run dev-ship" }

& git push origin $BaseBranch
if ($LASTEXITCODE -eq 0) {
  Ok "✔ [$ProjectKey] pushed to origin/$BaseBranch."
} else {
  # branch protection? escape hatch: feature branch + PR
  $fb = "feature/ship-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  Warn "⚠ Direct push to '$BaseBranch' blocked → pushing '$fb' instead."
  Run checkout -b $fb
  Run push -u origin $fb
  $web = Repo-WebUrl
  if ($web) { Ok "✔ Work is on origin. Open PR: $web/pull-requests/new?source=$fb&dest=$BaseBranch" }
  else      { Ok "✔ Work is on origin ($fb). Open a PR to $BaseBranch in Bitbucket." }
}
