# bootstrap-first-push.ps1 — ONE-TIME initial setup + first push to an EMPTY Bitbucket repo.
# After this, use dev-sync.ps1 / dev-ship.ps1 for the ongoing solo/trunk workflow.
# (The ongoing scripts rebase onto origin/<base>, which only exists AFTER this first push.)
#
# Prerequisite: create the repo EMPTY on Bitbucket first (no README/.gitignore):
#   https://bitbucket.org/precisyn/  → Create repository → name: zbrett
#
# Usage:  cd C:\Dev\dasBRETT\zbrett ; .\scripts\bootstrap-first-push.ps1
param(
  [string]$Remote  = 'git@bitbucket.org:precisyn/zbrett.git',
  [string]$Base    = 'main',
  [string]$Message = 'chore: scaffold zBRETT code monorepo (7 packages, measurements, deploy, EUPL-1.2)'
)
$ErrorActionPreference = 'Stop'
function Info($m){ Write-Host $m }
function Ok($m){ Write-Host $m -ForegroundColor Green }
function Die($m){ [Console]::Error.WriteLine($m); exit 1 }

# run from the folder this script lives in (repo root = website\)
Set-Location (Split-Path $PSScriptRoot -Parent)
Info "▶ Repo root: $(Get-Location)"

# ── clean any stale locks (agent/editor crashes, cloud-sync leftovers) ──
if (Test-Path '.git') {
  Get-ChildItem '.git' -Filter '*.lock' -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Remove-Item '.git\objects\maintenance.lock' -Force -ErrorAction SilentlyContinue
}

# ── init if needed, force base branch name ──
if (-not (Test-Path '.git')) { & git init | Out-Null; Info "＋ git init" }
& git symbolic-ref HEAD "refs/heads/$Base"    # name the branch $Base even before first commit

# ensure identity is set (uses global if present; sets a sensible local default otherwise)
if (-not (& git config user.email)) { & git config user.email 'hello@protagx.com' }
if (-not (& git config user.name))  { & git config user.name  'protagx' }

# ── remote ──
$have = (& git remote)
if ($have -contains 'origin') { & git remote set-url origin $Remote } else { & git remote add origin $Remote }
Info "＋ origin → $Remote"

# ── SSH auth check (Bitbucket over SSH) ──
$sshTarget = 'git@bitbucket.org'
if ($Remote -match '^(?:ssh://)?([^@/]+@[^:/]+)') { $sshTarget = $Matches[1] }
Info "▶ SSH check ($sshTarget)…"
$out = (& ssh -o BatchMode=yes -o ConnectTimeout=8 -T $sshTarget 2>&1) -join "`n"
if ($out -notmatch 'authenticated|logged in') {
  Die "✖ SSH auth failed for $sshTarget.`n  Fix (Win): Start-Service ssh-agent ; ssh-add `$env:USERPROFILE\.ssh\id_ed25519`n  Details: $out"
}
Ok "✔ SSH ok."

# ── commit everything, push ──
& git add -A
& git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { & git commit -m $Message | Out-Null; Ok "✔ Committed: $Message" }
else { Info "▶ Nothing to commit (already committed)." }

# guard: refuse to overwrite a NON-empty remote
$remoteHeads = (& git ls-remote --heads origin 2>$null)
if ($remoteHeads) { Die "✖ origin already has branches — this is the FIRST-push bootstrap only. Use .\scripts\dev-ship.ps1 instead." }

Info "▶ Pushing $Base → origin (first time)…"
& git push -u origin $Base
if ($LASTEXITCODE -ne 0) { Die "✖ Push rejected. Is the Bitbucket repo created and EMPTY? Retry, or see .\scripts\dev-doctor.ps1" }

Ok "✔ Live on origin/$Base."
Info ""
Info "Next steps:"
Info "  1. uv sync            # resolve the workspace"
Info "  2. uv run reuse lint  # licensing gate (should be green)"
Info "  3. uv run pytest      # smoke tests"
Info "  Ongoing: .\scripts\dev-ship.ps1 ""feat: ...""  (solo/trunk on main)."
Info "  Public GitHub EUPL mirror: set CI var GITHUB_MIRROR_URL, then it pushes on main/tags."
