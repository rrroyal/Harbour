// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {
  internal enum Docker {
    /// Container
    internal static let container = Localization.tr("Localizable", "Docker.Container", fallback: "Container")
    internal enum Container {
      /// Config
      internal static let config = Localization.tr("Localizable", "Docker.Container.Config", fallback: "Config")
      /// Endpoint
      internal static let endpoint = Localization.tr("Localizable", "Docker.Container.Endpoint", fallback: "Endpoint")
      /// Host
      internal static let host = Localization.tr("Localizable", "Docker.Container.Host", fallback: "Host")
      /// Logs
      internal static let logs = Localization.tr("Localizable", "Docker.Container.Logs", fallback: "Logs")
      /// Mounts
      internal static let mounts = Localization.tr("Localizable", "Docker.Container.Mounts", fallback: "Mounts")
      /// Network
      internal static let network = Localization.tr("Localizable", "Docker.Container.Network", fallback: "Network")
    }
  }
  internal enum Error {
    /// Invalid URL
    internal static let invalidURL = Localization.tr("Localizable", "Error.InvalidURL", fallback: "Invalid URL")
    /// Not ready
    internal static let noAPI = Localization.tr("Localizable", "Error.NoAPI", fallback: "Not ready")
    /// No credentials
    internal static let noCredentials = Localization.tr("Localizable", "Error.NoCredentials", fallback: "No credentials")
    /// No endpoint
    internal static let noEndpoint = Localization.tr("Localizable", "Error.NoEndpoint", fallback: "No endpoint")
    /// No server URL
    internal static let noServerURL = Localization.tr("Localizable", "Error.NoServerURL", fallback: "No server URL")
    /// No token
    internal static let noToken = Localization.tr("Localizable", "Error.NoToken", fallback: "No token")
  }
  internal enum ErrorRecoverySuggestion {
    /// Try logging out and logging in back again.
    internal static let relogin = Localization.tr("Localizable", "ErrorRecoverySuggestion.Relogin", fallback: "Try logging out and logging in back again.")
  }
  internal enum Generic {
    /// Are you sure?
    internal static let areYouSure = Localization.tr("Localizable", "Generic.AreYouSure", fallback: "Are you sure?")
    /// Attach
    internal static let attach = Localization.tr("Localizable", "Generic.Attach", fallback: "Attach")
    /// Fetching...
    internal static let fetching = Localization.tr("Localizable", "Generic.Fetching", fallback: "Fetching...")
    /// Loading...
    internal static let loading = Localization.tr("Localizable", "Generic.Loading", fallback: "Loading...")
    /// Nevermind
    internal static let nevermind = Localization.tr("Localizable", "Generic.Nevermind", fallback: "Nevermind")
    /// None
    internal static let `none` = Localization.tr("Localizable", "Generic.None", fallback: "None")
    /// Not logged in
    internal static let notLoggedIn = Localization.tr("Localizable", "Generic.NotLoggedIn", fallback: "Not logged in")
    /// Localizable.strings
    ///   Harbour
    /// 
    ///   Created by royal on 20/06/2021.
    ///   en_US
    internal static let refresh = Localization.tr("Localizable", "Generic.Refresh", fallback: "Refresh")
    /// Success!
    internal static let success = Localization.tr("Localizable", "Generic.Success", fallback: "Success!")
    /// Unknown
    internal static let unknown = Localization.tr("Localizable", "Generic.Unknown", fallback: "Unknown")
    /// Yup!
    internal static let yup = Localization.tr("Localizable", "Generic.Yup", fallback: "Yup!")
  }
  internal enum Home {
    /// Finished! If you see this, please let me know on Twitter - @destroystokyo 😶
    internal static let finishedDebugDisclaimer = Localization.tr("Localizable", "Home.FinishedDebugDisclaimer", fallback: "Finished! If you see this, please let me know on Twitter - @destroystokyo 😶")
    /// No containers
    internal static let noContainers = Localization.tr("Localizable", "Home.NoContainers", fallback: "No containers")
    /// No endpoints
    internal static let noEndpoints = Localization.tr("Localizable", "Home.NoEndpoints", fallback: "No endpoints")
    /// No endpoint selected
    internal static let noEndpointSelected = Localization.tr("Localizable", "Home.NoEndpointSelected", fallback: "No endpoint selected")
    /// Select container
    internal static let selectContainer = Localization.tr("Localizable", "Home.SelectContainer", fallback: "Select container")
  }
  internal enum Indicator {
    internal enum ContainerDismissed {
      /// Tap me to open it again
      internal static let description = Localization.tr("Localizable", "Indicator.ContainerDismissed.Description", fallback: "Tap me to open it again")
      /// Container dismissed!
      internal static let title = Localization.tr("Localizable", "Indicator.ContainerDismissed.Title", fallback: "Container dismissed!")
    }
    internal enum WebSocketDisconnected {
      /// WebSocket disconnected!
      internal static let title = Localization.tr("Localizable", "Indicator.WebSocketDisconnected.Title", fallback: "WebSocket disconnected!")
    }
  }
  internal enum Keychain {
    /// This is your authorization token for Portainer - if you delete it, you will be logged out of Harbour (%@).
    internal static func tokenComment(_ p1: Any) -> String {
      return Localization.tr("Localizable", "Keychain.TokenComment", String(describing: p1), fallback: "This is your authorization token for Portainer - if you delete it, you will be logged out of Harbour (%@).")
    }
  }
  internal enum Login {
    /// How to log in?
    internal static let howToLogin = Localization.tr("Localizable", "Login.HowToLogin", fallback: "How to log in?")
    /// Log in
    internal static let login = Localization.tr("Localizable", "Login.Login", fallback: "Log in")
    /// Log out
    internal static let logout = Localization.tr("Localizable", "Login.Logout", fallback: "Log out")
    internal enum Placeholder {
      /// token
      internal static let token = Localization.tr("Localizable", "Login.Placeholder.Token", fallback: "token")
    }
  }
  internal enum Portainer {
    internal enum AttachedContainer {
      /// Session finished.
      internal static let finished = Localization.tr("Localizable", "Portainer.AttachedContainer.Finished", fallback: "Session finished.")
      /// Unhandled message: %@
      internal static func unhandledMessage(_ p1: Any) -> String {
        return Localization.tr("Localizable", "Portainer.AttachedContainer.UnhandledMessage", String(describing: p1), fallback: "Unhandled message: %@")
      }
    }
  }
  internal enum Settings {
    internal enum Footer {
      /// Made with ❤️ (and ☕️) by @rrroyal
      internal static let label = Localization.tr("Localizable", "Settings.Footer.Label", fallback: "Made with ❤️ (and ☕️) by @rrroyal")
    }
    internal enum Section {
      /// Data
      internal static let data = Localization.tr("Localizable", "Settings.Section.Data", fallback: "Data")
      /// Interface
      internal static let interface = Localization.tr("Localizable", "Settings.Section.Interface", fallback: "Interface")
      /// Other
      internal static let other = Localization.tr("Localizable", "Settings.Section.Other", fallback: "Other")
    }
    internal enum Setting {
      internal enum AutoRefresh {
        /// Auto refresh
        internal static let title = Localization.tr("Localizable", "Settings.Setting.AutoRefresh.Title", fallback: "Auto refresh")
      }
      internal enum EnableHaptics {
        /// You can tone them down if you don't like them as much as I do :]
        internal static let description = Localization.tr("Localizable", "Settings.Setting.EnableHaptics.Description", fallback: "You can tone them down if you don't like them as much as I do :]")
        /// Enable haptics
        internal static let title = Localization.tr("Localizable", "Settings.Setting.EnableHaptics.Title", fallback: "Enable haptics")
      }
      internal enum PersistAttachedContainer {
        /// Keep connected to the attached container after dismissing it
        internal static let description = Localization.tr("Localizable", "Settings.Setting.PersistAttachedContainer.Description", fallback: "Keep connected to the attached container after dismissing it")
        /// Persist attached container
        internal static let title = Localization.tr("Localizable", "Settings.Setting.PersistAttachedContainer.Title", fallback: "Persist attached container")
      }
      internal enum RefreshInBackground {
        /// App will send you a notification if something bad happens 🤞
        internal static let description = Localization.tr("Localizable", "Settings.Setting.RefreshInBackground.Description", fallback: "App will send you a notification if something bad happens 🤞")
        /// Refresh in the background
        internal static let title = Localization.tr("Localizable", "Settings.Setting.RefreshInBackground.Title", fallback: "Refresh in the background")
      }
      internal enum UseColorfulCells {
        /// ✨ Add some sparkle ✨
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseColorfulCells.Description", fallback: "✨ Add some sparkle ✨")
        /// Use colorful container cells
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseColorfulCells.Title", fallback: "Use colorful container cells")
      }
      internal enum UseColumns {
        /// Use multiple-columns layout (only available on iPadOS and macOS)
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseColumns.Description", fallback: "Use multiple-columns layout (only available on iPadOS and macOS)")
        /// Use columns
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseColumns.Title", fallback: "Use columns")
      }
      internal enum UseGridView {
        /// You can fit more containers, but it's worse for accessibility
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseGridView.Description", fallback: "You can fit more containers, but it's worse for accessibility")
        /// Use grid view
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseGridView.Title", fallback: "Use grid view")
      }
    }
  }
  internal enum Setup {
    /// Beam me up, Scotty!
    internal static let nextButtonLabel = Localization.tr("Localizable", "Setup.NextButtonLabel", fallback: "Beam me up, Scotty!")
    /// Hi! Welcome to %@!
    internal static func welcomeHeadline(_ p1: Any) -> String {
      return Localization.tr("Localizable", "Setup.WelcomeHeadline", String(describing: p1), fallback: "Hi! Welcome to %@!")
    }
    internal enum Feature1 {
      /// Your Minecraft server is taking up too much ram? Quickly restart it from your phone.
      internal static let description = Localization.tr("Localizable", "Setup.Feature1.Description", fallback: "Your Minecraft server is taking up too much ram? Quickly restart it from your phone.")
      /// Control your containers
      internal static let title = Localization.tr("Localizable", "Setup.Feature1.Title", fallback: "Control your containers")
    }
    internal enum Feature2 {
      /// You can check logs, mounts, network config - everything!
      internal static let description = Localization.tr("Localizable", "Setup.Feature2.Description", fallback: "You can check logs, mounts, network config - everything!")
      /// See all of the details
      internal static let title = Localization.tr("Localizable", "Setup.Feature2.Title", fallback: "See all of the details")
    }
    internal enum Feature3 {
      /// Yeah. I spent way too much time on that one.
      internal static let description = Localization.tr("Localizable", "Setup.Feature3.Description", fallback: "Yeah. I spent way too much time on that one.")
      /// Attach to them too
      internal static let title = Localization.tr("Localizable", "Setup.Feature3.Title", fallback: "Attach to them too")
    }
  }
  internal enum UserActivity {
    internal enum AttachToContainer {
      /// Attach to %@
      internal static func title(_ p1: Any) -> String {
        return Localization.tr("Localizable", "UserActivity.AttachToContainer.Title", String(describing: p1), fallback: "Attach to %@")
      }
    }
    internal enum ViewContainer {
      /// View details for %@
      internal static func title(_ p1: Any) -> String {
        return Localization.tr("Localizable", "UserActivity.ViewContainer.Title", String(describing: p1), fallback: "View details for %@")
      }
    }
  }
  internal enum Widgets {
    /// Select a container
    internal static let selectContainer = Localization.tr("Localizable", "Widgets.SelectContainer", fallback: "Select a container")
    /// Unreachable
    internal static let unreachable = Localization.tr("Localizable", "Widgets.Unreachable", fallback: "Unreachable")
    internal enum StatusWidget {
      /// See status of your favorite container right on your home screen :)
      internal static let description = Localization.tr("Localizable", "Widgets.StatusWidget.Description", fallback: "See status of your favorite container right on your home screen :)")
      /// Status Widget
      internal static let name = Localization.tr("Localizable", "Widgets.StatusWidget.Name", fallback: "Status Widget")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
