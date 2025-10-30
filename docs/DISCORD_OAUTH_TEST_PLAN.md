# Discord OAuth Authentication - Test Plan

**Epic:** 2.1 - Discord OAuth Authentication
**Version:** 1.0
**Date:** October 27, 2025

## Overview

This test plan validates the complete Discord OAuth authentication system for GuildHub.

---

## Prerequisites

### 1. Discord Application Setup

Before testing, ensure Discord application is configured:

```bash
# Check credentials are set
bin/rails credentials:show | grep discord

# Should show:
# discord:
#   client_id: "YOUR_CLIENT_ID"
#   client_secret: "YOUR_CLIENT_SECRET"
```

If not set, follow: `docs/DISCORD_SETUP.md`

### 2. Database Setup

```bash
# With Docker
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate

# Or locally
bin/rails db:create
bin/rails db:migrate
```

### 3. Docker Setup (If Using Docker)

```bash
# Stop existing containers
docker compose down

# Rebuild images (includes new code)
docker compose build

# Start containers
docker compose up -d

# Check logs
docker compose logs -f web

# Verify app is running
docker compose ps
```

---

## Quick Fix: Rails Splash Page Issue

If you see the default Rails splash page instead of the GuildHub home page:

### Option 1: Docker Rebuild (Recommended)

```bash
# Stop containers
docker compose down

# Rebuild images (includes all new files)
docker compose build --no-cache

# Start fresh
docker compose up -d

# Run migrations
docker compose exec web bin/rails db:migrate

# Check it's working
curl http://localhost:3000
# Should show HTML with "GuildHub" title
```

### Option 2: Verify Files in Container

```bash
# Check if files exist in container
docker compose exec web ls -la app/controllers/home_controller.rb
docker compose exec web ls -la app/views/home/index.html.erb

# Check routes in container
docker compose exec web bin/rails routes | grep root

# If files are missing, rebuild is required (Option 1)
```

### Option 3: Check Logs for Errors

```bash
# View real-time logs
docker compose logs -f web

# Look for errors like:
# - "uninitialized constant HomeController"
# - "Missing template home/index"
# - Database connection errors
```

---

## Test Environment Setup

### Development Server (Choose One)

**Option A: Docker**
```bash
docker compose up -d
# App at: http://localhost:3000
```

**Option B: Local**
```bash
bin/dev
# App at: http://localhost:3000
```

### Test Database

```bash
# Prepare test database
RAILS_ENV=test bin/rails db:create db:migrate

# Or with Docker
docker compose exec web bash -c "RAILS_ENV=test bin/rails db:create db:migrate"
```

---

## Test Suite Execution

### Automated Tests

Run all authentication-related tests:

```bash
# All tests
bundle exec rspec

# Specific test suites
bundle exec rspec spec/models/user_spec.rb                          # User model (30+ tests)
bundle exec rspec spec/config/discord_credentials_spec.rb          # Credentials validation
bundle exec rspec spec/config/omniauth_spec.rb                     # OmniAuth config
bundle exec rspec spec/requests/auth/callbacks_spec.rb             # OAuth callbacks (20+ tests)
bundle exec rspec spec/requests/sessions_spec.rb                   # Logout
bundle exec rspec spec/controllers/application_controller_spec.rb  # Auth helpers (20+ tests)
bundle exec rspec spec/system/discord_authentication_spec.rb       # End-to-end (12+ tests)

# With Docker
docker compose exec web bundle exec rspec spec/models/user_spec.rb
```

### Expected Results

All tests should pass:
- ✅ 82+ test cases
- ✅ 0 failures
- ✅ Green output

---

## Manual Test Plan

### Test Case 1: Home Page Loads

**Objective:** Verify home page displays correctly

**Steps:**
1. Open browser
2. Navigate to `http://localhost:3000`

**Expected Results:**
- ✅ Page loads without errors
- ✅ "GuildHub" heading visible
- ✅ "Project 1999 DKP Management" subtitle visible
- ✅ "Login with Discord" button visible (if not signed in)
- ✅ Discord logo (blurple icon) visible
- ✅ No Rails splash page
- ✅ EverQuest class colors displayed
- ✅ Feature cards displayed

