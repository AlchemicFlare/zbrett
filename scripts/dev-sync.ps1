# dev-sync.ps1 — run this BEFORE you start working (Solo-/Trunk-Workflow).
# Pulls everything from origin and lands you cleanly on the base branch.
# Any uncommitted work is carried along (stashed + reapplied), never stranded.
# Usage: .\scripts\dev-sync.ps1
. "$PSScriptRoot\lib\common.ps1"

function Run { & git @args; if ($LASTEXITCODE) { Die "✖ git $($args -join ' ') failed" } }

Clean-Locks; Ensure-Origin
Info "== fetch origin (+prune) =="
Run fetch origin --prune

# carry uncommitted work (tracked + untracked) onto the base branch
$stashed = $false
if ((& git status --porcelain)) {
  Warn "⚠ Uncommitted work found → stashing to carry onto $BaseBranch"
  Run stash push -u -m "dev-sync $(Get-Date -Format s)"
  $stashed = $true
}

& git show-ref --verify --quiet "refs/heads/$BaseBranch"
if ($LASTEXITCODE -eq 0) {
  Run checkout $BaseBranch
  & git pull --ff-only origin $BaseBranch
  if ($LASTEXITCODE) {
    Warn "⚠ local $BaseBranch diverged → rebasing onto origin/$BaseBranch"
    Run pull --rebase origin $BaseBranch
  }
} else {
  Run checkout -b $BaseBranch "origin/$BaseBranch"
}

if ($stashed) {
  Info "▶ Restoring your work onto $BaseBranch"
  & git stash pop
  if ($LASTEXITCODE) { Die "✖ stash pop conflict → resolve + commit. Your work is safe in 'git stash list'." }
}

Ok "✔ [$ProjectKey] on $BaseBranch, in sync with origin."
& git status -sb
