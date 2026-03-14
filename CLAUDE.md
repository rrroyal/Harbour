# CLAUDE.md — Harbour Codebase Guide

This document provides guidance for AI assistants working on the **Harbour** codebase.

---

## Project Overview

**Harbour** is a native iOS/macOS application for managing Docker containers and stacks via the [Portainer](https://www.portainer.io/) API. It targets iOS 17+/macOS 14+ and is built entirely in Swift using SwiftUI.

- **Bundle ID:** `xyz.shameful.Harbour`
- **Marketing Version:** 4.2.7
- **Platforms:** iOS, iPadOS, macOS (Mac Catalyst or native)
- **No telemetry, no tracking** — privacy is a core principle

---

## Repository Layout

```
Harbour/
├── Harbour/                  # Main app target
│   ├── Controllers/          # AppDelegate, SceneDelegate, AppState
│   ├── UI/
│   │   ├── Views/            # 13 primary screens
│   │   ├── Components/       # Reusable UI components
│   │   ├── Styles/           # Custom button/textfield/tip styles
│   │   ├── Extensions/       # SwiftUI, UIKit, PortainerKit view extensions
│   │   └── Modifiers/        # Custom ViewModifiers
│   ├── Stores/               # PortainerStore — central data store
│   ├── Intents/              # App Intents & Shortcuts
│   ├── Helpers/              # ViewState, ANSIParser, AppIcon, etc.
│   ├── Protocols/            # IndicatorPresentable
│   └── Extensions/           # Foundation & other stdlib extensions
│
├── HarbourWidgets/           # Widget extension target (lock screen + home screen)
│
├── Shared/                   # Code shared between app and widgets
│   ├── Controllers/          # Preferences, AppState shared extensions
│   ├── UI/                   # Minimal shared components (DelayedView, etc.)
│   ├── Extensions/           # Shared Foundation/SwiftUI/PortainerKit extensions
│   ├── Helpers/              # Background tasks, notifications, logging
│   ├── Intents/              # Shared App Shortcuts implementation
│   ├── Types/                # ContainerChange, KeyValueEntry
│   ├── Persistence/          # SwiftData models
│   └── Localizable.xcstrings # All localized strings (~72 KB)
│
├── Modules/
│   ├── Commons/              # SPM package — navigation framework
│   └── PortainerKit/         # Git submodule — Portainer API wrapper
│
├── Harbour.xcodeproj/        # Xcode project
├── ci_scripts/               # Apple Cloud Build scripts
├── fastlane/                 # Fastlane automation
└── .github/                  # Issue templates, funding config
```

---

## Architecture

### Overall Pattern: MVVM + Observation

- **Views** own a nested `ViewModel` class annotated `@Observable @MainActor`.
- ViewModels are defined in companion files named `ViewName+ViewModel.swift`.
- Data flows down from `PortainerStore` (central store) and `Preferences` (persisted settings).
- Use Swift's `@Observable` (iOS 17) instead of legacy `@StateObject`/`@ObservedObject`.

### Central Data Store — `PortainerStore`

Located in `Harbour/Stores/`, it manages:
- Active server endpoints
- Container and stack state
- Refreshing and lifecycle operations
- Error propagation

Access it via the environment: `@EnvironmentObject var portainerStore: PortainerStore` or through the shared `AppState`.

### Environment Injection

Use the custom convenience extension to inject dependencies in previews and tests:

```swift
SomeView()
    .withEnvironment(appState:preferences:portainerStore:)
```

### State Modelling — `ViewState<Success, Failure>`

All async view states use the custom `ViewState` generic enum:

```swift
enum ViewState<Success, Failure: Error> {
    case loading
    case reloading(Success)
    case success(Success)
    case failure(Failure)
}
```

Prefer this over raw optionals or booleans for async content.

### Navigation — `Commons` Module

The `Modules/Commons` SPM package provides:
- `Navigable` — protocol for navigation destinations
- `Deeplinkable` / `DeeplinkHandlable` — deep link routing
- SwiftUI navigation extensions

---

## Key Conventions

### Swift Style

| Rule | Value |
|------|-------|
| Indentation | **Tabs** (enforced by SwiftLint) |
| File length | Warning at 500 lines, error at 700 lines |
| Function body | Warning at 80 lines, error at 100 lines |
| Line length | Warning at 180 chars, error at 220 chars |
| Type nesting | Max 3 levels |
| Force unwrapping | **Prohibited** (SwiftLint opt-in rule) |

### File Naming

- Regular files: `TypeName.swift`
- Extensions on a type: `TypeName+ExtendedBehavior.swift`
- View + ViewModel pairs: `ContainersView.swift` + `ContainersView+ViewModel.swift`
- Extensions organized by framework under `Extensions/SwiftUI/`, `Extensions/PortainerKit/`, etc.

### Localization

- All user-visible strings must be localized via `String(localized:)`.
- Strings are defined in `Shared/Localizable.xcstrings`.
- Never use raw string literals in UI code.

### Logging

Use OSLog via the custom `Logger` wrapper with privacy annotations:

```swift
// Prefer explicit privacy levels
logger.debug("Container ID: \(id, privacy: .public)")
logger.debug("Token: \(token, privacy: .sensitive(mask: .hash))")
```

Category-based loggers: `.app`, `.custom("category")`.

### Preferences Keys

Preferences use abbreviated key naming to conserve UserDefaults space:

```
cvUseGrid         → ContainersView: use grid layout
clIncludeTimestamps → ContainerLogs: include timestamps
svFilterByActiveEndpoint → StacksView: filter by active endpoint
```

Follow existing patterns when adding new preference keys.

---

## Dependencies

All managed via Swift Package Manager (SPM):

| Package | Purpose |
|---------|---------|
| `CommonsKit` | Shared utilities (from main branch) |
| `IndicatorsKit` | In-app notifications/banners (from develop branch) |
| `KeychainKit` | Secure keychain storage |
| `NetworkKit` | Networking helpers |
| `SwiftLintPlugin` | Compile-time linting |
| `PortainerKit` | Portainer REST API client (git submodule in `Modules/`) |

> **Note:** `PortainerKit` is a git submodule. After cloning, run `git submodule update --init --recursive`.

---

## Building

1. Open `Harbour.xcodeproj` in Xcode 16+.
2. Select the `Harbour` scheme.
3. Build for a simulator or connected device.

There is no command-line build script for the main app; use Xcode directly. Fastlane handles release builds:

```bash
bundle exec fastlane lint      # Run SwiftLint checks
bundle exec fastlane build_ipa # Build development .ipa
bundle exec fastlane release   # Full release (requires GITHUB_TOKEN, APPLE_ID, etc.)
```

---

## Testing

There are **no automated unit or UI test targets** in this project. Quality is enforced via:

1. **SwiftLint** — runs as a build plugin on every compile and via `fastlane lint`.
2. **Manual testing** on simulators and physical devices.
3. **TestFlight** beta distribution before App Store releases.

When modifying logic, manually verify affected flows on both iOS and macOS targets.

---

## CI/CD

### Apple Cloud Build

- `ci_scripts/ci_post_clone.sh` — enables build plugins post-clone.
- `ci_scripts/ci_post_xcodebuild.sh` — generates `WhatToTest.txt` from git log for TestFlight changelogs.

### Fastlane

Defined in `fastlane/Fastfile`. Required environment variables for release:

```
GITHUB_TOKEN    — GitHub personal access token
APPLE_ID        — Apple ID for App Store Connect
ITC_TEAM_ID     — App Store Connect team ID
TEAM_ID         — Apple Developer team ID
```

---

## App Intents & Shortcuts

The app integrates with Siri Shortcuts and Apple's App Intents framework. Intent implementations live in:
- `Harbour/Intents/` — app-specific intents
- `Shared/Intents/` — shared intents (used by widgets too)

When adding new intents, follow the existing pattern and register them in the `AppShortcutsProvider`.

---

## Widgets

The `HarbourWidgets` target shares code through the `Shared/` directory and the `group.xyz.shameful.Harbour` App Group. Widget-specific code lives in `HarbourWidgets/`. Widgets have their own entitlements file (`HarbourWidgets.entitlements`).

---

## Key Files Quick Reference

| File/Path | Purpose |
|-----------|---------|
| `Shared/Controllers/Preferences.swift` | All persisted user preferences |
| `Harbour/Stores/PortainerStore.swift` | Central data store |
| `Harbour/Controllers/AppState/` | App-level state management |
| `Harbour/Helpers/ViewState.swift` | Async state enum |
| `Harbour/Helpers/ANSIParser.swift` | ANSI color code parser for logs |
| `Shared/Localizable.xcstrings` | All localized strings |
| `Modules/Commons/` | Navigation framework (SPM) |
| `Modules/PortainerKit/` | Portainer API client (submodule) |
| `.swiftlint.yml` | SwiftLint configuration |
| `fastlane/Fastfile` | Release automation |

---

## Development Workflow

1. **Branch:** Create feature branches from `main` (or `master`).
2. **Lint:** Ensure `swiftlint` passes — it runs automatically on build. Fix all errors before committing.
3. **Test:** Manually test on iOS Simulator and, if possible, macOS.
4. **Commit:** Write clear, descriptive commit messages (see recent log for style).
5. **Push:** Open a PR against `main`.

---

## Important Constraints

- **No force unwrapping** — use `guard`, `if let`, or `??` instead.
- **Tabs, not spaces** — SwiftLint will fail the build otherwise.
- **Localize all UI strings** — never use raw string literals in views.
- **Respect privacy** — use `privacy:` annotations in OSLog calls; do not log sensitive data as `.public`.
- **No telemetry** — do not add analytics, crash reporting SDKs, or tracking of any kind.
- **Keep files under 700 lines** — split large files into extensions or sub-components.
