# ArcadeHub Training Plan - 6 Week Intensive

## 🎯 Project Overview

**Project Name**: ArcadeHub - Gaming Lounge Booking + Admin CMS (Micro-Frontend)

**Duration**: 6 weeks (240 hours)

**Target Audience**: Fresh graduate with React/TypeScript knowledge

**Goal**: Build production-ready micro-frontend application mastering the complete modern frontend stack

---

## 📋 What You'll Build

A full-featured gaming lounge management system with:

- **Customer Portal**: Browse branches, book gaming stations, manage bookings
- **Staff Dashboard**: Manage bookings, mark stations as occupied/free
- **Admin Panel**: Manage branches, stations, pricing, users, and reports
- **Real-time Updates**: Live station availability board (stretch goal)

---

## 🏗️ Architecture

### Micro-Frontend Structure
```
arcadehub/
├── frontend/
│   ├── container-shell/       # Host app (Module Federation host)
│   ├── bookings-app/          # Remote MFE - Booking management
│   ├── stations-app/          # Remote MFE - Station status board
│   ├── users-app/             # Remote MFE - User management
│   ├── shared-ui-lib/         # Shared MUI components + theme
│   └── shared-api-client/     # Axios client + TanStack Query hooks
├── mock-api/                  # Mock backend server
└── infra/
    ├── docker-compose.yml
    └── traefik/ or nginx/
```

---

## 📅 6-Week Schedule

### Week 1: Foundation (Steps 1-3)
- **Days 1-2**: Project setup, tooling, TypeScript configuration
- **Days 3-4**: Routing, layout, navigation structure
- **Day 5**: Module Federation micro-frontend setup

**Deliverable**: Working shell with 3 empty remote apps, navigation, and layout

---

### Week 2: Data Layer (Steps 4-5)
- **Days 1-2**: API client, TanStack Query setup, basic queries
- **Days 3-4**: Firebase Authentication integration
- **Day 5**: Protected routes, auth guards, token management

**Deliverable**: Authenticated app with API integration and data fetching

---

### Week 3: Core Features (Steps 6-7)
- **Days 1-3**: Complete booking flow (multi-step form)
- **Days 4-5**: Staff dashboard with optimistic updates

**Deliverable**: Working booking system with customer and staff views

---

### Week 4: Admin + Performance (Steps 8-9)
- **Days 1-3**: Admin panel (users table, filtering, pagination)
- **Days 4-5**: Performance optimization, lazy loading, code splitting

**Deliverable**: Complete CMS with optimized performance

---

### Week 5: Testing (Step 10)
- **Days 1-2**: Unit tests (Jest) - components, hooks, utilities
- **Days 3-4**: E2E tests (Playwright) - critical user flows
- **Day 5**: Test refinement and coverage improvement

**Deliverable**: Comprehensive test suite with >70% coverage

---

### Week 6: Deployment + Stretch (Steps 11-12)
- **Days 1-3**: Docker containerization, reverse proxy setup
- **Days 4-5**: Real-time WebSocket integration (stretch goal)

**Deliverable**: Production-ready dockerized application

---

## 📚 Step-by-Step Guides

Each step has a dedicated guide with:
- ✅ Clear objectives
- 📝 Detailed implementation instructions
- 💡 Tips and best practices
- ⚠️ Common pitfalls to avoid
- 🧪 Testing checklist
- 📋 Definition of Done

| Step | Topic | Guide | Time |
|------|-------|-------|------|
| 1 | Tooling + Baseline App | [step-01-tooling.md](./steps/step-01-tooling.md) | 2 days |
| 2 | Routing + Layout | [step-02-routing.md](./steps/step-02-routing.md) | 2 days |
| 3 | Module Federation | [step-03-module-federation.md](./steps/step-03-module-federation.md) | 1 day |
| 4 | API Client + TanStack Query | [step-04-api-client.md](./steps/step-04-api-client.md) | 2 days |
| 5 | Authentication | *(Guide to be created)* | 2 days |
| 6 | Booking Flow | *(Guide to be created)* | 3 days |
| 7 | Staff Dashboard | *(Guide to be created)* | 2 days |
| 8 | Admin Panel | *(Guide to be created)* | 3 days |
| 9 | Performance | *(Guide to be created)* | 2 days |
| 10 | Testing | *(Guide to be created)* | 4 days |
| 11 | Docker + Proxy | *(Guide to be created)* | 3 days |
| 12 | Real-time (Stretch) | *(Guide to be created)* | 2 days |