**Verification:**
```bash
# Check page content
curl http://localhost:3000 | grep "GuildHub"
curl http://localhost:3000 | grep "Login with Discord"
```

---

### Test Case 2: Discord Login Button

**Objective:** Verify login button appears and is functional

**Prerequisites:** Not signed in

**Steps:**
1. Navigate to `http://localhost:3000`
2. Locate "Login with Discord" button
3. Verify button styling
4. Check button link

**Expected Results:**
- ✅ Button visible in hero section
- ✅ Discord logo (SVG) visible
- ✅ Button has Discord blurple color (#5865F2)
- ✅ Hover effect changes color and scales button
- ✅ Helper text: "Sign in with your Discord account to get started"
- ✅ Button links to `/auth/discord`

**Verification:**
```bash
# Check button exists
curl http://localhost:3000 | grep "/auth/discord"
curl http://localhost:3000 | grep "Login with Discord"
```

---

### Test Case 3: Discord OAuth Flow (Happy Path)

**Objective:** Complete successful Discord login

**Prerequisites:**
- Discord credentials configured
- Not signed in

**Steps:**
1. Navigate to `http://localhost:3000`
2. Click "Login with Discord" button
3. Should redirect to Discord authorization page
4. Click "Authorize" on Discord
5. Should redirect back to GuildHub

**Expected Results:**
- ✅ Redirects to Discord (discord.com/oauth2/authorize)
- ✅ Discord shows authorization screen with:
  - App name: "GuildHub" (or "GuildHub Dev")
  - Requested permissions: "Identify" and "Email"
- ✅ After clicking "Authorize":
  - Redirects to `http://localhost:3000/auth/discord/callback`
  - Then redirects to `http://localhost:3000/`
  - Shows success notice: "Successfully signed in with Discord!"
  - Login button replaced with user info card
  - User display name visible
  - Avatar visible (or placeholder)

**Verification:**
```bash
# Check user was created in database
docker compose exec web bin/rails console
> User.count
> User.last.attributes
```

---

### Test Case 4: User Info Display (Signed In)

**Objective:** Verify user information displays correctly after login

**Prerequisites:** User signed in

**Steps:**
1. Complete login (Test Case 3)
2. Observe user info card

**Expected Results:**
- ✅ User info card visible (white card with shadow)
- ✅ Discord avatar displayed (64x64 rounded)
- ✅ If no avatar: Placeholder with first letter of username
- ✅ Display name shown (e.g., "username#1234" or email)
- ✅ Logout button visible
- ✅ "Login with Discord" button NOT visible

**For Admin Users:**
- ✅ Gold "ADMIN" badge visible above display name

**Verification:**
```bash
# Check session is set
docker compose exec web bin/rails console
> user = User.last
> user.discord_username
> user.discord_avatar_url
> user.admin?
```

---

### Test Case 5: Logout Functionality

**Objective:** Verify logout works correctly

**Prerequisites:** User signed in

**Steps:**
1. Sign in (Test Case 3)
2. Click "Logout" button
3. Observe page after logout

**Expected Results:**
- ✅ Page reloads/redirects to home
- ✅ Success notice: "Successfully signed out"
- ✅ User info card disappears
- ✅ "Login with Discord" button reappears
- ✅ Session cleared (can verify in browser dev tools)

**Verification:**
```bash
# Check logout is logged
docker compose logs web | grep "logged out"
```

---

### Test Case 6: Return Path After Login

**Objective:** Verify users return to intended page after login

**Prerequisites:** Not signed in

**Steps:**
1. Navigate to `http://localhost:3000/characters` (protected page, will be added later)
2. Should redirect to home with "Please sign in to continue"
3. Click "Login with Discord"
4. Complete Discord authorization
5. Should redirect back to `/characters`

**Expected Results:**
- ✅ After login, redirected to `/characters` (not home)
- ✅ Session stores return path during redirect

**Note:** This test will work once protected routes are added in Epic 3.

---

### Test Case 7: OAuth Failure Handling

**Objective:** Verify app handles OAuth failures gracefully

**Prerequisites:** Discord app configured

**Test 7a: User Denies Authorization**

**Steps:**
1. Click "Login with Discord"
2. On Discord authorization page, click "Cancel"

**Expected Results:**
- ✅ Redirects to `http://localhost:3000/`
- ✅ Error notice: "Discord authentication failed: [error type]"
- ✅ Login button still visible
- ✅ No user created in database

**Test 7b: Invalid Credentials**

**Steps:**
1. Temporarily break Discord credentials
2. Click "Login with Discord"
3. Observe error

**Expected Results:**
- ✅ Shows error message
- ✅ Does not crash application
- ✅ Error logged in Rails logs

---

### Test Case 8: Existing User Login

**Objective:** Verify existing users can log in and data updates

**Prerequisites:** User already exists in database

**Steps:**
1. Create user manually or via previous login
2. Log out
3. Log in again with same Discord account
4. Verify user data updates (if Discord profile changed)

**Expected Results:**
- ✅ No new user created (same user_id)
- ✅ User record updated with latest Discord data
- ✅ Username updates if changed on Discord
- ✅ Avatar URL updates if changed on Discord
- ✅ Email updates if changed on Discord

**Verification:**
```bash
docker compose exec web bin/rails console
> User.count  # Should not increase
> User.last.updated_at  # Should be recent
```

---

### Test Case 9: Admin Badge Display

**Objective:** Verify admin badge shows for admin users only

**Prerequisites:** Test users created

**Test 9a: Regular User**

**Steps:**
1. Create regular user (admin: false)
2. Sign in
3. Check user card

**Expected Results:**
- ✅ No "ADMIN" badge visible
- ✅ Only display name and avatar shown

**Test 9b: Admin User**

**Steps:**
1. Create admin user:
   ```bash
   docker compose exec web bin/rails console
   > user = User.last
   > user.update(admin: true)
   > exit
   ```
2. Sign in as admin user
3. Check user card

**Expected Results:**
- ✅ Gold "ADMIN" badge visible
- ✅ Badge appears below display name

---

### Test Case 10: Avatar Display

**Objective:** Verify avatar handling (with and without image)

**Test 10a: User With Avatar**

**Prerequisites:** User has Discord avatar

**Steps:**
1. Sign in with Discord account that has avatar
2. Check user card

**Expected Results:**
- ✅ Discord avatar image displayed (64x64)
- ✅ Image is rounded (circular)
- ✅ Image loads successfully (no broken image icon)

**Test 10b: User Without Avatar**

**Prerequisites:** User has no Discord avatar

**Steps:**
1. Remove avatar URL from user:
   ```bash
   docker compose exec web bin/rails console
   > User.last.update(discord_avatar_url: nil)
   ```
2. Refresh page

**Expected Results:**
- ✅ Placeholder shown (colored circle)
- ✅ First letter of username displayed in placeholder
- ✅ Letter is capitalized
- ✅ Background color: EverQuest blue

---

### Test Case 11: Session Persistence

**Objective:** Verify session persists across page reloads

**Prerequisites:** User signed in

**Steps:**
1. Sign in via Discord
2. Refresh page (F5)
3. Navigate to different page (if available)
4. Close and reopen browser tab
5. Visit site again

**Expected Results:**
- ✅ User remains signed in after refresh
- ✅ User info card still visible
- ✅ Session persists across different pages
- ✅ Session persists after closing/reopening tab (if cookies enabled)

---

### Test Case 12: Responsive Design

**Objective:** Verify UI works on different screen sizes

**Steps:**
1. Open site on desktop browser
2. Open browser dev tools (F12)
3. Toggle device toolbar (responsive design mode)
4. Test on different screen sizes:
   - Mobile (375px width)
   - Tablet (768px width)
   - Desktop (1920px width)

**Expected Results:**
- ✅ Login button readable on mobile
- ✅ User card fits on mobile screen
- ✅ Logout button accessible on mobile
- ✅ No horizontal scrolling
- ✅ Text remains readable at all sizes
- ✅ Touch targets large enough on mobile (48px minimum)

---

### Test Case 13: Browser Compatibility

**Objective:** Verify works across modern browsers

**Browsers to Test:**
- Chrome/Chromium (latest)
- Firefox (latest)
- Safari (latest, macOS)
- Edge (latest)

**Steps:**
1. Open site in each browser
2. Complete login flow
3. Test logout
4. Verify UI displays correctly

**Expected Results:**
- ✅ Works in all modern browsers
- ✅ OAuth flow completes successfully
- ✅ Styling consistent across browsers
- ✅ No console errors

---

### Test Case 14: Security Validation

**Objective:** Verify security measures are in place

**Test 14a: CSRF Protection**

**Steps:**
1. Attempt to POST to `/logout` without CSRF token

**Expected Results:**
- ✅ Request blocked or requires valid token
- ✅ No session cleared without token

**Test 14b: Session Security**

**Steps:**
1. Sign in
2. Copy session cookie
3. Clear browser data
4. Manually set old session cookie
5. Refresh page

**Expected Results:**
- ✅ Session validation works
- ✅ Expired/invalid sessions rejected

**Test 14c: SQL Injection Prevention**

**Steps:**
1. Attempt to sign in with SQL injection in username field (via manipulated OAuth response)

**Expected Results:**
- ✅ No SQL injection possible
- ✅ Input sanitized/parameterized

---

### Test Case 15: Error Messages

**Objective:** Verify user-friendly error messages

**Test Scenarios:**

**15a: Network Error During OAuth**
- ✅ Shows: "An error occurred during sign in. Please try again."
- ✅ Logs error details

**15b: Discord API Unavailable**
- ✅ Shows: "Discord authentication failed"
- ✅ User can retry

**15c: Invalid OAuth Response**
- ✅ Shows: "Authentication failed: No data received from Discord."
- ✅ Does not crash application

---

## Performance Tests

### Test Case 16: Page Load Performance

**Objective:** Verify pages load quickly

**Steps:**
1. Clear browser cache
2. Navigate to `http://localhost:3000`
3. Measure page load time (Network tab in dev tools)

**Expected Results:**
- ✅ Initial page load < 3 seconds
- ✅ No blocking resources
- ✅ Tailwind CSS loads efficiently

### Test Case 17: OAuth Callback Performance

**Objective:** Verify OAuth callback is fast

**Steps:**
1. Complete login flow
2. Measure time from Discord redirect to home page load

**Expected Results:**
- ✅ Callback processes < 1 second
- ✅ User creation/update efficient
- ✅ No N+1 queries

---

## Logs and Debugging

### Check Application Logs

```bash
# View logs (Docker)
docker compose logs -f web

# Look for:
# - "User authenticated via Discord: username#1234 (ID: 1)"
# - "User logged out: username#1234 (ID: 1)"
# - Any error messages
```

### Check Database

```bash
# Enter Rails console
docker compose exec web bin/rails console

# Check users created
> User.count
> User.all.pluck(:discord_username, :email, :admin)

# Check specific user
> user = User.last
> user.attributes
> user.admin?
> user.discord_avatar(size: 256)

# Clear test data
> User.destroy_all
```

### Check Routes

```bash
# List all routes
docker compose exec web bin/rails routes

# Check auth routes specifically
docker compose exec web bin/rails routes | grep auth
docker compose exec web bin/rails routes | grep logout
```

---

## Troubleshooting Guide

### Issue: Rails Splash Page Shows

**Symptoms:** Default Rails welcome page instead of GuildHub home page

**Solutions:**

1. **Rebuild Docker containers:**
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

2. **Check files exist in container:**
   ```bash
   docker compose exec web ls -la app/controllers/home_controller.rb
   docker compose exec web ls -la app/views/home/index.html.erb
   ```

3. **Check routes:**
   ```bash
   docker compose exec web bin/rails routes | grep root
   # Should show: root GET / home#index
   ```

4. **Check for errors:**
   ```bash
   docker compose logs web | tail -50
   ```

### Issue: "Uninitialized constant HomeController"

**Solution:**
```bash
# HomeController not loaded in container
# Rebuild Docker images
docker compose down
docker compose build
docker compose up -d
```

### Issue: "Missing template home/index"

**Solution:**
```bash
# View file not in container
# Rebuild Docker images
docker compose down
docker compose build
docker compose up -d
```

### Issue: "Discord OAuth not working"

**Symptoms:** Redirect to Discord fails or shows error

**Solutions:**

1. **Check credentials:**
   ```bash
   docker compose exec web bin/rails credentials:show | grep discord
   ```

2. **Check redirect URI matches:**
   - Discord app: `http://localhost:3000/auth/discord/callback`
   - OmniAuth config: `callback_path: "/auth/discord/callback"`

3. **Check OmniAuth initializer loaded:**
   ```bash
   docker compose exec web ls -la config/initializers/omniauth.rb
   ```

### Issue: "Database connection error"

**Solution:**
```bash
# Create and migrate database
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate

# Check database.yml
docker compose exec web cat config/database.yml
```

### Issue: "Logout button doesn't work"

**Solutions:**

1. **Check route exists:**
   ```bash
   docker compose exec web bin/rails routes | grep logout
   # Should show: logout DELETE /logout sessions#destroy
   ```

2. **Check Turbo configuration:**
   - Logout button should use `method: :delete`
   - May need `data: { turbo: false }` attribute

3. **Check logs for errors:**
   ```bash
   docker compose logs web | grep logout
   ```

---

## Test Results Template

Use this template to record test results:

```
# Discord OAuth Test Results
Date: _____________
Tester: _____________
Environment: [ ] Docker [ ] Local

## Automated Tests
[ ] User model tests (30+ cases) - PASS / FAIL
[ ] OAuth callback tests (20+ cases) - PASS / FAIL
[ ] Auth helper tests (20+ cases) - PASS / FAIL
[ ] System tests (12+ cases) - PASS / FAIL

## Manual Tests
[ ] Test Case 1: Home page loads - PASS / FAIL
[ ] Test Case 2: Login button displays - PASS / FAIL
[ ] Test Case 3: OAuth flow completes - PASS / FAIL
[ ] Test Case 4: User info displays - PASS / FAIL
[ ] Test Case 5: Logout works - PASS / FAIL
[ ] Test Case 6: Return path works - PASS / FAIL
[ ] Test Case 7: Error handling works - PASS / FAIL
[ ] Test Case 8: Existing user login - PASS / FAIL
[ ] Test Case 9: Admin badge displays - PASS / FAIL
[ ] Test Case 10: Avatar handling - PASS / FAIL
[ ] Test Case 11: Session persistence - PASS / FAIL
[ ] Test Case 12: Responsive design - PASS / FAIL
[ ] Test Case 13: Browser compatibility - PASS / FAIL
[ ] Test Case 14: Security validation - PASS / FAIL
[ ] Test Case 15: Error messages - PASS / FAIL
[ ] Test Case 16: Page performance - PASS / FAIL
[ ] Test Case 17: OAuth performance - PASS / FAIL

## Issues Found
1. _____________
2. _____________

## Overall Result
[ ] PASS - Ready for production
[ ] FAIL - Issues need resolution
```

---

## Success Criteria

All tests must pass before Epic 2.1 is considered complete:

- ✅ All automated tests pass (82+ cases)
- ✅ All critical manual tests pass (Cases 1-5)
- ✅ No security vulnerabilities found (Case 14)
- ✅ Performance acceptable (Cases 16-17)
- ✅ Works in all target browsers (Case 13)
- ✅ Responsive design works (Case 12)

---

## Next Steps After Testing

1. **If tests pass:**
   - Create Pull Request
   - Request code review
   - Merge to main branch
   - Move to Epic 2.2

2. **If tests fail:**
   - Document issues
   - Fix identified problems
   - Re-run failed tests
   - Update documentation if needed

---

**Test Plan Version:** 1.0
**Last Updated:** October 27, 2025
**Status:** Ready for execution
