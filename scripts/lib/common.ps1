# common.ps1 — shared git/ssh helpers + self-configuring project context.
# Dot-source from a script:   . "$PSScriptRoot\lib\common.ps1"
# Compatible with Windows PowerShell 5.1 and PowerShell 7+.
#
# Configuration is DERIVED from the repo (no registry needed):
#   - GitRemote:   git remote get-url origin
#   - BaseBranch:  config override > origin/HEAD > develop if it exists > main
#   - ProjectKey:  repo folder name
# Optional per-repo override (gitignore it): config\git.local.psd1
#   @{ BaseBranch = 'develop'; GitRemote = 'git@bitbucket.org:ws/repo.git'; Protected = @('main','develop') }

$ErrorActionPreference = 'Stop'

# ── print helpers (✖/⚠ go to stderr) ──
function Info($m) { Write-Host $m }
function Ok($m)   { Write-Host $m -ForegroundColor Green }
function Warn($m) { [Console]::Error.WriteLine($m) }
function Die($m)  { [Console]::Error.WriteLine($m); exit 1 }

# ── repo root ──
$Root = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Root)) {
  Die "✖ Kein Git-Repo (von hier aus)."
}
Set-Location $Root
$ProjectKey = Split-Path $Root -Leaf

# ── optional local override ──
$Local = @{}
$localPath = Join-Path $Root 'config\git.local.psd1'
if (Test-Path $localPath) { $Local = Import-PowerShellDataFile -Path $localPath }

# ── remote ──
$GitRemote = if ($Local.GitRemote) { $Local.GitRemote } else { (& git remote get-url origin 2>$null) }
if ($LASTEXITCODE -ne 0) { $GitRemote = '' }

# ── base branch: override > origin/HEAD > develop > main ──
function Resolve-BaseBranch {
  if ($Local.BaseBranch) { return $Local.BaseBranch }
  $head = (& git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>$null)
  if ($LASTEXITCODE -eq 0 -and $head) {
    $b = $head -replace '^origin/', ''
    # origin/HEAD often points at main even when the team integrates on develop
    & git show-ref --verify --quiet 'refs/remotes/origin/develop'
    if ($LASTEXITCODE -eq 0) { return 'develop' }
    return $b
  }
  foreach ($b in @('develop', 'main', 'master')) {
    & git show-ref --verify --quiet "refs/remotes/origin/$b"
    if ($LASTEXITCODE -eq 0) { return $b }
    & git show-ref --verify --quiet "refs/heads/$b"
    if ($LASTEXITCODE -eq 0) { return $b }
  }
  return 'main'
}
$BaseBranch = Resolve-BaseBranch
$Protected = if ($Local.Protected) { @($Local.Protected) } else { @('main', 'master', $BaseBranch) | Select-Object -Unique }

# ── SSH target from remote (git@host:path or ssh://git@host/path) ──
$SshTarget = ''
if ($GitRemote -match '^(?:ssh://)?([^@/]+@[^:/]+)') { $SshTarget = $Matches[1] }

# ── Bitbucket web URL from remote (for PR links) ──
function Repo-WebUrl {
  if ($GitRemote -match 'bitbucket\.org[:/](.+?)(?:\.git)?$') { return "https://bitbucket.org/$($Matches[1])" }
  return ''
}

# ── git/ssh helpers ──
function Clean-Locks {
  Get-ChildItem -Path (Join-Path $Root '.git') -Filter '*.lock' -File -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $Root '.git/objects/maintenance.lock') -Force -ErrorAction SilentlyContinue
  Get-ChildItem (Join-Path $Root '.git/objects') -Filter 'tmp_obj_*' -Recurse -File -ErrorAction SilentlyContinue |
    Remove-Item -Force -ErrorAction SilentlyContinue
}

function Ensure-Origin {
  if ([string]::IsNullOrWhiteSpace($GitRemote)) { Die "✖ Kein origin-Remote. git remote add origin <url>" }
  $remotes = & git remote
  if ($remotes -notcontains 'origin') { & git remote add origin $GitRemote; Info "＋ origin → $GitRemote" }
}

function Require-Clean {
  & git diff --quiet;          $a = $LASTEXITCODE
  & git diff --cached --quiet; $b = $LASTEXITCODE
  if ($a -ne 0 -or $b -ne 0) { Die "✖ Uncommitted changes. Commit/stash zuerst (oder dev-sync.ps1 nutzen)." }
}

function Ssh-Check {
  if ([string]::IsNullOrWhiteSpace($SshTarget)) { return $true }  # https remote — nothing to check
  $out = (& ssh -o BatchMode=yes -o ConnectTimeout=8 -T $SshTarget 2>&1) -join "`n"
  if ($out -match 'authenticated|logged in') { return $true }
  Warn "✖ SSH auth fehlgeschlagen ($SshTarget): $out"
  Warn "  Fix (Win): Start-Service ssh-agent ; ssh-add `$env:USERPROFILE\.ssh\<key>"
  return $false
}

function Current-Branch { (& git rev-parse --abbrev-ref HEAD).Trim() }

function Is-Protected($branch) { $Protected -contains $branch }
