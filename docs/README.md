# GuildHub Planning Documentation

This directory contains all planning and design documentation for the GuildHub project.

## 📋 Table of Contents

### Core Planning Documents

1. **[PRD-GuildHub-RailsVersion.md](PRD-GuildHub-RailsVersion.md)**
   - Product Requirements Document
   - Features, scope, and objectives
   - User stories and use cases
   - Success metrics and KPIs
   - **Read this first** to understand what we're building and why

2. **[ERD-GuildHub-P99.md](ERD-GuildHub-P99.md)**
   - Entity Relationship Diagram
   - Complete database schema (10 core tables)
   - Relationships and indexes
   - P99 EverQuest-specific data structures
   - **Reference this** when implementing models

3. **[ModernArchitecture.md](ModernArchitecture.md)**
   - Technical architecture overview
   - Technology stack decisions
   - Design patterns and conventions
   - Performance considerations
   - **Reference this** for architectural decisions

4. **[ImplementationRoadmap.md](ImplementationRoadmap.md)**
   - 8-month development timeline
   - 4 phases, 16 sprints
   - Epic dependencies
   - Risk assessment
   - **Reference this** for project planning

5. **[TASKS.md](TASKS.md)**
   - Complete task breakdown
   - 177 individual tasks across 14 epics
   - Story point estimates
   - Acceptance criteria for each task
   - **Use this** to understand detailed implementation steps

6. **[MigrationStrategy.md](MigrationStrategy.md)**
   - EQdkpPlus to GuildHub migration plan
   - Data transformation approach
   - Validation and testing strategy
   - **Reference this** when building Epic 12 (Migration Tool)

## 🎯 Quick Reference

### For Developers

**Starting a new epic?** Read:
1. The corresponding epic section in `TASKS.md`
2. Related models in `ERD-GuildHub-P99.md`
3. Architecture patterns in `ModernArchitecture.md`

**Implementing a specific task?**
1. Find the task in `TASKS.md` (e.g., T1.1.1)
2. Check the corresponding GitHub issue (#15-#191)
3. Review acceptance criteria
4. Reference `../CLAUDE.md` for Rails patterns

**Need context on a decision?**
1. Check `ModernArchitecture.md` for technical rationale
2. Check `PRD-GuildHub-RailsVersion.md` for product rationale

### For Project Managers

**Planning next sprint?**
- Use `ImplementationRoadmap.md` for timeline
- Check `TASKS.md` for story points
- Review GitHub Milestones for progress

**Estimating completion?**
- Current velocity: 20-25 SP per 2-week sprint (1-2 devs)
- Total remaining: See GitHub Issues
- Timeline: See `ImplementationRoadmap.md`

## 📊 Document Overview

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **PRD** | What we're building | Before starting project |
| **ERD** | Database structure | When implementing models |
| **Architecture** | How we're building it | When making tech decisions |
| **Roadmap** | When features are delivered | Sprint planning |
| **TASKS** | Detailed implementation steps | Daily development |
| **Migration** | EQdkpPlus import process | Epic 12 implementation |

## 🔄 Document Versions

All documents are **v2.0** (P99-Focused):
- Removed multi-game support
- Removed calendar/signups
- Removed plugin/theme systems
- Single DKP pool only
- Discord-first authentication

Original v1.0 documents (EQdkpPlus general) are archived in `/Users/casey/Desktop/GuildHub-Rails/EQDKP/`.

## 📝 Document Standards

### Mermaid Diagrams
All documents use Mermaid.js for diagrams (ERDs, Gantt charts, flowcharts). These render automatically in GitHub.

### Task IDs
Tasks follow the pattern: `T[Epic].[Section].[Task]`
- Example: `T1.1.1` = Epic 1, Section 1, Task 1
- Maps to GitHub Issues #15-#191

### Story Points
- 1 SP = 1-2 hours
- 2 SP = 2-4 hours
- 3 SP = 4-8 hours
- 5 SP = 1-2 days
- 8 SP = 2-4 days
- 13 SP = 1 week
- 21 SP = 2 weeks

### Acceptance Criteria
All tasks include clear acceptance criteria:
- ✅ checkboxes for verification
- Specific, measurable outcomes
- Test requirements

## 🔗 Related Resources

### In Repository
- `/CLAUDE.md` - AI assistant development guide
- `/README.md` - Project overview and setup
- GitHub Issues - All 191 tracked issues
- GitHub Milestones - 4 phase milestones

### External
- [Rails 8 Guides](https://guides.rubyonrails.org)
- [Project 1999 Website](http://www.project1999.com)
- [EQdkpPlus (Archived)](https://github.com/EQdkpPlus/core)

## 🛠️ Using These Documents

### For Epic Implementation

When starting an epic (e.g., Epic 1: Infrastructure):

```bash
# 1. Read epic overview in TASKS.md
cat docs/TASKS.md | grep -A 50 "Epic 1:"

# 2. Check database requirements in ERD
cat docs/ERD-GuildHub-P99.md | grep -A 20 "users table"

# 3. Review architecture patterns
cat docs/ModernArchitecture.md | grep -A 10 "Authentication"

# 4. Create branch for first task
git checkout -b task/T1.1.1-rails-init

# 5. Reference CLAUDE.md for patterns
cat CLAUDE.md | grep -A 10 "Rails 8 Conventions"
```

### For Code Review

Reviewers should reference:
- Task acceptance criteria in `TASKS.md`
- Architecture patterns in `ModernArchitecture.md`
- Database schema in `ERD-GuildHub-P99.md`
- Rails patterns in `../CLAUDE.md`

## 📅 Document Maintenance

**When to Update:**
- After major architectural changes
- After completing a phase (retrospective)
- When scope changes
- When technical decisions are made

**Who Updates:**
- **PRD:** Product owner
- **ERD:** Backend developers
- **Architecture:** Tech lead
- **Roadmap:** Project manager
- **TASKS:** Development team
- **Migration:** Backend developers

**Version Control:**
- All changes committed to git
- Document version number in header
- Last updated date in header

## 🎓 Learning Path

### New to the Project?

Read in this order:
1. `../README.md` - Project overview
2. `PRD-GuildHub-RailsVersion.md` - What we're building
3. `ERD-GuildHub-P99.md` - Database structure
4. `ModernArchitecture.md` - How we're building it
5. `TASKS.md` - Pick your first task
6. `../CLAUDE.md` - Development patterns

### Experienced with Rails?

Focus on:
1. `ERD-GuildHub-P99.md` - P99-specific data model
2. `ModernArchitecture.md` - Our architectural choices
3. `TASKS.md` - Implementation tasks

### Product/Design Focus?

Read:
1. `PRD-GuildHub-RailsVersion.md` - Features and scope
2. `ImplementationRoadmap.md` - Timeline
3. GitHub Milestones - Progress tracking

---

**Last Updated:** October 21, 2025
**Document Set Version:** 2.0 (P99-Focused)
**Total Pages:** ~250 pages of planning documentation
