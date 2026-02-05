# Quick Start Guide - ArcadeHub Training

## 🚀 Get Started in 5 Minutes

### Prerequisites Check

```bash
# Check versions
node --version    # Should be 18.x or higher
npm --version     # Should be 9.x or higher
docker --version  # Should be 20.x or higher

# If missing, install:
# - Node.js: https://nodejs.org/
# - Docker: https://www.docker.com/products/docker-desktop
```

---

## 📖 Day 1 Checklist

### Morning (2-3 hours)
- [ ] Read [TRAINING_PLAN.md](./TRAINING_PLAN.md) - Overview and schedule
- [ ] Read [DATA_MODELS.md](./DATA_MODELS.md) - Understand the data structure
- [ ] Read [API_CONTRACT.md](./API_CONTRACT.md) - Know the API endpoints
- [ ] Skim [COMMON_PITFALLS.md](./COMMON_PITFALLS.md) - Know what to avoid

### Afternoon (4-6 hours)
- [ ] Follow [Step 1: Tooling](./steps/step-01-tooling.md)
  - Create monorepo structure
  - Configure TypeScript strict mode
  - Set up ESLint and Prettier
  - Create container-shell app
  - Get "Hello ArcadeHub" running

### Evening
- [ ] Commit your work to Git
- [ ] Review what you built
- [ ] Bookmark key documentation

---

## 📁 Project Structure You'll Build

```
arcadehub/
├── frontend/
│   ├── container-shell/           # Week 1-2
│   │   ├── src/
│   │   │   ├── components/        # Layout, Navigation
│   │   │   ├── pages/             # All page components
│   │   │   ├── contexts/          # Auth, Notification contexts
│   │   │   ├── routes.tsx         # Route configuration
│   │   │   ├── theme.ts           # MUI theme
│   │   │   └── App.tsx
│   │   └── webpack.config.js      # Module Federation config
│   │
│   ├── bookings-app/              # Week 3 (Step 6-7)
│   │   ├── src/
│   │   │   ├── components/        # Booking flow steps
│   │   │   ├── BookingFlow.tsx
│   │   │   └── bootstrap.tsx
│   │   └── webpack.config.js
│   │
│   ├── stations-app/              # Week 4 (Optional)
│   │   └── src/
│   │       ├── StationsBoard.tsx  # Live status board
│   │       └── bootstrap.tsx
│   │
│   ├── users-app/                 # Week 4 (Step 8)
│   │   └── src/
│   │       ├── UsersTable.tsx     # Admin user management
│   │       └── bootstrap.tsx
│   │
│   ├── shared-ui-lib/             # Week 1-2
│   │   └── src/
│   │       └── components/        # Reusable components
│   │
│   └── shared-api-client/         # Week 2 (Step 4)
│       └── src/
│           ├── api.ts             # Axios instance
│           ├── hooks/             # TanStack Query hooks
│           └── types/             # API types
│
├── mock-api/                      # Week 2 (Step 4)
│   ├── server.js                  # Express mock server
│   └── data/                      # Seed data
│
└── infra/                         # Week 6 (Step 11)
    ├── docker-compose.yml
    └── traefik/                   # Or nginx/
```

---

## 🗓️ Your 6-Week Journey

### Week 1: Foundation
**Goal**: Solid base with routing and layout

**Daily Goals**:
- Mon-Tue: Project setup, TypeScript, tooling
- Wed-Thu: React Router, layout, navigation
- Fri: Module Federation basics

**Deliverable**: Shell app with navigation

---

### Week 2: Data & Auth
**Goal**: Connect to API and add authentication

**Daily Goals**:
- Mon-Tue: API client, TanStack Query, data fetching
- Wed-Thu: Firebase Auth integration
- Fri: Protected routes, token management

**Deliverable**: Authenticated app fetching real data

---

### Week 3: Core Features
**Goal**: Users can book stations

**Daily Goals**:
- Mon-Tue: Booking flow (steps 1-2: branch, date)
- Wed: Booking flow (steps 3-4: station, confirm)
- Thu-Fri: Staff dashboard, optimistic updates

**Deliverable**: Working booking system

---

### Week 4: Admin & Performance
**Goal**: Complete CMS with fast performance

**Daily Goals**:
- Mon-Tue: Admin users table
- Wed: Admin reports/stats
- Thu-Fri: Performance optimization

**Deliverable**: Full CMS, optimized

---

### Week 5: Testing
**Goal**: Comprehensive test coverage

