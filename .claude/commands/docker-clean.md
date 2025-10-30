# Description: Clean up Docker resources and reset environment

You are helping clean up Docker resources and reset the development environment.

## Steps

1. **Stop All Services**
   ```bash
   docker compose down
   ```

2. **Remove Volumes (if requested)**
   - Ask user: "Do you want to remove volumes (deletes database data)? (y/n)"
   - If yes:
   ```bash
   docker compose down -v
   ```

3. **Clean Up Docker System**
   ```bash
   docker system prune -f
   ```

4. **Remove Dangling Images**
   ```bash
   docker image prune -f
   ```

5. **Show Disk Space Freed**
   ```bash
   docker system df
   ```

6. **Restart Services (if user wants)**
   - Ask user: "Restart services now? (y/n)"
   - If yes:
   ```bash
   docker compose up -d db redis
   ```

## Report

Show user:
- Containers stopped: X
- Volumes removed: Y (if applicable)
- Disk space freed: Z GB
- Services status after cleanup

**Usage:** `/docker-clean`

Use this when you need to:
- Free up disk space
- Reset database to clean state
- Fix Docker-related issues
- Start fresh
