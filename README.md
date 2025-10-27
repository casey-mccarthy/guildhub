# GuildHub

> Modern DKP management system for Project 1999 EverQuest guilds

[![Ruby](https://img.shields.io/badge/Ruby-3.3+-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0+-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

GuildHub is a modern Ruby on Rails application designed to replace the archived EQdkpPlus PHP system. Built exclusively for **Project 1999 EverQuest guilds**, it provides a streamlined, maintainable DKP (Dragon Kill Points) management system with Discord integration.

## ✨ Features

### Core DKP Management
- **Raid Attendance Tracking** - Track who attended which raids
- **Item Award System** - Record loot distribution and DKP spending
- **DKP Calculations** - Real-time balance calculations with caching
- **Manual Adjustments** - Officer tools for DKP corrections
- **Audit Trail** - Complete history of all DKP changes

### P99 EverQuest Optimized
- **14 EverQuest Classes** - Warrior, Cleric, Wizard, etc.
- **12 EverQuest Races** - Human, Elf, Dwarf, etc.
- **Level 1-60** - Classic EverQuest level cap
- **P99 Servers** - Blue (Velious) and Green (Kunark)
- **Common Raid Targets** - PoF, PoH, PoSky, Nagafen, Vox, etc.

### Modern Stack
- **Discord OAuth** - Primary authentication (no passwords for members)
- **Admin Panel** - Devise authentication for officers
- **Real-time Updates** - Hotwire (Turbo + Stimulus)
- **Responsive UI** - Tailwind CSS 4.0+
- **Background Jobs** - Solid Queue (Rails 8 built-in)
- **Discord Bot** - Optional slash commands and webhooks

### Migration Tools
- **EQdkpPlus Importer** - Migrate from legacy PHP system
- **Data Validation** - Ensure DKP balances match after import
- **Rollback Safety** - Transaction-based import process

## 📋 Project Status

**Phase:** Pre-development (Planning Complete)
**Timeline:** 8 months (16 two-week sprints)
**Story Points:** 186 total
**GitHub Issues:** 191 (14 epics + 177 tasks)

### Milestones

- **Phase 1: Foundation** (2 months) - Rails setup, auth, guild/character management
- **Phase 2: Core DKP** (2 months) - Raids, attendance, items, adjustments
- **Phase 3: Polish** (2 months) - Dashboard, Discord bot, analytics
- **Phase 4: Launch** (2 months) - Migration tool, docs, testing

## 📚 Documentation

All planning documentation is in the [`/docs`](docs/) directory:

| Document | Description |
|----------|-------------|
| [**DEVELOPMENT.md**](DEVELOPMENT.md) | Daily development guide - running server, testing, debugging |
| [**PRD**](docs/PRD-GuildHub-RailsVersion.md) | Product Requirements Document - features and scope |
| [**ERD**](docs/ERD-GuildHub-P99.md) | Entity Relationship Diagram - complete database schema |
| [**Architecture**](docs/ModernArchitecture.md) | Technical architecture and design decisions |
| [**Roadmap**](docs/ImplementationRoadmap.md) | 8-month development timeline and milestones |
| [**Tasks**](docs/TASKS.md) | All 177 implementation tasks with estimates |
| [**Migration**](docs/MigrationStrategy.md) | EQdkpPlus migration strategy |
| [**CLAUDE.md**](CLAUDE.md) | AI assistant development guide (patterns, conventions) |

## 🚀 Quick Start

### Prerequisites

- **Ruby** 3.3 or higher
- **Rails** 8.0 or higher
- **PostgreSQL** 16 or higher
- **Redis** 7 or higher
- **Node.js** 18+ (for esbuild)

### Installation

```bash
# Clone the repository
git clone https://github.com/casey-mccarthy/guildhub.git
cd guildhub

# Run setup script
bin/setup

# Start development server
bin/dev
```

The application will be available at `http://localhost:3000`.

### Docker Setup

```bash
# Build and run with Docker Compose
docker-compose up

# Run migrations
docker-compose exec web bin/rails db:migrate

# Seed data
docker-compose exec web bin/rails db:seed
```

## 🛠️ Development

### Running Tests

```bash
# Run all tests
bin/test

# Or use RSpec directly
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation
```

### Code Quality

```bash
# Run Rubocop (linter)
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Security scan
bundle exec brakeman

# Dependency audit
bundle exec bundle-audit
```

### Database

```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Seed sample data
bin/rails db:seed

# Reset database (drop, create, migrate, seed)
bin/rails db:reset
```

## 📊 Tech Stack

### Backend
- **Ruby** 3.3+ - Programming language
- **Rails** 8.0+ - Web framework
- **PostgreSQL** 16+ - Primary database
- **Redis** 7+ - Caching and ActionCable
- **Solid Queue** - Background jobs (Rails 8 built-in)

### Frontend
- **Hotwire** - Turbo + Stimulus for reactivity
- **Tailwind CSS** 4.0+ - Utility-first CSS
- **esbuild** - JavaScript bundling
- **ViewComponent** 3+ - Reusable UI components

### Authentication & Authorization
- **OmniAuth Discord** - Discord OAuth for members
- **Devise** - Email/password for admin panel
- **Pundit** - Policy-based authorization

### Testing & Quality
- **RSpec** - Testing framework
- **FactoryBot** - Test fixtures
- **Capybara** - System tests
- **SimpleCov** - Code coverage
- **Rubocop** - Linting
- **Brakeman** - Security scanning

### Integrations
- **Discord.rb** - Discord bot (optional)
- **PaperTrail** - Audit trail
- **Chart.js** 4+ - Analytics visualizations

## 🏗️ Architecture

### Database Schema (10 core tables)

```
users ─┐
       ├──> characters ──> guilds
       │         │
       │         ├──> raid_attendances ──> raids ──> event_types
       │         │
       │         ├──> item_awards ──> raids
       │         │
       │         └──> dkp_adjustments ──> guilds
       │
       └──> announcements ──> guilds
```

### Key Design Decisions

**Single DKP Pool:**
- Simplified from EQdkpPlus multi-pool complexity
- Configured via `guilds.dkp_config` JSONB field

**Calculated DKP Balances:**
- NOT stored in database
- Formula: `earned - spent + adjustments`
- Cached in Redis (5 min TTL)

**Discord-First:**
- Members log in via Discord OAuth
- No password management for regular users
- Officers use Devise for admin panel

**No Calendar/Signups:**
- P99 guilds use Discord for scheduling
- GuildHub tracks attendance AFTER raids

## 📝 GitHub Issues

All work is tracked in GitHub Issues:

- **Epic Issues:** [#1-#14](https://github.com/casey-mccarthy/guildhub/issues) - High-level features
- **Task Issues:** [#15-#191](https://github.com/casey-mccarthy/guildhub/issues) - Individual implementation tasks
- **Milestones:** [4 phases](https://github.com/casey-mccarthy/guildhub/milestones) - Timeline tracking
- **Labels:** Epic, type, story points, priority, phase

### Issue Breakdown by Phase

| Phase | Epics | Tasks | Story Points |
|-------|-------|-------|--------------|
| **1: Foundation** | E1-E3 | 55 | 55 SP |
| **2: Core DKP** | E4-E7 | 43 | 47 SP |
| **3: Polish** | E8-E11 | 40 | 42 SP |
| **4: Launch** | E12-E14 | 39 | 42 SP |
| **Total** | **14** | **177** | **186 SP** |

## 🎯 Project Goals

### Primary Objectives
1. ✅ **Replace EQdkpPlus** - Modern Rails alternative to archived PHP app
2. ✅ **P99-Specific** - Optimized for Project 1999 EverQuest guilds
3. ✅ **Simplified DKP** - Single pool, calculated balances
4. ✅ **Discord Integration** - OAuth auth + optional bot
5. ✅ **Migration Path** - Import tool for existing EQdkpPlus guilds

### Success Metrics
- **30 P99 Guilds** - Target adoption (realistic for P99 community)
- **>90% Test Coverage** - Maintain high code quality
- **<300ms Response Time** - Fast page loads
- **100% DKP Accuracy** - Perfect migration from EQdkpPlus

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow

1. **Pick a Task** - Choose from [GitHub Issues](https://github.com/casey-mccarthy/guildhub/issues)
2. **Create Branch** - `git checkout -b task/T1.1.1-description`
3. **Write Tests** - TDD approach preferred
4. **Implement Feature** - Follow acceptance criteria
5. **Run Tests** - `bin/test` must pass
6. **Run Linter** - `bundle exec rubocop -a`
7. **Commit** - Reference issue number
8. **Push & PR** - Create pull request
9. **Review** - Address feedback
10. **Merge** - Squash and merge when approved

## 📖 Learning Resources

- [Rails 8 Guides](https://guides.rubyonrails.org)
- [Hotwire Documentation](https://hotwired.dev)
- [Tailwind CSS](https://tailwindcss.com)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [RSpec Rails](https://github.com/rspec/rspec-rails)

## 🔗 Links

- **GitHub Repository:** https://github.com/casey-mccarthy/guildhub
- **Issues:** https://github.com/casey-mccarthy/guildhub/issues
- **Milestones:** https://github.com/casey-mccarthy/guildhub/milestones
- **Project 1999:** http://www.project1999.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **EQdkpPlus** - Original PHP DKP system (now archived)
- **Project 1999** - Classic EverQuest community
- **Rails Core Team** - For Rails 8 and Hotwire
- **P99 Guild Leaders** - Feedback and feature requests

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/casey-mccarthy/guildhub/issues)
- **Discussions:** [GitHub Discussions](https://github.com/casey-mccarthy/guildhub/discussions)
- **Discord:** Coming soon

---

**Built with ❤️ for the Project 1999 EverQuest community**

*Last Updated: October 21, 2025*
