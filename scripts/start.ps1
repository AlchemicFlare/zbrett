# start.ps1 — neuer feature-Branch vom BaseBranch (auto-erkannt oder config).
# Usage: .\scripts\start.ps1 <kurzer-name>
param([string]$Name = "")
. "$PSScriptRoot\lib\common.ps1"

if ([string]::IsNullOrWhiteSpace($Name)) { Die "Usage: .\scripts\start.ps1 <kurzer-name>" }
$slug = ($Name.ToLower() -replace '[ ]', '-') -replace '[^a-z0-9\-_/]', ''
$branch = "feature/$slug"

Clean-Locks; Ensure-Origin; Require-Clean
Info "▶ [$ProjectKey] Fetching origin…"; & git fetch origin --prune
& git show-ref --verify --quiet "refs/heads/$BaseBranch"
if ($LASTEXITCODE -eq 0) {
  & git checkout $BaseBranch
  & git pull --rebase origin $BaseBranch
} else {
  & git ls-remote --exit-code --heads origin $BaseBranch 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) {
    & git checkout -b $BaseBranch --track "origin/$BaseBranch"
  } else {
    Info "ℹ origin/$BaseBranch fehlt — erstelle lokal."
    & git checkout -b $BaseBranch
  }
}
& git checkout -b $branch
Ok "✔ Auf '$branch' (von $BaseBranch). Arbeiten, dann .\scripts\push.ps1 ""msg"""
