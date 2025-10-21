# Product Requirements Document (PRD)
## GuildHub - Project 1999 EverQuest Guild Management
### Ruby on Rails Implementation

**Project Name:** GuildHub (Modern DKP System for Project 1999 EverQuest)
**Version:** 2.0 (P99-Focused)
**Date:** October 19, 2025
**Status:** Planning Complete
**Target Game:** Project 1999 EverQuest (Classic EQ)
**Target Launch:** June 2026
**License:** GNU Affero General Public License v3

---

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Project Vision & Goals](#project-vision--goals)
3. [Why Ruby on Rails?](#why-ruby-on-rails)
4. [Core Features & Requirements](#core-features--requirements)
5. [Modern Enhancements](#modern-enhancements)
6. [Technical Requirements](#technical-requirements)
7. [Success Metrics](#success-metrics)
8. [Project Phases](#project-phases)

---

## 1. Executive Summary

### 1.1 Problem Statement

EQdkpPlus, a widely-used guild management system for MMORPG communities, has been **archived and is no longer maintained**. The **Project 1999 EverQuest community** has particularly relied on EQdkpPlus for managing classic EverQuest guilds, but faces challenges:

**Current Pain Points:**
- EQdkpPlus is no longer maintained (archived 2021)
- Built on aging PHP technology (5.6-7.4)
- Generic multi-game design adds unnecessary complexity
- Lacks modern features (mobile optimization, real-time updates, Discord integration)
- Difficult to customize for classic EQ-specific needs
- Security vulnerabilities with no patches

**Project 1999 guilds need:**
- Modern, maintained DKP tracking system
- Classic EverQuest-specific features (classes, races, zones, items)
- Mobile-friendly interface for raid signups
- Discord integration for notifications
- Real-time raid tracking
- Familiar DKP workflows (fixed-price, zero-sum, etc.)

**The P99 community needs a modern, actively maintained solution optimized specifically for classic EverQuest mechanics and workflows.**

### 1.2 Solution Overview

**GuildHub** is a modern guild management system built specifically for **Project 1999 EverQuest**, using Ruby on Rails 8.x:

✅ **Classic EQ Optimized** - Built for P99 classes, races, zones, and items
✅ **100% Core DKP Features** - All essential DKP tracking capabilities
✅ **Data Migration Tools** - Import from EQdkpPlus seamlessly
✅ **Modern Technology** - Rails 8.x, mobile-first, real-time updates
✅ **Discord Integration** - Native Discord bot and notifications
✅ **P99 Item Database** - Integration with classic EQ item data
✅ **Active Development** - Maintained by the P99 community
✅ **Self-Hosted or Cloud** - Deploy anywhere (Docker, cloud platforms)

### 1.3 Target Audience

**Primary Users:**
- **Project 1999 EverQuest guilds** (Green, Blue, Red servers)
- Guild leaders and officers managing classic EQ raids
- Raid leaders coordinating 40-72 person raids
- DKP masters tracking points across multiple pools
- Guild members checking standings and signing up for raids

**Secondary Users:**
- Other classic EverQuest emulator guilds
- EQEmu server guilds
- Future: Other classic EverQuest projects

**Geographic Focus:** Global (English primary, multi-language future)

**Community Size:**
- 50+ active P99 raiding guilds estimated
- 5,000+ active P99 players
- Target: 30+ guilds in first year

---

## 2. Project Vision & Goals

### 2.1 Vision Statement

> "To provide Project 1999 EverQuest guilds with a simple, modern DKP tracking system that integrates seamlessly with Discord and maintains the essential workflows guilds rely on."

### 2.2 Project Goals

#### Short-Term Goals (6 months)
1. **MVP Release** with core DKP tracking (single pool)
2. **Discord Authentication** for seamless guild integration
3. **Migration Tools** for existing EQdkpPlus users
4. **Mobile-Responsive** interface
5. **Community Feedback** from 5+ P99 pilot guilds

#### Mid-Term Goals (12 months)
1. **P99 Guild Adoption** - 30+ guilds using GuildHub
2. **Discord Bot** - Rich integration with Discord commands
3. **P99 Item Database** - Auto-populate item names and details
4. **Analytics Dashboard** - Attendance and loot distribution insights
5. **Self-Hosting Guides** - Easy deployment for guilds

#### Long-Term Goals (18-24 months)
1. **Standard DKP System** for P99 community
2. **Community-Driven Features** based on guild feedback
3. **Performance Optimization** for large raid histories
4. **Optional Managed Hosting** for guilds wanting hosted solution

### 2.3 Success Criteria

| Metric | Target | Timeline |
|--------|--------|----------|
| P99 Guilds Using GuildHub | 30+ | 12 months |
| Active Raids Tracked/Week | 200+ | 12 months |
| Monthly Active Users | 1,500+ | 12 months |
| Discord Servers Integrated | 30+ | 12 months |
| GitHub Stars | 100+ | 12 months |
| Community Contributors | 5+ | 18 months |
| User Satisfaction (NPS) | > 50 | 12 months |

---

## 3. Why Ruby on Rails?

### 3.1 Technical Advantages

| Advantage | Benefit |
|-----------|---------|
| **Convention over Configuration** | Faster development, less boilerplate |
| **ActiveRecord ORM** | Elegant database interactions, migrations |
| **Built-in Testing** | RSpec, MiniTest for quality assurance |
| **Asset Pipeline** | Modern frontend tooling (Webpack, esbuild) |
| **Security Defaults** | CSRF, XSS, SQL injection prevention built-in |
| **Scalability** | Battle-tested at scale (GitHub, Shopify, Airbnb) |
| **Community & Gems** | Vast ecosystem of well-maintained libraries |
| **Modern Ruby (3.x)** | Performance improvements, pattern matching |

### 3.2 Comparison: PHP vs Rails

| Aspect | EQdkpPlus (PHP) | GuildHub (Rails) |
|--------|-----------------|------------------|
| **Language** | PHP 5.6-7.4 | Ruby 3.x |
| **Framework** | Custom/Bespoke | Rails 8.x |
| **ORM** | Custom DB wrapper | ActiveRecord |
| **Template Engine** | Custom | ERB/Haml/Slim |
| **Package Manager** | Manual/Composer | Bundler (Gems) |
| **Asset Pipeline** | Manual | Sprockets/Webpacker/esbuild |
| **Testing Framework** | Limited/Custom | RSpec/MiniTest |
| **API Support** | Basic/Custom | Rails API mode, GraphQL |
| **WebSockets** | Manual | ActionCable built-in |
| **Background Jobs** | Cron scripts | Solid Queue (Rails 8 built-in) |
| **Deployment** | FTP/Manual | Capistrano/Docker/Heroku |
| **Cloud Native** | Limited | Native support |

### 3.3 Long-Term Maintainability

**Rails Advantages:**
- **Active Development**: Rails 8.0+ with regular updates
- **Security Patches**: Rapid CVE response from core team
- **Ecosystem Health**: 6,000+ actively maintained gems
- **Developer Pool**: Large community of Rails developers
- **Modern Standards**: Follows web best practices
- **Documentation**: Extensive guides, books, tutorials

---

## 4. Core Features & Requirements

### 4.1 Simplified Feature Set

**Focus: Essential DKP tracking for P99 EverQuest guilds**

**INCLUDED Features:**
- ✅ Single DKP pool tracking
- ✅ Raid creation and logging
- ✅ Raid attendance tracking
- ✅ Item awards with DKP deduction
- ✅ Character management (classes, races, levels)
- ✅ Main/alt character relationships
- ✅ DKP standings and reports
- ✅ Discord authentication
- ✅ Admin panel for officers
- ✅ News/announcements
- ✅ Audit logging

**EXCLUDED Features:**
- ❌ Multiple DKP pools
- ❌ Calendar and event signups
- ❌ Multi-game support
- ❌ Plugin system
- ❌ Theme customization
- ❌ Traditional user registration
- ❌ Portal widgets

### 4.2 Feature Implementation

#### Phase 1: Foundation (Months 1-2)

| Feature | Implementation | Priority | Notes |
|---------|---------------|----------|-------|
| **Discord OAuth** | OmniAuth Discord | **P0** | Primary auth method |
| **Admin Login** | Devise (username/password) | **P0** | For officers only |
| **Guild Setup** | Single guild per installation | **P0** | Simple setup |
| **Character Management** | ActiveRecord with EQ classes/races | **P0** | 14 classes, 12 races |
| **Main/Alt Linking** | Self-referential association | **P0** | Track alts |

#### Phase 2: Core DKP (Months 3-4)

| Feature | Implementation | Priority | Notes |
|---------|---------------|----------|-------|
| **Single DKP Pool** | Simple point tracking | **P0** | No multi-pool complexity |
| **Raid Creation** | Raid model with zone/boss | **P0** | Classic EQ zones |
| **Attendance Tracking** | Character attendance per raid | **P0** | Auto-award points |
| **Item Awards** | Item model with point cost | **P0** | Auto-deduct DKP |
| **DKP Standings** | Current/earned/spent view | **P0** | Sortable, filterable |

#### Phase 3: Polish & Features (Months 5-6)

| Feature | Implementation | Priority | Notes |
|---------|---------------|----------|-------|
| **News/Announcements** | ActionText for rich content | **P1** | Guild communications |
| **Discord Bot** | Discord.rb gem | **P1** | !dkp commands |
| **P99 Item Database** | Seed data from P99 wiki | **P1** | Auto-complete items |
| **Manual Adjustments** | Point adjustment with reason | **P1** | Officer corrections |
| **Audit Logging** | PaperTrail | **P1** | Track all changes |
| **Reports** | DKP analytics & charts | **P1** | Attendance, loot dist |

#### Phase 4: Migration & Launch (Months 7-8)

| Feature | Implementation | Priority | Notes |
|---------|---------------|----------|-------|
| **Data Migration Tool** | Ruby script for EQdkpPlus import | **P0** | Essential for adoption |
| **Mobile Optimization** | Responsive Tailwind design | **P1** | Mobile-first |
| **Performance Tuning** | Query optimization, caching | **P1** | Handle large guilds |
| **Documentation** | User & admin guides | **P0** | Self-service |
| **Deployment Guide** | Docker & cloud instructions | **P0** | Easy self-hosting |

### 4.3 Detailed Requirements

#### 4.3.1 Authentication & Authorization

**REQ-AUTH-001**: Discord OAuth
- Users authenticate via Discord OAuth2
- Auto-link Discord username to character(s)
- Store Discord ID for bot integration
- No traditional email/password registration

**REQ-AUTH-002**: Admin Authentication
- Separate admin panel (username/password)
- Devise for admin users only
- Officer roles: Guild Leader, Officer, DKP Master
- Session timeout after 30 minutes

**REQ-AUTH-003**: Permissions
- Simple role-based access (Pundit)
- Roles: Guild Leader, Officer, Member, Guest
- Guild Leader: Full access
- Officer: Manage raids, items, adjustments
- Member: View-only access
- Guest: Public standings only

#### 4.3.2 Character Management

**REQ-CHAR-001**: Character Profiles
- Character name (unique per guild)
- EverQuest class (14 classes: Warrior, Cleric, Paladin, Ranger, Shadow Knight, Druid, Monk, Bard, Rogue, Shaman, Necromancer, Wizard, Magician, Enchanter)
- EverQuest race (12 races: Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome)
- Level (1-60)
- Status: Active, Inactive, Deleted
- Main/Alt character linking (self-referential)
- Optional notes field

**REQ-CHAR-002**: Guild Ranks
- Fixed ranks: Guild Leader, Officer, Member, Recruit
- Rank displayed on character profile
- No complex hierarchy needed
- Permissions tied to officer roles (separate from ranks)

**REQ-CHAR-003**: Character-Discord Linking
- Link Discord user to one or more characters
- Primary character designation
- Display Discord avatar on character profile
- Show online status from Discord

#### 4.2.3 DKP System (Single Pool)

**REQ-DKP-001**: DKP Pool Management
- Single DKP pool per guild (simplified design)
- Guild-level DKP configuration:
  - Pool name (e.g., "Main Raid DKP")
  - Point precision (decimals allowed or integers only)
  - Starting balance for new members (default: 0)
  - Optional decay rules (percentage per time period)
  - Optional point caps (maximum balance)

**REQ-DKP-002**: Raid Event Types
- Predefined event types for P99 raids:
  - Plane of Fear
  - Plane of Hate
  - Plane of Sky
  - Nagafen
  - Vox
  - Innoruuk
  - Cazic-Thule
  - Custom raid types
- Each event type has:
  - Default point value
  - Optional icon/image
  - Description

**REQ-DKP-003**: Raid Tracking
- Create raid instance with:
  - Raid date/time
  - Event type selection
  - Point value (pre-filled from event type, editable)
  - Optional notes (ActionText for rich formatting)
- Attendance tracking:
  - Add characters to raid attendance list
  - Track attendance status (present, late, left early)
  - Points awarded per character
  - Bulk add/remove attendees
- Raid history with filtering and search

**REQ-DKP-004**: Item Awards
- Award items from raids to characters:
  - Item name (free text or from EQ item database)
  - Point cost (DKP spent)
  - Character receiving item
  - Raid association (which raid drop)
  - Optional notes
- Item award history per character
- Rollback capability (undo item award, restore points)
- Audit trail with PaperTrail

**REQ-DKP-005**: Manual Adjustments
- Officers can manually adjust DKP:
  - Add or subtract points from character(s)
  - Required reason/note field
  - Timestamp and admin user tracking
- Mass adjustments:
  - Decay application (reduce all balances by %)
  - Bonus points for entire guild
  - Correction adjustments
- Full audit trail with PaperTrail

**REQ-DKP-006**: Point Calculation & Display
- Real-time current balance per character
- Balance calculation:
  - Starting balance
  - + Points earned (raid attendance)
  - - Points spent (item awards)
  - +/- Manual adjustments
  - - Decay (if enabled)
- Historical point tracking (transaction log)
- Reports:
  - Current standings (all characters sorted by DKP)
  - Earned vs. Spent summary
  - Transaction history with filters
  - Export to CSV

#### 4.2.4 Content Management

**REQ-CMS-001**: Announcements
- Rich text editor (ActionText/Trix)
- Create guild announcements/news posts
- Draft and published states
- Pinned announcements (sticky)
- View tracking (read counts)
- Simple categorization (News, Raid, Loot, General)

**REQ-CMS-002**: Comments
- Simple threaded comments on announcements
- Comment moderation by officers
- Basic Markdown support
- @ mentions for Discord-linked users
- Edit/delete own comments

#### 4.2.5 Portal/Dashboard

**REQ-PORTAL-001**: Guild Dashboard
- Simple dashboard with key information:
  - Recent announcements
  - Current DKP standings (top 10)
  - Recent raids
  - Recent loot awards
  - Online Discord members (if connected)
- ViewComponent-based widgets
- Simple responsive layout (Tailwind CSS)

**REQ-PORTAL-002**: Character Dashboard
- Personal view for logged-in members:
  - My DKP balance
  - My recent raid attendance
  - My loot history
  - My characters list

---

## 5. Modern Enhancements (Beyond EQdkpPlus)

### 5.1 Discord Integration (Primary Enhancement)

**REQ-INT-001**: Discord OAuth Authentication
- OAuth 2.0 login with Discord (OmniAuth Discord)
- Automatic account creation on first login
- Link Discord identity to guild characters
- Display Discord avatar throughout application
- Show online/offline status

**REQ-INT-002**: Discord Bot Integration
- Optional Discord bot (Discord.rb gem)
- Bot commands:
  - `/dkp [character]` - Check DKP balance
  - `/standings` - Top 10 DKP standings
  - `/raids` - Recent raids
- Post raid results to Discord channel
- Post loot awards to Discord channel
- Configurable webhook URLs per guild

### 5.2 Mobile Experience

**REQ-MOB-001**: Responsive Design
- Mobile-first responsive design (Tailwind CSS)
- Touch-optimized interfaces
- Works on phones, tablets, desktop
- No dedicated mobile app needed (PWA future consideration)

### 5.3 Real-Time Features

**REQ-RT-001**: Live Updates (Hotwire/Turbo)
- Real-time DKP standings updates
- Live raid attendance tracking
- Activity feed on dashboard
- Turbo Streams for instant updates without page refresh

**REQ-RT-002**: Notifications
- In-app notification system
- Discord webhook notifications for:
  - New announcements
  - DKP adjustments
  - Raid results posted
- Email notifications (optional, queued via Solid Queue)

### 5.4 Analytics & Reporting

**REQ-ANA-001**: Guild Analytics
- Attendance reports (per character, per raid type)
- Loot distribution analysis
- DKP balance trends over time (Chart.js)
- Activity metrics (active raiders)
- Simple visualizations and charts

**REQ-ANA-002**: Data Export
- CSV exports for all major data:
  - DKP standings
  - Raid history
  - Loot awards
  - Transaction history
- Print-friendly reports

### 5.5 Modern Developer Features

**REQ-DEV-001**: Simple API
- RESTful JSON API for basic operations:
  - GET /api/v1/standings
  - GET /api/v1/raids
  - GET /api/v1/characters
- API token authentication for Discord bot
- Rate limiting (Rack::Attack)
- JSON:API format

---

## 6. Technical Requirements

### 6.1 Technology Stack

#### Backend (Rails 8.x)
- **Ruby**: 3.3+ (latest stable)
- **Rails**: 8.0+ (with built-in defaults)
- **Database**: PostgreSQL 16+ (primary)
- **Cache**: Redis 7+
- **Background Jobs**: Solid Queue (Rails 8 built-in)
- **Search**: PostgreSQL full-text search (pg_search gem)

#### Frontend
- **Asset Pipeline**: Propshaft (Rails 8 built-in)
- **JavaScript**: Modern ES6+ with esbuild
- **CSS Framework**: Tailwind CSS 4.0+
- **UI Components**: ViewComponent 3+
- **Interactivity**: Stimulus.js (Hotwire)
- **Real-time**: Turbo Streams (Hotwire)
- **Icons**: Heroicons 2+
- **Charts**: Chart.js 4+ (for DKP analytics)

#### Key Gems
```ruby
# Authentication & Authorization
gem 'devise', '~> 4.9'              # Admin panel auth only
gem 'omniauth-discord'              # Discord OAuth for users
gem 'pundit', '~> 2.3'              # Authorization policies

# Rich Features
gem 'action_text'                   # Rich text (Rails 8 built-in)
gem 'paper_trail', '~> 15.0'        # Audit trail for DKP changes

# Discord Integration
gem 'discordrb', '~> 3.5'           # Discord bot (optional)

# Utilities
gem 'kaminari', '~> 1.2'            # Pagination
gem 'pg_search', '~> 2.3'           # PostgreSQL search
gem 'jsonapi-serializer'            # API responses
```

#### Infrastructure
- **Web Server**: Puma 6+ (concurrent)
- **Reverse Proxy**: Nginx or Caddy
- **Deployment**: Docker, Kamal 2.0, or Capistrano
- **Cloud Platforms**: AWS, DigitalOcean, Railway, Render
- **Storage**: S3-compatible for avatar uploads (AWS S3, Backblaze B2)

### 6.2 System Requirements

#### Development
- Ruby 3.3+
- PostgreSQL 16+
- Redis 7+
- Node.js 20+ (for asset compilation)
- Git

#### Production (Small Guild: <100 members)
- 1 CPU core
- 2GB RAM
- 10GB SSD storage
- 5GB monthly bandwidth

#### Production (Medium Guild: 100-500 members)
- 2 CPU cores
- 4GB RAM
- 20GB SSD storage
- 20GB monthly bandwidth

#### Production (Large Guild: 500+ members)
- 4 CPU cores
- 8GB RAM
- 50GB SSD storage
- 50GB monthly bandwidth

### 6.3 Security Requirements

**REQ-SEC-001**: Authentication Security
- Discord OAuth (primary - OmniAuth Discord)
- Admin panel: bcrypt password hashing (cost factor 12) via Devise
- Session encryption (Rails default)
- Rate limiting on admin login (Rack::Attack)
- Account lockout after failed admin login attempts

**REQ-SEC-002**: Data Protection
- HTTPS required in production (Let's Encrypt)
- Content Security Policy (CSP) headers
- Encrypted environment variables (Rails credentials)
- Secure cookie flags (Rails default)
- Database connection encryption

**REQ-SEC-003**: Input Validation
- Strong parameters (Rails default)
- SQL injection prevention (ActiveRecord parameterization)
- XSS prevention (Rails auto-escaping)
- CSRF protection (Rails default)
- File upload validation (if supporting custom icons)

**REQ-SEC-004**: Audit & Compliance
- Full audit trail via PaperTrail (all DKP changes)
- GDPR compliance (data export, account deletion)
- Privacy policy (Discord data usage)
- Officer action logging

### 6.4 Performance Requirements

**REQ-PERF-001**: Response Times (P99 Guild Scale)
- Page load: < 300ms (cached)
- DKP standings page: < 500ms
- API requests: < 200ms (p95)
- Database queries: < 100ms (average)

**REQ-PERF-002**: Scalability (Realistic P99 Targets)
- Support 100 concurrent users per guild
- Handle up to 1,000 members per guild
- Process 50 raids/month per guild
- Store 10,000+ item awards per guild

**REQ-PERF-003**: Optimization
- Fragment caching for DKP standings
- Database indexing (character_id, raid_id, etc.)
- N+1 query prevention (Bullet gem in development)
- Asset minification (Propshaft + Tailwind)
- Image optimization for Discord avatars

---

## 7. Success Metrics

### 7.1 Technical Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Test Coverage** | > 80% | SimpleCov |
| **Page Load Time** | < 300ms | Rails logs / APM |
| **API Response Time** | < 200ms | Rails logs |
| **Uptime** | > 99.5% | Uptime monitoring |
| **Error Rate** | < 0.5% | Sentry/Rollbar |
| **Security Score** | A | Brakeman, bundler-audit |

### 7.2 Adoption Metrics (P99 Community)

| Metric | 6 Months | 12 Months | 24 Months |
|--------|----------|-----------|-----------|
| **Active P99 Guilds** | 5 | 15 | 30 |
| **Monthly Active Users** | 200 | 600 | 1,200 |
| **Migration Completions** | 3 | 10 | 25 |
| **GitHub Stars** | 20 | 50 | 100 |
| **Contributors** | 2 | 5 | 10 |

**Note:** P99 is a niche community (~3,000 concurrent players), so targets reflect realistic adoption within this specific ecosystem.

### 7.3 User Satisfaction

| Metric | Target | Method |
|--------|--------|--------|
| **Guild Leader Satisfaction** | > 4/5 | Post-migration surveys |
| **Feature Adoption** | > 70% | Usage analytics |
| **Discord Integration Usage** | > 90% | Analytics (primary auth) |
| **Support Response Time** | < 48hrs | GitHub Issues / Discord |

---

## 8. Project Phases (8-Month Timeline)

### Phase 1: Foundation (Months 1-2)

**Goals:**
- Rails 8 application setup
- Discord OAuth authentication
- Basic guild and character management

**Deliverables:**
- Rails 8.x app scaffold with Hotwire + Tailwind
- PostgreSQL database schema
- Discord OAuth integration (OmniAuth Discord)
- Admin panel authentication (Devise)
- Guild model and basic CRUD
- Character model with EQ classes/races
- Basic UI with Tailwind CSS

**Success Criteria:**
- Users can log in with Discord
- Admins can create guilds and characters
- Database schema deployed

### Phase 2: Core DKP System (Months 3-4)

**Goals:**
- Single DKP pool tracking
- Raid management
- Item awards
- Point calculation

**Deliverables:**
- DKP pool configuration per guild
- Raid event types (P99 specific: PoF, PoH, PoS, dragons, etc.)
- Raid creation with attendance tracking
- Item award system
- Point calculation engine
- DKP standings page with real-time updates (Turbo)
- Manual adjustments with audit trail (PaperTrail)

**Success Criteria:**
- Officers can create raids and track attendance
- Officers can award items and deduct DKP
- Members can view their DKP balance and history
- 1-2 pilot guilds testing system

### Phase 3: Content & Polish (Months 5-6)

**Goals:**
- Announcements system
- Dashboard/portal
- Discord bot integration
- Enhanced UI/UX

**Deliverables:**
- Announcements with rich text (ActionText)
- Comments on announcements
- Guild dashboard (recent activity, standings)
- Character dashboard (personal stats)
- Discord bot with /dkp commands
- Discord webhooks for raid results
- Responsive mobile design
- Analytics and charts (Chart.js)

**Success Criteria:**
- Guilds can post announcements and communicate
- Discord integration working (OAuth + bot)
- Mobile-friendly interface
- 3-5 active pilot guilds

### Phase 4: Migration & Launch (Months 7-8)

**Goals:**
- EQdkpPlus migration tools
- Documentation
- Production readiness
- Initial launch

**Deliverables:**
- EQdkpPlus MySQL → PostgreSQL migration script
- Data import tool (DKP history, raids, items, characters)
- User documentation (setup, usage, migration)
- Admin documentation (installation, configuration)
- Security audit (Brakeman, bundler-audit)
- Performance optimization
- Deployment guide (Docker, Kamal)

**Success Criteria:**
- Successfully migrate 2-3 guilds from EQdkpPlus
- Documentation complete
- Production deployment stable
- Ready for P99 community announcement

---

## 9. Migration from EQdkpPlus

### 9.1 Data Migration

**REQ-MIG-001**: EQdkpPlus Import Tool
- Rails console script to import MySQL dumps
- Import scope (P99 EverQuest guilds only):
  - Guild configuration
  - Characters (map to EQ classes/races)
  - DKP history (consolidate to single pool if multi-pool)
  - Raids and attendance
  - Item awards
  - Members (create placeholder users for Discord linking)
- Data validation and cleanup
- Dry-run mode for testing
- Detailed import log

**REQ-MIG-002**: Migration Process
1. Guild exports EQdkpPlus database (MySQL dump)
2. Run validation checks on export
3. Import to GuildHub staging environment
4. Manual review and testing by guild officers
5. Members link Discord accounts to imported characters
6. Import to production
7. Verify data integrity (DKP balances match)
8. Archive EQdkpPlus installation

### 9.2 Migration Support

- Written migration guide (step-by-step)
- Discord support channel
- Video walkthrough
- Direct migration assistance for first 5 pilot guilds

---

## 10. Risk Analysis

### 10.1 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Rails 8 learning curve | Medium | Medium | Well-documented framework, strong community |
| Discord API changes | Medium | Low | Use official Discord.rb gem, monitor changes |
| Data migration errors | High | Medium | Extensive testing, pilot guilds, validation scripts |
| P99 server downtime affecting testing | Low | Low | P99 highly stable, can test with offline data |

### 10.2 Adoption Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low P99 guild adoption | High | Medium | Direct outreach to P99 guilds, forums, Discord |
| Guilds reluctant to migrate | Medium | Medium | Provide easy migration path, hands-on support |
| Competition from spreadsheets | Medium | High | Emphasize automation, Discord integration benefits |
| Volunteer/solo developer burnout | High | Medium | Simplified scope, realistic 8-month timeline |

### 10.3 Community Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| P99 community rejection | High | Low | Open source, transparent development, community input |
| Lack of ongoing maintenance | Medium | Medium | Simple architecture, good documentation for handoff |
| Hosting costs for guilds | Low | Low | Cheap to host (small DB, minimal traffic) |

---

## 11. Open Questions

1. **Hosting Model**: Self-hosted only? Or offer a simple shared hosting option for $5-10/month per guild?
2. **Item Database**: Build EQ item database integration, or just use free-text item names?
3. **Multi-Guild Support**: Can one user be in multiple P99 guilds? (Edge case: alt guild, sister guilds)
4. **DKP Decay**: Support automatic decay rules, or keep it manual-only?
5. **Public Standings**: Should DKP standings be publicly viewable, or login-required?

---

## 12. Appendices

### 12.1 Reference Documents
- EQdkpPlus Source Code Analysis
- EQdkpPlus ERD (from original documentation)
- Rails 8.x Release Notes
- Project 1999 Wiki (game reference)
- P99 Community Forums

### 12.2 Glossary

| Term | Definition |
|------|------------|
| **P99** | Project 1999 - Classic EverQuest emulator server |
| **DKP** | Dragon Kill Points - reward system for tracking member contributions |
| **Main/Alt** | Primary and alternate characters for the same player |
| **PoF/PoH/PoS** | Plane of Fear/Hate/Sky - major P99 raid zones |
| **Hotwire** | Rails framework for SPA-like experiences (Turbo + Stimulus) |
| **Solid Queue** | Rails 8 built-in background job system (replaces Sidekiq) |
| **Propshaft** | Rails 8 built-in asset pipeline (replaces Sprockets) |
| **OmniAuth** | Ruby authentication library supporting OAuth providers |

### 12.3 P99 EverQuest Reference

**Classes (14):**
- **Tanks**: Warrior, Paladin, Shadow Knight
- **Healers**: Cleric, Druid, Shaman
- **Melee DPS**: Monk, Rogue, Ranger, Bard
- **Casters**: Wizard, Magician, Necromancer, Enchanter

**Races (12):**
- Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome

**Level Cap:** 60 (classic EverQuest)

---

**Document Control**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-19 | Planning Team | Initial PRD for generic Rails implementation |
| 2.0 | 2025-10-19 | Planning Team | Updated for P99-specific focus (simplified scope) |

---

**Next Steps:**
1. ✅ Review and approve PRD (v2.0 - P99 focused)
2. ⬜ Update architecture document for simplified scope
3. ⬜ Update migration strategy for P99-only migration
4. ⬜ Update implementation roadmap (8-month timeline)
5. ⬜ Design database schema (single DKP pool)
6. ⬜ Set up Rails 8 development environment

