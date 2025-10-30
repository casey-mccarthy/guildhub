# Claude Code Custom Commands for GuildHub

This directory contains custom slash commands for Claude Code to streamline development workflows.

## Available Commands

### `/submit-pr` - Auto-Submit PR (Hands-Off) 🚀 **NEW**

**Fully automated PR submission - run and go to work!**

Automatically validates, commits, and submits a PR without any user prompts.

**What it does:**
1. ✅ Auto-creates feature branch if on main
2. ✅ Rubocop auto-fix
3. ✅ Runs tests locally (continues if fail)
4. ✅ Auto-commits all changes
5. ✅ Pushes to remote
6. ✅ Creates/updates PR with auto-generated description
7. ✅ Marks as draft if tests failing
8. ✅ Never stops - handles all errors automatically

**Usage:**
```
/submit-pr
```

**When to use:**
- End of work session (save and go)
- Need to submit WIP quickly
- Auto-submit progress before leaving
- Quick iteration workflow

**Important:**
- This is NOT the final merge workflow
- Use `/pre-merge` for final validation before merge
- This is for "save progress" submissions
- CI/CD will run full checks after submission

---

### `/pre-merge` - Complete Pre-Merge Workflow ⭐

**Use this before submitting any PR for merge.**

Runs the complete pre-merge checklist:
1. ✅ Rubocop (auto-fix)
2. ✅ Brakeman security scan
3. ✅ Bundle audit
4. ✅ Docker build & test
5. ✅ Full RSpec test suite in Docker
6. ✅ Health check verification
7. 📝 Auto-generate PR description
8. 🚀 Create/update PR

**Usage:**
```
/pre-merge
```

**When to use:**
- Before requesting code review
- Before merging to main
- After completing a feature
- To verify everything works in production-like environment

---

### `/quick-test` - Fast Local Tests

Runs tests locally without Docker for faster iteration.

**What it does:**
- Rubocop auto-fix
- RSpec against localhost database
- Shows coverage

**Usage:**
```
/quick-test
```

**When to use:**
- During active development
- Quick verification of changes
- When iterating rapidly

**Requirements:**
- Docker services running: `docker compose up -d db redis`

---

### `/pr-status` - Check PR Status

Check the status of your current branch's PR and CI/CD checks.

**What it does:**
- Finds PR for current branch
- Shows all CI/CD check statuses
- Displays failed check logs if needed
- Tells you if PR is ready to merge

**Usage:**
```
/pr-status
```

**When to use:**
- After pushing changes
- To check if CI passed
- Before requesting review
- To troubleshoot CI failures

---

### `/docker-clean` - Docker Cleanup

Clean up Docker resources and optionally reset the environment.

**What it does:**
- Stops all containers
- Optionally removes volumes (data)
- Prunes unused Docker resources
- Shows disk space freed
- Optionally restarts services

**Usage:**
```
/docker-clean
```

**When to use:**
- Low on disk space
- Need fresh database
- Docker issues/corruption
- Starting a new feature

---

## Workflow Examples

### Quick Submit Flow (Hands-Off) 🚀

1. Make your changes
2. Run `/submit-pr` (auto-submits everything)
3. Go to work / step away
4. CI/CD runs automatically
5. Come back and check `/pr-status`

### Standard Development Flow

1. Make your changes
2. Run `/quick-test` frequently
3. When feature complete, run `/pre-merge`
4. Wait for CI, check with `/pr-status`
5. Request review when all checks pass

### Troubleshooting Flow

1. PR failing? Run `/pr-status` to see what's wrong
2. Fix issues locally
3. Run `/quick-test` to verify fixes
4. Push changes
5. Run `/pr-status` again

### Clean Start Flow

1. Run `/docker-clean` (with volumes)
2. Rebuild: `docker compose build`
3. Migrate: `docker compose exec web bin/rails db:migrate`
4. Run `/quick-test` to verify setup

---

## Requirements

All commands assume you have:
- Docker and Docker Compose installed
- GitHub CLI (`gh`) installed and authenticated
- Bundler installed locally
- Database services accessible

## Customization

To modify these commands, edit the `.md` files in this directory. Each command is a markdown file with:
- Description (used in Claude Code UI)
- Detailed instructions for Claude to follow
- Error handling guidance

## Tips

- Use `/submit-pr` for quick hands-off PR submission (WIP)
- Use `/pre-merge` as your final quality gate before merge
- Run `/quick-test` often during development
- Check `/pr-status` after every push
- Clean Docker regularly with `/docker-clean`

## Command Comparison

| Command | Speed | Validation | Use Case |
|---------|-------|------------|----------|
| `/submit-pr` | ⚡ Fast | Basic (local tests) | Quick WIP submission, end of session |
| `/quick-test` | ⚡ Fast | Basic (local tests) | During development, iteration |
| `/pre-merge` | 🐢 Slow | Comprehensive (Docker) | Before final merge, production-ready |
| `/pr-status` | ⚡ Instant | N/A | Check CI/CD status |
| `/docker-clean` | ⚡ Fast | N/A | Free disk space, reset env |

---

**Project:** GuildHub - P99 DKP Management
**Framework:** Rails 8.1.0
**Database:** PostgreSQL 16
**See:** `/docs/CLAUDE.md` for full development guidelines
