# Douyin Live TV

## What This Is

A personal native app for Apple TV (tvOS) that displays basic Douyin live room statistics alongside live video preview. Supports saving favorite rooms for quick access, with manual refresh or automatic refresh every 30 minutes. Built exclusively for personal use.

## Core Value

Conveniently monitor Douyin live room statistics on the big TV screen, keep it simple and fast.

## Requirements

### Validated

- ✓ **AUTH-01**: Support Douyin account login to access live data — v1.0
- ✓ **AUTH-02**: Authentication tokens stored securely in Keychain — v1.0
- ✓ **AUTH-03**: Session persists across app restarts — v1.0
- ✓ **AUTH-04**: Token refresh handled automatically — v1.0
- ✓ **LIVE-01**: Display basic statistics: viewer count, likes, total gifts — v1.0
- ✓ **LIVE-02**: Live video preview playback via AVPlayer — v1.0
- ✓ **LIVE-03**: Stats overlay displayed on top of video — v1.0
- ✓ **LIVE-04**: Large text sizing for stats (visible from couch distance) — v1.0
- ✓ **LIVE-05**: Visual live/offline status indicator — v1.0
- ✓ **LIVE-06**: Toggle between overlay mode and full-screen video — v1.0
- ✓ **LIVE-07**: Picture in Picture (PiP) support for video playback — v1.0
- ✓ **FAV-01**: User can add new room by entering room ID or URL — v1.0
- ✓ **FAV-02**: User can view list of saved favorite rooms — v1.0
- ✓ **FAV-03**: User can delete rooms from favorites — v1.0
- ✓ **FAV-04**: User can quickly select a favorite room to monitor — v1.0
- ✓ **FAV-05**: Last viewed room is remembered and opened on app launch — v1.0
- ✓ **FAV-06**: Favorites persist across app restarts via SwiftData — v1.0
- ✓ **REFRESH-01**: Manual pull-to-refresh for immediate stats update — v1.0
- ✓ **REFRESH-02**: Automatic refresh every 30 minutes when possible — v1.0
- ✓ **REFRESH-03**: Uses system BackgroundTasks framework for background refresh — v1.0
- ✓ **QOL-01**: Top Shelf extension provides quick access to favorites from Apple TV home screen — v1.0
- ✓ **QOL-02**: App icon has correct sizing configured in Xcode project — v1.0

### Active

*(No active requirements — v1.0 complete. Start new milestone for additional features.)*

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
| Single room monitoring only | Aligns with user requirement, simplifies UI and code | ✓ Implemented as designed |
| Manual/30min automatic refresh | User preference, reduces API calls | ✓ Implemented as designed |
| SwiftData for favorites persistence | Native persistent storage, integrates cleanly with SwiftUI | ✓ Implemented as designed |
| Manual dependency injection with DependencyContainer | Avoids third-party DI framework complexity for small app | ✓ Implemented as designed |
| BackgroundTasks for 30-minute background refresh | System-native approach, battery-efficient | ✓ Implemented as designed |

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
*Last updated: 2026-03-31 after v1.0 milestone completion*
