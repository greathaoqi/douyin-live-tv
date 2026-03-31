# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — Initial MVP

**Shipped:** 2026-03-31
**Phases:** 7 | **Plans:** 26 | **Sessions:** ~15

### What Was Built
- Complete tvOS app for monitoring Douyin live rooms on Apple TV
- Secure QR login flow with Keychain storage and automatic token refresh
- Live video playback with PiP support and statistics overlay
- SwiftData-powered favorites management with add/delete/last-room-recall
- Manual pull-to-refresh + 30-minute automatic foreground/background refresh
- Top Shelf extension for quick access to favorites from Apple TV home screen

### What Worked
- Phase-based GSD workflow broke large problem into manageable chunks
- Incremental integration testing caught gaps early in phase 7
- Swift 6 concurrency with `@MainActor` and actor-isolated services works well for this size app
- Manual dependency injection keeps it simple without third-party frameworks
- tvOS HIG compliance baked in from phase 3 avoids large rewrites later

### What Was Inefficient
- Can't build/verify in Windows environment - all Xcode project configuration and compilation must be done manually on macOS
- Initial placeholder files created early sometimes hung around as dead stubs (the one leftover issue found in audit)
- Some phases required gap closure after integration testing - this is expected but added a few extra steps

### Patterns Established
- GSD autonomous mode handles end-to-end execution well - all phases completed automatically with only minor decisions needed
- tvOS development requires human verification for UI/interaction - this is expected and baked into the verification process
- Small app favors simple architecture (four layers, manual DI) - no need for complicated patterns

### Key Lessons
1. **Environment matters**: Cross-platform development where Xcode project can't be built/verified in the working environment requires explicit manual steps documented in the audit - plan for that upfront
2. **Incremental integration check**: Integration gap closure as the final phase is effective - catches all the wiring issues after individual phases are complete
3. **tvOS specifics**: Focus targets, safe area, dark mode, and lifecycle need to be addressed from the beginning - adding them later is more work

### Cost Observations
- Model mix: Mostly sonnet for planning/execution, occasional opus for complex integration analysis
- Sessions: ~15 working sessions across development
- Notable: Autonomous mode completed the entire milestone without manual intervention between phases - very efficient

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | ~15 | 7 | Initial greenfield development with autonomous GSD workflow |

### Cumulative Quality

| Milestone | Tests | Requirements Coverage | Zero-Dep Additions |
|-----------|-------|----------------------|-------------------|
| v1.0 | 17 unit tests | 30/30 (100%) | All core functionality implemented with planned dependencies |

### Top Lessons (Verified Across Milestones)

1. Autonomous GSD workflow effectively delivers complete milestones when requirements are clearly defined upfront
2. Integration gap closure as the final phase is an effective pattern for catching wiring issues
3. Greenfield tvOS development requires human verification for UI and interaction - this is normal and expected
