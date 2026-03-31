---
phase: 1
slug: project-setup-core-infrastructure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-30
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (built-in) |
| **Config file** | none — Xcode default |
| **Quick run command** | `xcodebuild clean build -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"` |
| **Full suite command** | `xcodebuild test -scheme DouyinLiveTV -destination "platform=tvOS Simulator,name=Apple TV 4K (3rd generation)"` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick build check
- **After every plan wave:** Run full test suite
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01 | 01 | 1 | Project creation | Build | `xcodebuild clean build...` | ❌ W0 | ⬜ pending |
| 1-02 | 01 | 1 | Dependencies added | Build | `xcodebuild clean build...` | ❌ W0 | ⬜ pending |
| 1-03 | 01 | 1 | Folder structure created | Manual check | N/A | ✅ | ⬜ pending |
| 1-04 | 01 | 1 | Core models defined | Unit test | `xcodebuild test...` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `DouyinLiveTVTests/ModelTests.swift` — stubs for LiveRoom/LiveStats testing
- [ ] Test target created automatically by Xcode during project setup

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Correct folder structure matches four-layer architecture | Phase 1 infrastructure | Can't automate folder structure check | Open project in Finder, verify: App/, UI/, Domain/, Data/ directories exist at correct levels |
| Minimum deployment target set to tvOS 17.0+ | Project setup required for SwiftData | Build will succeed with older deployment if SwiftData not used yet | Open Xcode project settings → Deployment → verify `Minimum Deployments: tvOS 17.0` |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