**Daily Goals**:
- Mon-Tue: Unit tests (components, hooks)
- Wed-Thu: E2E tests (Playwright)
- Fri: Fix flaky tests, improve coverage

**Deliverable**: >70% test coverage

---

### Week 6: Deployment
**Goal**: Production-ready Docker deployment

**Daily Goals**:
- Mon-Tue: Dockerfiles for all apps
- Wed: docker-compose.yml
- Thu: Reverse proxy (Traefik/Nginx)
- Fri: Real-time WebSocket (bonus)

**Deliverable**: `docker-compose up` runs everything

---

## 🎯 Critical Success Factors

### Must Have (To Pass)
1. **TypeScript strict mode** - No shortcuts
2. **Module Federation working** - Host + 3 remotes
3. **TanStack Query** - Proper caching & invalidation
4. **Auth working** - Firebase + protected routes
5. **Booking flow** - Complete end-to-end
6. **Tests** - At least 10 meaningful tests
7. **Docker** - Runs with docker-compose

### Should Have (For Good Grade)
1. **Error handling** - Loading, error, empty states
2. **Optimistic updates** - Fast UX
3. **Clean code** - Well-typed, organized
4. **Responsive UI** - Mobile-friendly

### Nice to Have (For Excellence)
1. **WebSocket** - Real-time updates
2. **Advanced tests** - High coverage
3. **Performance** - Optimized bundles
4. **Accessibility** - Keyboard nav, ARIA

---

## 📚 Essential Reading Order

### Before You Code (Day 1)
1. TRAINING_PLAN.md (this structure)
2. DATA_MODELS.md (what you're building)
3. API_CONTRACT.md (how it connects)

### As You Code (Reference)
- COMMON_PITFALLS.md (when stuck)
- TIPS_AND_TRICKS.md (to level up)
- Step guides (for each feature)

### Before Submission
- EVALUATION_RUBRIC.md (self-assessment)
- CODE_REVIEW_CHECKLIST.md (final check)

---

## 🆘 When You Get Stuck

### 1. Check the Step Guide
Each step has:
- Detailed implementation
- Common pitfalls
- Testing checklist

### 2. Search COMMON_PITFALLS.md
90% of issues are listed there

### 3. Debug Systematically
```
1. Read error message carefully
2. Check browser console
3. Check network tab
4. Check React DevTools
5. Check TanStack Query Devtools
6. Add console.logs
```

### 4. Isolate the Problem
- Does it work in a fresh component?
- Did it work before your last change?
- Can you reproduce in a minimal example?

### 5. Take a Break
Seriously. 15-minute walk > 2 hours of frustrated debugging.

---

## 💡 Pro Tips for Success

### Time Management
- **Don't perfect early steps** - Good enough is enough
- **Test as you go** - Don't save testing for Week 5
- **Commit frequently** - Small, working increments
- **Ask for help** - But show what you've tried first

### Learning Strategy
- **Type, don't copy-paste** - Muscle memory matters
- **Read error messages** - They tell you what's wrong
- **Experiment** - Break things to understand them
- **Document learnings** - Keep a TIL.md file

### Code Quality
- **Make it work first** - Then make it right
- **Refactor as you go** - Don't accumulate tech debt
- **Write types immediately** - Not "I'll add them later"
- **Test complex logic** - Don't wait until Week 5

---

## 🎮 Your First Task

Open your terminal and start:

```bash
# Create project directory
mkdir arcadehub && cd arcadehub

# Initialize Git
git init

# Open in VS Code
code .

# Now follow Step 1: Tooling
# Open: steps/step-01-tooling.md
```

---

## 📞 Support

- **Stuck >2 hours?** → Ask for help (show what you tried)
- **Concept unclear?** → Re-read documentation
- **Technical issue?** → Check COMMON_PITFALLS.md
- **Need motivation?** → Review what you've built so far!

---

## ✅ Week 1 Checkpoint

By end of Week 1, you should have:
- [ ] Monorepo structure created
- [ ] TypeScript strict mode working
- [ ] Linting passing
- [ ] Shell app running
- [ ] React Router configured
- [ ] Layout with navigation working
- [ ] Module Federation loading remotes
- [ ] No console errors

If you have this, you're on track! 🎉

---

## 🏁 Final Deliverable

By end of Week 6:
```bash
# One command to run everything
docker-compose up

# Visit http://localhost
# See working app with:
# - Login/logout
# - Browse branches
# - Book stations
# - View bookings
# - Staff dashboard
# - Admin panel
```

If this works, you've succeeded! 🚀

---

**Now go build something amazing! You got this! 💪**
