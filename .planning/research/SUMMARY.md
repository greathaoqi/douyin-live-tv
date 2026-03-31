# Research Summary: Douyin Live TV for tvOS

**Domain:** Native tvOS app for monitoring Douyin live rooms
**Researched:** 2026-03-30
**Overall confidence:** MEDIUM

## Executive Summary

For a small, single-purpose personal tvOS app that monitors Douyin live statistics, MVVM with a clean layered architecture is the clear recommendation. This approach balances simplicity with maintainability — not over-engineering while avoiding the anti-pattern of massive view controllers.

The app naturally separates into four layers: UI (Views/ViewControllers), ViewModels, Domain (models and use cases), and Data (API and persistence). Key concerns are addressed with dedicated components: authentication tokens stored securely in Keychain, live video managed by a dedicated stream manager, periodic stats handled by a polling manager that integrates with tvOS background refresh.

The architecture follows Apple's platform conventions while staying minimal. This is a personal project with a single user, so complexity is avoided where possible but good separation is maintained for future evolution.

## Key Findings

**Stack:** Native Swift with TVUIKit/SwiftUI, Combine for MVVM reactivity, Keychain for secure token storage, AVFoundation for live streaming. Minimal third-party dependencies.
**Architecture:** MVVM with clean layered architecture (UI → ViewModel → Domain → Data) is the sweet spot — not overkill, not messy.
**Authentication:** Tokens must go in Keychain, never UserDefaults. Token refresh logic lives in the APIClient.
**Live Management:** Separate managers for live stream connection (AVPlayer) and stats polling — don't put this in the ViewModel.
**Critical pitfall:** Over-engineering with complex architecture patterns (VIPER, heavy DI containers) that adds unnecessary boilerplate for a personal small app.

## Implications for Roadmap

Based on research, suggested phase structure:

1. **Project Setup & Core Infrastructure** - Create project structure, set up layers, configure dependency container
   - Addresses: Foundation for all features, establishes folder structure and conventions
   - Avoids: Messy ad-hoc structure that requires refactoring later

2. **Authentication & API Layer** - Implement Keychain storage, Douyin API client, login flow
   - Addresses: Core authentication requirement, secure token storage
   - Avoids: Storing tokens insecurely

3. **Basic UI and Data Flow** - Build room list, add room, live room screen with MVVM pattern
   - Addresses: Core user workflow, establishes MVVM pattern consistently
   - Avoids: Massive view controllers by enforcing separation early

4. **Live Stream Integration** - Integrate AVPlayer for live video, implement stats polling
   - Addresses: Core value proposition of displaying video + stats
   - Avoids: Putting stream management logic in ViewModel

5. **Background Refresh & Persistence** - Implement background app refresh, persist favorite rooms
   - Addresses: Automatic 30-minute refresh requirement
   - Avoids: Missing background execution time limits

**Phase ordering rationale:**
- Infrastructure first: Establish architecture patterns before adding features
- Authentication is required before any API calls can work
- Basic UI screens establish the MVVM pattern consistently across the app
- Live stream is the core feature that needs to come after basic structure is in place
- Background refresh is a finishing touch that depends on all other components

**Research flags for phases:**
- Phase 2 (Authentication): Need to verify Douyin API authentication requirements during implementation — can tokens be refreshed? How long do they last? This depends on reverse-engineering the API.
- Phase 4 (Live Stream): Need to test if Douyin live stream URLs can be directly played by AVPlayer on tvOS — may need extra configuration.
- All other phases: Standard patterns, unlikely to need deeper research.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Standard Swift/TVUIKit/AVFoundation stack for tvOS, well-established in industry |
| Features | HIGH | Requirements are clearly defined in project document, all features identified |
| Architecture | MEDIUM | Core patterns are standard Apple platform practice, specific tvOS patterns are adapted from iOS which is standard |
| Pitfalls | HIGH | Common pitfalls are identifiable from general Apple platform development experience |

## Gaps to Address

- **Douyin API specifics:** The actual authentication flow and endpoints need to be discovered during implementation — this research addresses architecture structure, not API details.
- **tvOS background refresh timing:** System can't guarantee exactly 30-minute intervals — this is acceptable per requirements but needs testing on actual hardware.
- **Live stream playback compatibility:** Need to verify that Douyin stream URLs are compatible with AVPlayer on tvOS during implementation.