---

## 📖 Supporting Documentation

### Core References
- **[Data Models & DTOs](./DATA_MODELS.md)** - Complete type definitions
- **[API Contract](./API_CONTRACT.md)** - OpenAPI specification and endpoints
- **[Component Library](./COMPONENT_LIBRARY.md)** - Shared UI components guide
- **[State Management Strategy](./STATE_MANAGEMENT.md)** - Query keys, caching, invalidation

### Best Practices
- **[TypeScript Guidelines](./TYPESCRIPT_GUIDELINES.md)** - Strict typing patterns
- **[Testing Strategy](./TESTING_STRATEGY.md)** - What, when, and how to test
- **[Performance Best Practices](./PERFORMANCE.md)** - Optimization techniques
- **[Security Checklist](./SECURITY.md)** - Auth, validation, XSS prevention

### Troubleshooting
- **[Common Pitfalls](./COMMON_PITFALLS.md)** - Mistakes to avoid
- **[Tips & Tricks](./TIPS_AND_TRICKS.md)** - Pro techniques
- **[Debugging Guide](./DEBUGGING.md)** - How to troubleshoot issues
- **[Module Federation FAQ](./MODULE_FEDERATION_FAQ.md)** - MFE-specific problems

### Evaluation
- **[Evaluation Rubric](./EVALUATION_RUBRIC.md)** - How your work will be assessed
- **[Code Review Checklist](./CODE_REVIEW_CHECKLIST.md)** - Self-review guide

---

## 🎯 Learning Objectives

By completing this project, you will master:

### Frontend Core
- ✅ React 18.2 with TypeScript (strict mode)
- ✅ Material-UI v5 theming and components
- ✅ React Router v6 (nested routes, protected routes, URL state)
- ✅ TanStack Query v5 (queries, mutations, caching, invalidation)

### Architecture
- ✅ Micro-frontend architecture with Webpack Module Federation
- ✅ Monorepo management with npm workspaces
- ✅ Shared component library design
- ✅ API client architecture and error handling

### Advanced Patterns
- ✅ Optimistic updates
- ✅ Complex form handling and validation
- ✅ URL-driven state management
- ✅ Code splitting and lazy loading
- ✅ Authentication flow and token management

### DevOps
- ✅ Docker multi-stage builds
- ✅ Docker Compose orchestration
- ✅ Reverse proxy configuration (Traefik/Nginx)
- ✅ Environment-based configuration

### Testing
- ✅ Jest unit and component tests
- ✅ Playwright E2E tests
- ✅ Mock service worker (MSW) for API mocking
- ✅ Testing Library best practices

### Optional Advanced
- ✅ WebSocket integration for real-time updates
- ✅ Performance monitoring and optimization
- ✅ Bundle analysis and optimization

---

## 📊 Success Criteria

### Must-Have (Pass/Fail)
- [ ] TypeScript strict mode with proper typing (minimal `any`)
- [ ] All 4 micro-frontends load correctly through Module Federation
- [ ] React Router navigation works (deep links, refresh, back button)
- [ ] TanStack Query used correctly (proper keys, caching, invalidation)
- [ ] Firebase Auth integration complete
- [ ] Core booking flow works end-to-end
- [ ] At least 10 meaningful tests (unit + E2E)
- [ ] Docker Compose runs entire system
- [ ] No console errors in production build

### Strong Signals (Excellence)
- [ ] Excellent error UX (loading states, error boundaries, retry logic)
- [ ] Thoughtful caching strategy with proper invalidation
- [ ] URL-driven state for tables/filters
- [ ] Clean component boundaries with reusable patterns
- [ ] Stable, readable E2E tests
- [ ] Performance optimizations documented
- [ ] Accessible UI (keyboard nav, ARIA labels)
- [ ] Security best practices followed

