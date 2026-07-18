# Git scripts (git-bitbucket toolkit)

Self-configuring PowerShell helpers for the **solo/trunk** workflow on `main`.
Config is derived from the repo; `config/git.local.psd1` pins base=`main` for this project.
Requires PowerShell 5.1+ and an `origin` remote over SSH.

## First time (once)

Create the repo **empty** on Bitbucket (`precisyn/xbrett-website`), then:

```powershell
cd C:\Dev\dasBRETT\website
.\scripts\bootstrap-first-push.ps1
```

This inits git, wires the remote, checks SSH, commits everything and does the first push.

## Everyday loop (after the first push)

```powershell
.\scripts\dev-sync.ps1              # BEFORE work — pull + land cleanly on main (WIP carried, never stranded)
# … edit pages …
.\scripts\dev-ship.ps1 "feat: …"   # AFTER work — commit all, rebase others' work, push to main
```

Each `dev-ship` push auto-deploys on Netlify.

## Other tools

| Script | Purpose |
|---|---|
| `dev-doctor.ps1` | Read-only status: ahead/behind, unpushed branches, stashes, backups. Changes nothing. |
| `reset-to-remote.ps1 [branch] [-Clean]` | Set local branch exactly to origin — always makes a backup branch + WIP tag first. |
| `precheck.ps1` | Run CI gates locally before push (auto-detects stack; a static site has none, so it just reports "no stack"). |
| `start.ps1 <name>` / `push.ps1` / `sync.ps1` / `pull.ps1` | Feature-branch (PR) workflow — not needed for solo/trunk, kept for later. |
| `repos.ps1` | Clone/refresh many registered repos (needs `repos.psd1`). |

## Principles

- Never strand work — WIP is stashed + reapplied or backed up before any reset.
- Never force-push protected branches (`main`); feature branches only with `--force-with-lease`.
- Rebase (not merge) for local integration.
- On a rejected push: `dev-doctor.ps1` for the picture, then act — don't guess.
- Stale `.git\*.lock` files are cleaned automatically by the scripts.
