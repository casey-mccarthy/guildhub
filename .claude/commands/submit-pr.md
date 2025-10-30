# Description: Auto-submit PR with tests and validation (hands-off workflow)

You are helping automatically validate code, commit changes, and submit a pull request. This is a hands-off workflow for submitting work-in-progress.

## Steps

### Step 1: Pre-Flight Checks (Fully Automated)

1. **Check current branch**
   ```bash
   git branch --show-current
   ```
   - If on `main`, **auto-create** feature branch: `auto-submit/$(date +%Y-%m-%d-%H-%M-%S)`
   - If on feature branch, continue with existing branch
   - Report which branch is being used

2. **Check for uncommitted changes**
   ```bash
   git status --porcelain
   ```
   - If uncommitted changes exist, they will be committed in Step 3
   - If no changes, will push existing commits (if any)
   - Report status

### Step 2: Run Validation (Automated - Never Stops)

1. **Rubocop auto-fix**
   ```bash
   bundle exec rubocop -a
   ```
   - Auto-fix all style issues
   - Report any unfixable offenses (but continue)
   - Track offense count for PR description

2. **Run tests locally (with error handling)**
   ```bash
   DATABASE_HOST=localhost bundle exec rspec --format progress || true
   ```
   - Run tests and capture results
   - **If tests fail:** Continue anyway, mark PR as draft, add warning to description
   - **If database not running:** Skip tests, add note to PR, continue
   - **If tests pass:** Note success in PR
   - Always continue to next step regardless of result

### Step 3: Commit Changes

1. **Stage all changes**
   ```bash
   git add -A
   ```

2. **Check if there are changes to commit**
   ```bash
   git diff --cached --quiet
   ```
   - If no changes, skip commit
   - If changes exist, create commit

3. **Generate commit message**
   - Analyze changed files
   - Determine commit type (feat, fix, test, docs, style, refactor, chore)
   - Create conventional commit message
   - Include file changes summary

4. **Create commit**
   ```bash
   git commit -m "[Generated message]"
   ```

### Step 4: Push Branch

1. **Push to remote**
   ```bash
   git push -u origin $(git branch --show-current)
   ```
   - Creates remote branch if doesn't exist
   - Updates existing branch if already pushed

### Step 5: Create or Update PR

1. **Check if PR exists**
   ```bash
   gh pr list --head $(git branch --show-current) --json number
   ```

2. **Generate PR title and description**
   - Analyze all commits on branch (vs main)
   - Extract task IDs if present (e.g., [T1.2.3])
   - Summarize changes
   - List modified files
   - Include test results

3. **Create new PR if none exists**
   ```bash
   gh pr create --title "[Generated Title]" --body "[Generated Body]"
   ```

4. **Update existing PR if found**
   ```bash
   gh pr edit [PR-NUMBER] --body "[Updated Body with latest changes]"
   ```

### Step 6: Final Report

Provide user with:

```
✅ PR Submitted Successfully!

Branch: [branch-name]
PR: #[number] - [title]
URL: [pr-url]

Summary:
- ✅ Rubocop: [X] offenses fixed
- ✅ Tests: [X] examples, [Y] failures
- ✅ Committed: [X] files changed
- ✅ Pushed: [commit-count] commits

CI/CD Status:
Run `/pr-status` to check CI/CD progress

Next Steps:
1. CI/CD will run automatically
2. Check status: /pr-status
3. PR will be ready for review when CI passes

You can safely step away - the PR is submitted! 🚀
```

## PR Description Template

Use this template for auto-generated PR descriptions:

```markdown
## Summary

[Auto-generated summary of changes based on commits]

## Changes Made

[Bullet list of key changes from commit messages]

**Files Modified:**
- [file1]
- [file2]
- [file3]

## Test Results

**Local Test Run:**
- Examples: [X]
- Failures: [Y]
- Pending: [Z]
- Coverage: [%]

**Validation:**
- ✅ Rubocop: [status]
- ✅ Tests: [status]

## Type of Change

[Auto-detected based on commits:]
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Test updates

## Notes

This PR was auto-submitted using `/submit-pr` command.
Please review changes and run full `/pre-merge` validation before merging.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Commit Message Template

```
[type]: [short description]

[Detailed changes]

**Changes:**
- [change1]
- [change2]

**Files modified:** [count]
**Tests:** [status]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Error Handling (Fully Automated - No User Prompts)

### If tests fail:
1. Report failure summary in output
2. **Continue anyway** - mark PR as draft
3. Add warning to PR description:
   ```
   ⚠️ **WARNING: Tests Failing**
   This PR was auto-submitted with failing tests.
   Please review and fix before requesting merge.

   Test Failures: [X] examples failed
   ```
4. Tag PR with `tests-failing` label if possible
5. Complete submission

### If Rubocop has unfixable offenses:
1. Report offenses in output
2. **Continue anyway** - include in PR description
3. Add note to PR:
   ```
   ⚠️ **Note: Rubocop Offenses**
   [X] unfixable Rubocop offenses detected.
   Review required before merge.
   ```
4. Complete submission

### If already on main branch:
1. **Auto-create feature branch** from current changes
2. Use naming: `auto-submit/[timestamp]` (e.g., `auto-submit/2025-10-30-07-25`)
3. Checkout new branch
4. Continue with submission
5. Note in PR: "Auto-created from main branch"

### If no changes to commit:
1. Check if branch is ahead of main
2. If ahead, skip commit step, just push and create/update PR
3. If not ahead, report: "No changes to submit" and exit gracefully
4. Do NOT create empty PR

### If no remote branch exists:
1. **Auto-create** with `git push -u origin [branch-name]`
2. Continue with PR creation

### If PR already exists:
1. **Auto-update** PR body with latest changes
2. Add update timestamp to PR description
3. Report: "Updated existing PR #[number]"

### If database not running:
1. Report warning: "Database not running - tests skipped"
2. Add to PR description:
   ```
   ⚠️ **Tests Skipped**
   Database not available during submission.
   CI/CD will run full test suite.
   ```
3. **Continue** with submission (CI will test)

## Important Notes

- This is a **quick submit** workflow, not comprehensive validation
- Use `/pre-merge` before final merge for full Docker testing
- This command is designed for "save and go" workflow
- CI/CD will run comprehensive checks after submission
- All commits follow conventional commit format
- PRs are marked as auto-submitted in description

## Requirements

- Git repository with remote configured
- GitHub CLI (`gh`) authenticated
- Bundle installed locally
- Database services running (for tests)

## Safety Checks

- Never commit to main branch
- Never force push
- Always run tests before submitting
- Include test results in PR description
- Auto-mark PR as draft if tests fail

---

**Usage:** `/submit-pr`

**When to use:**
- End of work session (save progress)
- Need to step away but want PR submitted
- Quick iteration during development
- Auto-submit work-in-progress

**When NOT to use:**
- Ready for merge (use `/pre-merge` instead)
- Breaking changes without testing
- Incomplete features without clear TODO markers
