# Description: Quick local test run (no Docker, faster iteration)

You are helping run a quick validation of changes without the full Docker setup. This is useful for rapid iteration during development.

## Steps

1. **Run Rubocop (auto-fix)**
   ```bash
   bundle exec rubocop -a
   ```
   - Report any unfixable issues

2. **Run Tests Locally**
   ```bash
   DATABASE_HOST=localhost bundle exec rspec --format progress
   ```
   - If tests fail, show failures
   - Do NOT proceed if failures

3. **Report Results**
   - Show test count: X examples, Y failures
   - Show coverage percentage
   - List any pending tests

## Notes

- This runs tests against localhost database (requires Docker services running)
- Faster than full Docker test suite
- Use this during development
- Use `/pre-merge` before submitting PR

**Usage:** `/quick-test`
