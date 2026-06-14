# Harbour – Agent Instructions

Harbour is a SwiftUI app for iOS, iPadOS, and macOS that manages Docker containers via [Portainer](https://www.portainer.io).

## Agent Directives

### Tool Calling
When invoking terminal commands, display the raw command without adding a descriptive name for the action. For example, use `find **/*/SomeFile.swift` instead of `Find SomeFile files`. The description field should be the raw command, not a label.

## Build & Lint

Open `Harbour.xcodeproj` in Xcode and build/run via the IDE.

**Lint (SwiftLint via Fastlane):**
```sh
bundle exec fastlane lint          # uses .swiftlint-full.yml
swiftlint lint                     # uses .swiftlint.yml (lighter config)
```

**PortainerKit tests** (Swift Package, run from `Modules/PortainerKit/`):
```sh
swift test                                          # all tests
swift test --filter PortainerKitTests.<TestName>    # single test
```

## Architecture

### Layer overview

```
Harbour (main app target)
├── HarbourWidgets (widget extension)
└── Shared/              ← types and helpers shared with widgets
    ├── Controllers/Preferences    ← UserDefaults wrapper (ObservableObject)
    ├── Types/                     ← ContainerChange, etc.
    └── Extensions/

Modules/
├── PortainerKit/        ← Swift package: Portainer REST + WebSocket API client
│   └── Sources/PortainerKit/
│       ├── PortainerClient          ← URLSession-based API client
│       └── Types/API/               ← API model types (Container, Endpoint, Stack…)
└── Commons/             ← Swift package: Navigation protocols/helpers
    └── Sources/Navigation/
```

### State & dependency flow

- **`PortainerStore`** (`@Observable @MainActor`) — central data store. Holds `containers`, `endpoints`, `stacks`, the `PortainerClient`, `Keychain`, and `Preferences`. Owns a `TasksController` for tracking in-flight requests.
- **`AppState`** (`@Observable @MainActor`) — app-level state (notification handling, container change tracking). Holds a reference to `PortainerStore`.
- **`SceneDelegate`** (`@Observable @MainActor`) — per-scene navigation state (active tab, navigation paths, presented sheets/alerts, selected items).
- **`Preferences`** (`ObservableObject`) — `@AppStorage`-backed settings stored in the App Group suite (`group.<bundleID>`).

All four are created in `HarbourApp.init()` and injected into the SwiftUI environment via `.withEnvironment(appState:preferences:portainerStore:)`. Views read them with `@Environment(PortainerStore.self)`, `@Environment(AppState.self)`, `@Environment(SceneDelegate.self)`, and `@EnvironmentObject var preferences: Preferences`.

### View / ViewModel pattern

Every major view has a nested `ViewModel` type declared as an extension:

```swift
extension ContainersView {
    @Observable @MainActor
    final class ViewModel { … }
}
```

The ViewModel is stored as `@State private var viewModel: ViewModel` in the view and initialised with the required stores. It drives derived state (`viewState`, filtered `containers`, etc.) and owns the `fetchTask`.

### `ViewState<Success, Failure>`

Async views use this enum instead of ad-hoc booleans:
`.loading` → `.reloading(Success?)` → `.success(Success)` / `.failure(Failure)`

`viewState.backgroundView` renders the appropriate `ProgressView` or `ContentUnavailableView` overlay automatically.

### Offline persistence (SwiftData)

`PortainerStore` persists the last-fetched containers, endpoints, and stacks so they are available offline. Model types (`StoredContainer`, `StoredEndpoint`, `StoredStack`) live in `Shared/Persistence/SwiftData/`. The store creates a `ModelContainer` via `ModelContainer.default()` (which uses the shared App Group) and wraps it in a `ModelActor` for thread-safe access.

### App Intents

Container action and status intents live in `Harbour/Intents/`. They use a separate `IntentPortainerStore` (registered via `AppDependencyManager.shared.add`) rather than the main `PortainerStore`, so they can run in the intents extension process.

### Navigation (`Modules/Commons`)

Views conform to the `Navigable` protocol, declaring:
- `associatedtype NavigationItem: NavigableItem` — identifies what to navigate to
- `associatedtype Subdestination: Hashable` — sub-routes within the view

`SceneDelegate` holds a `NavigationState` struct with per-tab `NavigationPath` properties (`.containers`, `.stacks`). Programmatic navigation goes through `sceneDelegate.navigate(to:tab:with:)`.

### Error & indicator handling

- `\.errorHandler` — `EnvironmentValues` entry; call `errorHandler(error)` to surface errors.
- `\.presentIndicator` — `EnvironmentValues` entry; call `presentIndicator(.someCase)` for transient toasts via `IndicatorsKit`.

## Key Conventions

- **Tabs (indentation):** Use tabs, not spaces. SwiftLint enforces this via the `indentation_style` custom rule.
- **File-per-extension:** Large types are split into `TypeName+Topic.swift` files (e.g. `PortainerStore+Refresh.swift`, `AppState+Notifications.swift`).
- **`MARK:` sections:** Group code with `// MARK: - SectionName` at the type level and `// MARK: TypeName+SectionName` for extensions in separate files.
- **`SFSymbol` constants:** SF Symbol names are referenced through the `SFSymbol` enum (and `SFSymbol.Custom` for custom assets) — never inline string literals.
- **Localization:** All user-facing strings use `LocalizedStringKey` string literals (e.g. `"ContainersView.Title"`). Strings live in `Shared/Localizable.xcstrings`.
- **OSLog:** Use `Logger(.custom(MyType.self))` / `Logger(.app)` / `Logger(.scene)` (from `CommonOSLog`). Privacy annotations (`privacy: .sensitive`, `privacy: .public`) are required on logged values.
- **`force_unwrapping` is opt-in:** The SwiftLint rule is enabled. Suppress with `// swiftlint:disable:next force_unwrapping` only when justified.
- **App Group:** Keychain, `UserDefaults`, and `ModelContainer` all use the shared App Group `group.<mainBundleIdentifier>` so widgets can access the same data.
- **`@ObservationIgnored`:** Properties that should not trigger SwiftUI updates on `@Observable` types (e.g. the `PortainerClient` instance, in-flight tasks) must be annotated with `@ObservationIgnored`.
- **Platform conditionals:** UI differences between iOS and macOS are handled inline with `#if os(iOS)` / `#if os(macOS)` blocks rather than separate files.
