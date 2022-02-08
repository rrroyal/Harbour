// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localization {

  internal enum Docker {
    /// Container
    internal static let container = Localization.tr("Localizable", "Docker.Container")
    internal enum Container {
      /// Config
      internal static let config = Localization.tr("Localizable", "Docker.Container.Config")
      /// Endpoint
      internal static let endpoint = Localization.tr("Localizable", "Docker.Container.Endpoint")
      /// Host
      internal static let host = Localization.tr("Localizable", "Docker.Container.Host")
      /// Logs
      internal static let logs = Localization.tr("Localizable", "Docker.Container.Logs")
      /// Mounts
      internal static let mounts = Localization.tr("Localizable", "Docker.Container.Mounts")
      /// Network
      internal static let network = Localization.tr("Localizable", "Docker.Container.Network")
    }
  }

  internal enum Error {
    /// Invalid URL
    internal static let invalidURL = Localization.tr("Localizable", "Error.InvalidURL")
    /// Not ready
    internal static let noAPI = Localization.tr("Localizable", "Error.NoAPI")
    /// No credentials
    internal static let noCredentials = Localization.tr("Localizable", "Error.NoCredentials")
    /// No endpoint
    internal static let noEndpoint = Localization.tr("Localizable", "Error.NoEndpoint")
    /// No server URL
    internal static let noServerURL = Localization.tr("Localizable", "Error.NoServerURL")
    /// No token
    internal static let noToken = Localization.tr("Localizable", "Error.NoToken")
  }

  internal enum ErrorRecoverySuggestion {
    /// Try logging out and logging in back again.
    internal static let relogin = Localization.tr("Localizable", "ErrorRecoverySuggestion.Relogin")
  }

  internal enum Generic {
    /// Are you sure?
    internal static let areYouSure = Localization.tr("Localizable", "Generic.AreYouSure")
    /// Attach
    internal static let attach = Localization.tr("Localizable", "Generic.Attach")
    /// Fetching...
    internal static let fetching = Localization.tr("Localizable", "Generic.Fetching")
    /// Loading...
    internal static let loading = Localization.tr("Localizable", "Generic.Loading")
    /// Nevermind
    internal static let nevermind = Localization.tr("Localizable", "Generic.Nevermind")
    /// None
    internal static let `none` = Localization.tr("Localizable", "Generic.None")
    /// Not logged in
    internal static let notLoggedIn = Localization.tr("Localizable", "Generic.NotLoggedIn")
    /// Refresh
    internal static let refresh = Localization.tr("Localizable", "Generic.Refresh")
    /// Success!
    internal static let success = Localization.tr("Localizable", "Generic.Success")
    /// Unknown
    internal static let unknown = Localization.tr("Localizable", "Generic.Unknown")
    /// Yup!
    internal static let yup = Localization.tr("Localizable", "Generic.Yup")
  }

  internal enum Home {
    /// Finished! If you see this, please let me know on Twitter - @destroystokyo 😶
    internal static let finishedDebugDisclaimer = Localization.tr("Localizable", "Home.FinishedDebugDisclaimer")
    /// No containers
    internal static let noContainers = Localization.tr("Localizable", "Home.NoContainers")
    /// No endpoints
    internal static let noEndpoints = Localization.tr("Localizable", "Home.NoEndpoints")
    /// No endpoint selected
    internal static let noEndpointSelected = Localization.tr("Localizable", "Home.NoEndpointSelected")
    /// Select container
    internal static let selectContainer = Localization.tr("Localizable", "Home.SelectContainer")
  }

  internal enum Indicator {
    internal enum ContainerDismissed {
      /// Tap me to open it again
      internal static let description = Localization.tr("Localizable", "Indicator.ContainerDismissed.Description")
      /// Container dismissed!
      internal static let title = Localization.tr("Localizable", "Indicator.ContainerDismissed.Title")
    }
    internal enum WebSocketDisconnected {
      /// WebSocket disconnected!
      internal static let title = Localization.tr("Localizable", "Indicator.WebSocketDisconnected.Title")
    }
  }

  internal enum Keychain {
    /// This is your authorization token for Portainer - if you delete it, you will be logged out of Harbour (%@).
    internal static func tokenComment(_ p1: Any) -> String {
      return Localization.tr("Localizable", "Keychain.TokenComment", String(describing: p1))
    }
  }

  internal enum Login {
    /// How to log in?
    internal static let howToLogin = Localization.tr("Localizable", "Login.HowToLogin")
    /// Log in
    internal static let login = Localization.tr("Localizable", "Login.Login")
    /// Log out
    internal static let logout = Localization.tr("Localizable", "Login.Logout")
    internal enum Placeholder {
      /// token
      internal static let token = Localization.tr("Localizable", "Login.Placeholder.Token")
    }
  }

  internal enum Portainer {
    internal enum AttachedContainer {
      /// Session finished.
      internal static let finished = Localization.tr("Localizable", "Portainer.AttachedContainer.Finished")
      /// Unhandled message: %@
      internal static func unhandledMessage(_ p1: Any) -> String {
        return Localization.tr("Localizable", "Portainer.AttachedContainer.UnhandledMessage", String(describing: p1))
      }
    }
  }

  internal enum Settings {
    internal enum Footer {
      /// Made with ❤️ (and ☕️) by @rrroyal
      internal static let label = Localization.tr("Localizable", "Settings.Footer.Label")
    }
    internal enum Section {
      /// Data
      internal static let data = Localization.tr("Localizable", "Settings.Section.Data")
      /// Interface
      internal static let interface = Localization.tr("Localizable", "Settings.Section.Interface")
      /// Other
      internal static let other = Localization.tr("Localizable", "Settings.Section.Other")
    }
    internal enum Setting {
      internal enum AutoRefresh {
        /// Auto refresh
        internal static let title = Localization.tr("Localizable", "Settings.Setting.AutoRefresh.Title")
      }
      internal enum EnableHaptics {
        /// You can tone them down if you don't like them as much as I do :]
        internal static let description = Localization.tr("Localizable", "Settings.Setting.EnableHaptics.Description")
        /// Enable haptics
        internal static let title = Localization.tr("Localizable", "Settings.Setting.EnableHaptics.Title")
      }
      internal enum PersistAttachedContainer {
        /// Keep connected to the attached container after dismissing it
        internal static let description = Localization.tr("Localizable", "Settings.Setting.PersistAttachedContainer.Description")
        /// Persist attached container
        internal static let title = Localization.tr("Localizable", "Settings.Setting.PersistAttachedContainer.Title")
      }
      internal enum RefreshInBackground {
        /// App will send you a notification if something bad happens 🤞
        internal static let description = Localization.tr("Localizable", "Settings.Setting.RefreshInBackground.Description")
        /// Refresh in the background
        internal static let title = Localization.tr("Localizable", "Settings.Setting.RefreshInBackground.Title")
      }
      internal enum UseColorfulCells {
        /// ✨ Add some sparkle ✨
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseColorfulCells.Description")
        /// Use colorful container cells
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseColorfulCells.Title")
      }
      internal enum UseColumns {
        /// Use multiple-columns layout (only available on iPadOS and macOS)
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseColumns.Description")
        /// Use columns
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseColumns.Title")
      }
      internal enum UseGridView {
        /// You can fit more containers, but it's worse for accessibility
        internal static let description = Localization.tr("Localizable", "Settings.Setting.UseGridView.Description")
        /// Use grid view
        internal static let title = Localization.tr("Localizable", "Settings.Setting.UseGridView.Title")
      }
    }
  }

  internal enum Setup {
    /// Beam me up, Scotty!
    internal static let nextButtonLabel = Localization.tr("Localizable", "Setup.NextButtonLabel")
    /// Hi! Welcome to %@!
    internal static func welcomeHeadline(_ p1: Any) -> String {
      return Localization.tr("Localizable", "Setup.WelcomeHeadline", String(describing: p1))
    }
    internal enum Feature1 {
      /// Your Minecraft server is taking up too much ram? Quickly restart it from your phone.
      internal static let description = Localization.tr("Localizable", "Setup.Feature1.Description")
      /// Control your containers
      internal static let title = Localization.tr("Localizable", "Setup.Feature1.Title")
    }
    internal enum Feature2 {
      /// You can check logs, mounts, network config - everything!
      internal static let description = Localization.tr("Localizable", "Setup.Feature2.Description")
      /// See all of the details
      internal static let title = Localization.tr("Localizable", "Setup.Feature2.Title")
    }
    internal enum Feature3 {
      /// Yeah. I spent way too much time on that one.
      internal static let description = Localization.tr("Localizable", "Setup.Feature3.Description")
      /// Attach to them too
      internal static let title = Localization.tr("Localizable", "Setup.Feature3.Title")
    }
  }

  internal enum Widgets {
    /// Select a container
    internal static let selectContainer = Localization.tr("Localizable", "Widgets.SelectContainer")
    /// Unreachable
    internal static let unreachable = Localization.tr("Localizable", "Widgets.Unreachable")
    internal enum StatusWidget {
      /// See status of your favorite container right on your home screen :)
      internal static let description = Localization.tr("Localizable", "Widgets.StatusWidget.Description")
      /// Status Widget
      internal static let name = Localization.tr("Localizable", "Widgets.StatusWidget.Name")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
