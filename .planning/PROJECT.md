# Douyin Live TV

## What This Is

A personal native app for Apple TV (tvOS) that displays basic Douyin live room statistics alongside live video preview. Supports saving favorite rooms for quick access, with manual refresh or automatic refresh every 30 minutes. Built exclusively for personal use.

## Core Value

Conveniently monitor Douyin live room statistics on the big TV screen, keep it simple and fast.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Support Douyin account login to access live data
- [ ] Display basic statistics for single live room: viewer count, likes, gifts
- [ ] Show live video preview alongside stats overlay
- [ ] Save favorite rooms for quick access and switching
- [ ] Support manual refresh and 30-minute automatic refresh
- [ ] Add new rooms by entering room ID or URL

### Out of Scope

- Multiple rooms simultaneous monitoring — requirement explicitly specifies single room only, simplifies implementation
- Live开播 notifications/reminders — user explicitly stated not needed
- App Store publication — personal sideload use only, no need for App Store compliance
- Historical data recording and analysis — only display needed, no storage/analysis required
- Chat/danmaku display — only basic stats required, scope doesn't include chat
- Multi-user support — single personal use only, no authentication system needed

## Context

Personal project for monitoring Douyin live data on Apple TV. No existing codebase, greenfield development. The app fetches public live data via Douyin's API after login and displays it on TV form factor.

## Constraints

- **Platform**: tvOS for Apple TV — application targets Apple TV hardware
- **Deployment**: Personal sideload only — no need to satisfy App Store review requirements, prioritize simplicity
- **Audience**: Single user — serves only one person, no multi-account needed
- **Refresh frequency**: Maximum 30 minutes — user requested infrequent refresh to reduce risk
- **Authentication**: Requires Douyin login — need to handle authentication session

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Single room monitoring only | Aligns with user requirement, simplifies UI and code | — Pending |
| Manual/30min automatic refresh | User preference, reduces API calls | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-30 after initialization*
