# precheck.ps1 — run the SAME gates the CI pipeline runs, locally, before push.
# Auto-detects the stack per directory: package.json → npm gates, pyproject/requirements → ruff+pytest.
# Monorepo-aware: checks repo root plus direct subdirs (e.g. api/, web/).
# Usage: .\scripts\precheck.ps1
$ErrorActionPreference = 'Continue'   # run every check, then summarise

$Root = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($Root)) { [Console]::Error.WriteLine("✖ Not a git repo."); exit 1 }
Set-Location $Root
$script:fail = 0

function Check($label, [scriptblock]$block) {
  Write-Host "▶ $label"
  $out = & $block 2>&1
  if ($LASTEXITCODE -eq 0) { Write-Host "   ✓ ok" }
  else { Write-Host "   ✖ failed:"; $out | Select-Object -Last 15 | ForEach-Object { "      $_" } | Write-Host; $script:fail = 1 }
}

function Check-NodeDir($dir) {
  Push-Location $dir
  $name = if ($dir -eq $Root) { '.' } else { Split-Path $dir -Leaf }
  Write-Host "`n━━ node: $name ━━" -ForegroundColor Cyan

  Write-Host "▶ package-lock.json in sync? (CI runs 'npm ci')"
  & npm install --package-lock-only --silent *> $null
  & git diff --quiet -- package-lock.json
  if ($LASTEXITCODE -eq 0) { Write-Host "   ✓ lockfile in sync" }
  else { Write-Host "   ✖ lockfile war out of sync — wurde aktualisiert; COMMIT package-lock.json"; $script:fail = 1 }

  $pkg = Get-Content package.json -Raw | ConvertFrom-Json
  if ($pkg.scripts.lint)      { Check "ESLint (npm run lint)"          { npm run --silent lint } }
  if ($pkg.scripts.typecheck) { Check "Types (npm run typecheck)"      { npm run --silent typecheck } }
  if ($pkg.scripts.build)     { Check "Build (npm run build)"          { npm run --silent build } }
  Pop-Location
}

function Check-PythonDir($dir) {
  Push-Location $dir
  $name = if ($dir -eq $Root) { '.' } else { Split-Path $dir -Leaf }
  Write-Host "`n━━ python: $name ━━" -ForegroundColor Cyan
  $py = if (Test-Path .venv\Scripts\python.exe) { '.venv\Scripts\python.exe' } else { 'python' }
  Check "ruff check"  { & $py -m ruff check . }
  Check "pytest -q"   { & $py -m pytest -q }
  # mypy non-blocking (matches CI)
  Write-Host "▶ mypy (non-blocking)"
  & $py -m mypy . *> $null
  if ($LASTEXITCODE -eq 0) { Write-Host "   ✓ ok" } else { Write-Host "   ⚠ mypy findings (non-blocking, CI ebenso)" }
  Pop-Location
}

# discover stacks: root + direct subdirs
$dirs = @($Root) + (Get-ChildItem $Root -Directory | Where-Object { $_.Name -notmatch '^(\.|node_modules|archive)' } | ForEach-Object { $_.FullName })
$seen = $false
foreach ($d in $dirs) {
  if (Test-Path (Join-Path $d 'package.json')) { Check-NodeDir $d; $seen = $true }
  elseif ((Test-Path (Join-Path $d 'pyproject.toml')) -or (Test-Path (Join-Path $d 'requirements.in'))) { Check-PythonDir $d; $seen = $true }
}
if (-not $seen) { Write-Host "⚠ Kein bekannter Stack gefunden (package.json / pyproject.toml / requirements.in)." }

Write-Host ""
if ($script:fail -eq 0) {
  Write-Host "✅ All local gates passed — safe to push." -ForegroundColor Green
} else {
  Write-Host "❌ Fix the ✖ items above before pushing (saves a red pipeline + CI minutes)." -ForegroundColor Red
  exit 1
}
