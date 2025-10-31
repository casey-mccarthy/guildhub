# Description: Check PR status and CI/CD results

You are helping check the status of a Pull Request and its CI/CD checks.

## Steps

1. **Find Current Branch PR**
   ```bash
   gh pr list --head $(git branch --show-current) --json number,title,url,state
   ```

2. **Show PR Checks Status**
   ```bash
   gh pr checks $(gh pr list --head $(git branch --show-current) --json number --jq '.[0].number')
   ```

3. **Show Detailed CI Logs if Failed**
   - If any checks failed, ask user if they want to see logs
   - If yes, fetch failed run logs:
   ```bash
   gh run view [RUN-ID] --log-failed
   ```

4. **Provide Summary**
   - ✅ Passing checks (green)
   - ❌ Failing checks (red)
   - ⏳ Pending checks (yellow)
   - Total: X/Y passing

5. **Next Actions**
   - If all passing: "Ready to merge! ✅"
   - If failing: "Fix required issues"
   - If pending: "Wait for checks to complete"

**Usage:** `/pr-status`
