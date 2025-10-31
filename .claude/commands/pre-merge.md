# Description: Complete pre-merge validation and PR submission workflow

You are helping complete a comprehensive pre-merge workflow for a Rails 8 application. Follow these steps in order, stopping immediately if any step fails:

## Step 1: Pre-Commit Tests (Local)

Run all required checks locally:

1. **Rubocop (Linter)**
   - Run: `bundle exec rubocop -a`
   - Auto-fix all issues possible
   - If unfixable issues remain, report them and ask for guidance

2. **Brakeman (Security)**
   - Run: `bundle exec brakeman`
   - Report any security issues found
   - Ask user if they want to proceed with warnings

3. **Bundle Audit (Dependencies)**
   - Run: `bundle exec bundle-audit`
   - Report vulnerable dependencies
   - Ask user if they want to proceed with vulnerabilities

## Step 2: Docker Compose Tests

Test the full application in Docker environment:

1. **Build and Start Services**
   ```bash
   docker compose build
   docker compose up -d db redis
   sleep 10  # Wait for services to be healthy
   ```

2. **Database Setup in Docker**
   ```bash
   docker compose exec -T web bin/rails db:create RAILS_ENV=test
   docker compose exec -T web bin/rails db:migrate RAILS_ENV=test
   ```

3. **Run Tests in Docker**
   ```bash
   docker compose exec -T web bundle exec rspec --format documentation
   ```
   - ALL tests must pass
   - If any fail, show the failures and STOP
   - Do NOT proceed if tests fail

4. **Verify App Boots**
   ```bash
   docker compose up -d web
   sleep 15
   curl -f http://localhost:3000/up || echo "App failed health check"
   ```

## Step 3: Commit Changes (if any fixes were made)

If Rubocop or other tools made changes:

1. Stage changes: `git add -A`
2. Create commit with clear message:
   ```
   chore: pre-merge fixes from automated checks

   - Auto-fixed Rubocop offenses
   - Resolved [other issues]

   All checks passing:
   ✅ Rubocop
   ✅ Brakeman
   ✅ Bundle Audit
   ✅ RSpec (Docker)
   ✅ Health Check
   ```

## Step 4: Generate PR Summary

Analyze the branch changes and create a comprehensive PR description:

1. **Check what's changed:**
   ```bash
   git diff main...HEAD --stat
   git log main..HEAD --oneline
   ```

2. **Generate PR body** with:
   - Summary of changes (bullet points)
   - Related issue numbers (search for `[T` or `#` in commits)
   - Test results summary
   - Breaking changes (if any)
   - Migration info (if db/migrate has changes)
   - Screenshots/demos needed (mention if UI changes)

## Step 5: Create or Update PR

1. **Check if PR exists:**
   ```bash
   gh pr list --head $(git branch --show-current)
   ```

2. **Create new PR if none exists:**
   ```bash
   gh pr create --title "[Generated Title]" --body "[Generated Body]"
   ```

3. **Update existing PR if found:**
   ```bash
   gh pr edit [PR-NUMBER] --body "[Updated Body with test results]"
   ```

## Step 6: Final Report

Provide user with:

1. ✅ All checks passed status
2. PR number and URL
3. CI/CD status check command: `gh pr checks [PR-NUMBER]`
4. Next steps:
   - Wait for CI/CD to pass
   - Request review if needed
   - Merge when approved

## Error Handling

If ANY step fails:
1. STOP immediately
2. Report the failure clearly
3. Show the error output
4. Provide suggestions to fix
5. Ask user if they want to continue or abort

## Important Notes

- Follow the project's CLAUDE.md guidelines
- Use conventional commit format
- Reference issue numbers in commits
- All tests MUST pass before creating/updating PR
- Never force push or skip checks
- Clean up Docker resources when done: `docker compose down`

---

**Usage:** `/pre-merge`

This command ensures your changes are production-ready before merging.