### Red Flags (Major Issues)
- ❌ Duplicate React instances in console
- ❌ No loading/error state handling
- ❌ Mutations without cache invalidation (stale UI)
- ❌ Hardcoded URLs or secrets (no env vars)
- ❌ Flaky tests with arbitrary timeouts
- ❌ Memory leaks or infinite render loops
- ❌ No TypeScript types (excessive `any` usage)

---

## 🚀 Getting Started

### Prerequisites
```bash
# Required versions
node >= 18.x
npm >= 9.x
docker >= 20.x
docker-compose >= 2.x
```

### Initial Setup
1. **Read all documentation first** (2-3 hours)
   - This file (TRAINING_PLAN.md)
   - DATA_MODELS.md
   - API_CONTRACT.md
   - COMMON_PITFALLS.md

2. **Set up your environment**
   - Install Node.js, Docker, VS Code
   - Install VS Code extensions (ESLint, Prettier, TypeScript)
   - Create Firebase project for authentication

3. **Start with Step 1**
   - Follow steps/step-01-tooling.md
   - Don't skip ahead - each step builds on the previous

4. **Daily routine**
   - Morning: Review step objectives
   - Work: Implement features with tests
   - Evening: Self-review with checklist

---

## 💡 Pro Tips

### Time Management
- **Don't get stuck** - If blocked for >2 hours, move on and come back
- **Test as you go** - Don't leave testing for Week 5
- **Commit frequently** - Small, working increments
- **Use the week buffer** - If you finish Week 4 work in 3 days, that's perfect

### Learning Strategy
- **Read before coding** - Understand the why, not just the how
- **Type everything yourself** - No copy-paste marathon
- **Break when confused** - Fresh eyes solve problems faster
- **Document decisions** - Write comments explaining tricky parts

### Quality Focus
- **Make it work** - Get feature working first
- **Make it right** - Refactor with patterns
- **Make it fast** - Optimize if needed
- **Make it tested** - Add tests before moving on

---

## 🆘 Getting Help

### Self-Help Resources
1. Read the relevant guide in `/steps/`
2. Check COMMON_PITFALLS.md for your exact issue
3. Search the module's official documentation
4. Use browser DevTools and React DevTools

### When to Ask for Help
- Blocked for >2 hours on setup issues
- Fundamental concept confusion (not syntax)
- Need API specification clarification
- Docker/infrastructure issues

### What to Include When Asking
- What you're trying to achieve
- What you've tried
- Error messages (full stack trace)
- Relevant code snippet
- Which step you're on

---

## 📈 Progress Tracking

### Daily Checklist
- [ ] Morning: Review today's objectives
- [ ] Code: Implement features
- [ ] Test: Write tests for new features
- [ ] Review: Check Definition of Done
- [ ] Commit: Push working code
- [ ] Document: Update notes on learnings

### Weekly Milestones
- **Week 1**: Shell runs, remotes load, navigation works
- **Week 2**: Auth works, API calls succeed, data displays
- **Week 3**: Can create and manage bookings
- **Week 4**: Admin panel works, app is fast
- **Week 5**: Tests pass reliably
- **Week 6**: `docker-compose up` runs entire app

---

## 🎓 After Completion

### Portfolio
- Deploy to a free hosting service (Vercel, Netlify, Railway)
- Write a blog post about your Module Federation journey
- Document architecture decisions (ADRs)
- Create a demo video

### Next Steps
- Review SKILLS_BY_LEVEL.md for next learning goals
- Contribute to open source projects
- Build a similar project with a different backend (Go, .NET)
- Add more advanced features (payment gateway, analytics)

---

## 📞 Support

- **Technical Questions**: Review documentation first, then ask
- **Clarifications**: API_CONTRACT.md should cover all endpoints
- **Bugs in Instructions**: Document and work around, report later

---

**Good luck! You're about to level up significantly. 🚀**

*Remember: This is hard on purpose. Struggling means you're learning. Keep going!*

---

*Last Updated: February 2026*
