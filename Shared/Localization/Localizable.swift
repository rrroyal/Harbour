// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localizable {
  /// Localizable.strings
  ///   Harbour
  /// 
  ///   Created by royal on 17/07/2022.
  ///   en_US
  internal static let appName = Localizable.tr("Localizable", "AppName", fallback: "Harbour")
  internal enum ContainerCell {
    ///  • 
    internal static let stateJoiner = Localizable.tr("Localizable", "ContainerCell.StateJoiner", fallback: " • ")
    /// Unnamed
    internal static let unnamed = Localizable.tr("Localizable", "ContainerCell.Unnamed", fallback: "Unnamed")
  }
  internal enum ContainerContextMenu {
    /// Attach
    internal static let attach = Localizable.tr("Localizable", "ContainerContextMenu.Attach", fallback: "Attach")
  }
  internal enum ContainerDetails {
    /// State
    internal static let containerState = Localizable.tr("Localizable", "ContainerDetails.ContainerState", fallback: "State")
    /// Logs
    internal static let logs = Localizable.tr("Localizable", "ContainerDetails.Logs", fallback: "Logs")
    internal enum UserActivity {
      /// See the details of %@
      internal static func title(_ p1: Any) -> String {
        return Localizable.tr("Localizable", "ContainerDetails.UserActivity.Title", String(describing: p1), fallback: "See the details of %@")
      }
      /// a container
      internal static let unnamedContainerPlaceholder = Localizable.tr("Localizable", "ContainerDetails.UserActivity.UnnamedContainerPlaceholder", fallback: "a container")
    }
  }
  internal enum ContainerLogs {
    /// Empty
    internal static let logsEmpty = Localizable.tr("Localizable", "ContainerLogs.LogsEmpty", fallback: "Empty")
    /// Logs
    internal static let navigationTitle = Localizable.tr("Localizable", "ContainerLogs.NavigationTitle", fallback: "Logs")
    internal enum Menu {
      /// Include timestamps?
      internal static let includeTimestamps = Localizable.tr("Localizable", "ContainerLogs.Menu.IncludeTimestamps", fallback: "Include timestamps?")
      /// Scroll to bottom
      internal static let scrollToBottom = Localizable.tr("Localizable", "ContainerLogs.Menu.ScrollToBottom", fallback: "Scroll to bottom")
      /// Scroll to top
      internal static let scrollToTop = Localizable.tr("Localizable", "ContainerLogs.Menu.ScrollToTop", fallback: "Scroll to top")
    }
  }
  internal enum ContainersView {
    /// Loading...
    internal static let loadingPlaceholder = Localizable.tr("Localizable", "ContainersView.LoadingPlaceholder", fallback: "Loading...")
    /// No containers
    internal static let noContainersPlaceholder = Localizable.tr("Localizable", "ContainersView.NoContainersPlaceholder", fallback: "No containers")
    /// No endpoints
    internal static let noEndpointsPlaceholder = Localizable.tr("Localizable", "ContainersView.NoEndpointsPlaceholder", fallback: "No endpoints")
    /// No endpoint selected
    internal static let noSelectedEndpointPlaceholder = Localizable.tr("Localizable", "ContainersView.NoSelectedEndpointPlaceholder", fallback: "No endpoint selected")
    /// No server selected
    internal static let noSelectedServerPlaceholder = Localizable.tr("Localizable", "ContainersView.NoSelectedServerPlaceholder", fallback: "No server selected")
  }
  internal enum ContentView {
    /// No container selected
    internal static let noContainerSelectedPlaceholder = Localizable.tr("Localizable", "ContentView.NoContainerSelectedPlaceholder", fallback: "No container selected")
    /// No endpoint selected
    internal static let noEndpointSelected = Localizable.tr("Localizable", "ContentView.NoEndpointSelected", fallback: "No endpoint selected")
    /// Not setup
    internal static let notSetup = Localizable.tr("Localizable", "ContentView.NotSetup", fallback: "Not setup")
    internal enum NavigationButton {
      /// Settings
      internal static let settings = Localizable.tr("Localizable", "ContentView.NavigationButton.Settings", fallback: "Settings")
      /// Stacks
      internal static let stacks = Localizable.tr("Localizable", "ContentView.NavigationButton.Stacks", fallback: "Stacks")
    }
  }
  internal enum Debug {
    /// Debug
    internal static let title = Localizable.tr("Localizable", "Debug.Title", fallback: "Debug")
    internal enum LastBackgroundRefresh {
      /// Never
      internal static let never = Localizable.tr("Localizable", "Debug.LastBackgroundRefresh.Never", fallback: "Never")
      /// Last Background Refresh
      internal static let title = Localizable.tr("Localizable", "Debug.LastBackgroundRefresh.Title", fallback: "Last Background Refresh")
    }
  }
  internal enum Generic {
    /// Close
    internal static let close = Localizable.tr("Localizable", "Generic.Close", fallback: "Close")
    /// Copy
    internal static let copy = Localizable.tr("Localizable", "Generic.Copy", fallback: "Copy")
    /// Done
    internal static let done = Localizable.tr("Localizable", "Generic.Done", fallback: "Done")
    /// Error!
    internal static let error = Localizable.tr("Localizable", "Generic.Error", fallback: "Error!")
    /// Loading...
    internal static let loading = Localizable.tr("Localizable", "Generic.Loading", fallback: "Loading...")
    /// More
    internal static let more = Localizable.tr("Localizable", "Generic.More", fallback: "More")
    /// None
    internal static let `none` = Localizable.tr("Localizable", "Generic.None", fallback: "None")
    /// Refresh
    internal static let refresh = Localizable.tr("Localizable", "Generic.Refresh", fallback: "Refresh")
    /// Share...
    internal static let share = Localizable.tr("Localizable", "Generic.Share", fallback: "Share...")
    /// Share
    internal static let shareNoDots = Localizable.tr("Localizable", "Generic.ShareNoDots", fallback: "Share")
    /// Share Portainer URL...
    internal static let sharePortainerURL = Localizable.tr("Localizable", "Generic.SharePortainerURL", fallback: "Share Portainer URL...")
    /// Something went wrong 😕
    internal static let somethingWentWrong = Localizable.tr("Localizable", "Generic.SomethingWentWrong", fallback: "Something went wrong 😕")
    /// Unknown
    internal static let unknown = Localizable.tr("Localizable", "Generic.Unknown", fallback: "Unknown")
  }
  internal enum Indicators {
    /// Copied!
    internal static let copied = Localizable.tr("Localizable", "Indicators.Copied", fallback: "Copied!")
    /// Error!
    internal static let error = Localizable.tr("Localizable", "Indicators.Error", fallback: "Error!")
    /// Expand to read more
    internal static let expandToReadMore = Localizable.tr("Localizable", "Indicators.ExpandToReadMore", fallback: "Expand to read more")
  }
  internal enum Landing {
    /// Beam me up, Scotty!
    internal static let continueButton = Localizable.tr("Localizable", "Landing.ContinueButton", fallback: "Beam me up, Scotty!")
    /// Hi! Welcome to
    internal static let titlePrefix = Localizable.tr("Localizable", "Landing.TitlePrefix", fallback: "Hi! Welcome to")
    internal enum Feature1 {
      /// Manage state, inspect details or see real-time logs right on your phone.
      internal static let description = Localizable.tr("Localizable", "Landing.Feature1.Description", fallback: "Manage state, inspect details or see real-time logs right on your phone.")
      /// Control in your pocket
      internal static let title = Localizable.tr("Localizable", "Landing.Feature1.Title", fallback: "Control in your pocket")
    }
    internal enum Feature2 {
      /// Feature2_Description
      internal static let description = Localizable.tr("Localizable", "Landing.Feature2.Description", fallback: "Feature2_Description")
      /// Feature2_Title
      internal static let title = Localizable.tr("Localizable", "Landing.Feature2.Title", fallback: "Feature2_Title")
    }
    internal enum Feature3 {
      /// Feature3_Description
      internal static let description = Localizable.tr("Localizable", "Landing.Feature3.Description", fallback: "Feature3_Description")
      /// Feature3_Title
      internal static let title = Localizable.tr("Localizable", "Landing.Feature3.Title", fallback: "Feature3_Title")
    }
  }
  internal enum Notifications {
    internal enum ContainersChanged {
      /// Some container
      internal static let unknownContainerPlaceholder = Localizable.tr("Localizable", "Notifications.ContainersChanged.UnknownContainerPlaceholder", fallback: "Some container")
      internal enum MultipleReadable {
        /// 📫
        internal static let emoji = Localizable.tr("Localizable", "Notifications.ContainersChanged.MultipleReadable.Emoji", fallback: "📫")
        /// %@ changed their states.
        internal static func title(_ p1: Any) -> String {
          return Localizable.tr("Localizable", "Notifications.ContainersChanged.MultipleReadable.Title", String(describing: p1), fallback: "%@ changed their states.")
        }
      }
      internal enum MultipleUnreadable {
        /// 📫
        internal static let emoji = Localizable.tr("Localizable", "Notifications.ContainersChanged.MultipleUnreadable.Emoji", fallback: "📫")
        /// %@ containers changed their states.
        internal static func title(_ p1: Any) -> String {
          return Localizable.tr("Localizable", "Notifications.ContainersChanged.MultipleUnreadable.Title", String(describing: p1), fallback: "%@ containers changed their states.")
        }
      }
      internal enum Single {
        internal enum Changed {
          /// %@ → %@
          internal static func body(_ p1: Any, _ p2: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Changed.Body", String(describing: p1), String(describing: p2), fallback: "%@ → %@")
          }
          /// "%@" changed its state.
          internal static func title(_ p1: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Changed.Title", String(describing: p1), fallback: "\"%@\" changed its state.")
          }
        }
        internal enum Inserted {
          /// Current status: %@
          internal static func body(_ p1: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Inserted.Body", String(describing: p1), fallback: "Current status: %@")
          }
          /// "%@" appeared.
          internal static func title(_ p1: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Inserted.Title", String(describing: p1), fallback: "\"%@\" appeared.")
          }
        }
        internal enum Removed {
          /// Last known state: %@
          internal static func body(_ p1: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Removed.Body", String(describing: p1), fallback: "Last known state: %@")
          }
          /// 😶‍🌫️
          internal static let emoji = Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Removed.Emoji", fallback: "😶‍🌫️")
          /// "%@" disappeared.
          internal static func title(_ p1: Any) -> String {
            return Localizable.tr("Localizable", "Notifications.ContainersChanged.Single.Removed.Title", String(describing: p1), fallback: "\"%@\" disappeared.")
          }
        }
      }
    }
  }
  internal enum PortainerKit {
    internal enum ContainerState {
      /// Unknown
      internal static let unknown = Localizable.tr("Localizable", "PortainerKit.ContainerState.Unknown", fallback: "Unknown")
    }
    internal enum ExecuteAction {
      /// Kill
      internal static let kill = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Kill", fallback: "Kill")
      /// Pause
      internal static let pause = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Pause", fallback: "Pause")
      /// Restart
      internal static let restart = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Restart", fallback: "Restart")
      /// Start
      internal static let start = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Start", fallback: "Start")
      /// Stop
      internal static let stop = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Stop", fallback: "Stop")
      /// Resume
      internal static let unpause = Localizable.tr("Localizable", "PortainerKit.ExecuteAction.Unpause", fallback: "Resume")
    }
    internal enum Generic {
      /// Container
      internal static let container = Localizable.tr("Localizable", "PortainerKit.Generic.Container", fallback: "Container")
    }
  }
  internal enum Settings {
    /// Settings
    internal static let title = Localizable.tr("Localizable", "Settings.Title", fallback: "Settings")
    internal enum General {
      /// General
      internal static let title = Localizable.tr("Localizable", "Settings.General.Title", fallback: "General")
      internal enum EnableBackgroundRefresh {
        /// Harbour will notify you if containers change their state in the background.
        internal static let description = Localizable.tr("Localizable", "Settings.General.EnableBackgroundRefresh.Description", fallback: "Harbour will notify you if containers change their state in the background.")
        /// Enable Background Refresh
        internal static let title = Localizable.tr("Localizable", "Settings.General.EnableBackgroundRefresh.Title", fallback: "Enable Background Refresh")
      }
    }
    internal enum Interface {
      /// Interface
      internal static let title = Localizable.tr("Localizable", "Settings.Interface.Title", fallback: "Interface")
      internal enum AppIcon {
        /// App Icon
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.AppIcon.Title", fallback: "App Icon")
      }
      internal enum DisplaySummary {
        /// Show a summary of your containers.
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.DisplaySummary.Description", fallback: "Show a summary of your containers.")
        /// Display Summary
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.DisplaySummary.Title", fallback: "Display Summary")
      }
      internal enum EnableHaptics {
        /// You can tone them down if you don't like them as much as I do :]
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.EnableHaptics.Description", fallback: "You can tone them down if you don't like them as much as I do :]")
        /// Enable Haptics
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.EnableHaptics.Title", fallback: "Enable Haptics")
      }
      internal enum UseColumns {
        /// Display containers list and detail side-by-side.
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.UseColumns.Description", fallback: "Display containers list and detail side-by-side.")
        /// Use Two-Column Layout
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.UseColumns.Title", fallback: "Use Two-Column Layout")
      }
      internal enum UseGridView {
        /// You can fit more containers, but it's harder to read.
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.UseGridView.Description", fallback: "You can fit more containers, but it's harder to read.")
        /// Use Grid View
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.UseGridView.Title", fallback: "Use Grid View")
      }
    }
    internal enum Other {
      /// Debug
      internal static let debug = Localizable.tr("Localizable", "Settings.Other.Debug", fallback: "Debug")
      /// Made with ❤️ (and ☕) by @rrroyal
      internal static let footer = Localizable.tr("Localizable", "Settings.Other.Footer", fallback: "Made with ❤️ (and ☕) by @rrroyal")
      /// Other
      internal static let title = Localizable.tr("Localizable", "Settings.Other.Title", fallback: "Other")
    }
    internal enum Portainer {
      /// Portainer
      internal static let title = Localizable.tr("Localizable", "Settings.Portainer.Title", fallback: "Portainer")
      internal enum EndpointsMenu {
        /// Add
        internal static let add = Localizable.tr("Localizable", "Settings.Portainer.EndpointsMenu.Add", fallback: "Add")
        /// None
        internal static let noServerPlaceholder = Localizable.tr("Localizable", "Settings.Portainer.EndpointsMenu.NoServerPlaceholder", fallback: "None")
        internal enum Server {
          /// Delete
          internal static let delete = Localizable.tr("Localizable", "Settings.Portainer.EndpointsMenu.Server.Delete", fallback: "Delete")
          /// In use
          internal static let inUse = Localizable.tr("Localizable", "Settings.Portainer.EndpointsMenu.Server.InUse", fallback: "In use")
          /// Use
          internal static let use = Localizable.tr("Localizable", "Settings.Portainer.EndpointsMenu.Server.Use", fallback: "Use")
        }
      }
    }
  }
  internal enum Setup {
    /// Setup
    internal static let headline = Localizable.tr("Localizable", "Setup.Headline", fallback: "Setup")
    /// How to log in?
    internal static let howToLogin = Localizable.tr("Localizable", "Setup.HowToLogin", fallback: "How to log in?")
    internal enum Button {
      /// Log in
      internal static let login = Localizable.tr("Localizable", "Setup.Button.Login", fallback: "Log in")
      /// Success!
      internal static let success = Localizable.tr("Localizable", "Setup.Button.Success", fallback: "Success!")
    }
  }
  internal enum Widgets {
    /// Not Found
    internal static let notFoundPlaceholder = Localizable.tr("Localizable", "Widgets.NotFoundPlaceholder", fallback: "Not Found")
    /// Please select a container 🙈
    internal static let selectContainerPlaceholder = Localizable.tr("Localizable", "Widgets.SelectContainerPlaceholder", fallback: "Please select a container 🙈")
    /// Unreachable
    internal static let unreachablePlaceholder = Localizable.tr("Localizable", "Widgets.UnreachablePlaceholder", fallback: "Unreachable")
    internal enum ContainerState {
      /// See the status of selected container right on your Home Screen :)
      internal static let description = Localizable.tr("Localizable", "Widgets.ContainerState.Description", fallback: "See the status of selected container right on your Home Screen :)")
      /// Container Status
      internal static let displayName = Localizable.tr("Localizable", "Widgets.ContainerState.DisplayName", fallback: "Container Status")
    }
    internal enum Placeholder {
      /// Containy
      internal static let containerName = Localizable.tr("Localizable", "Widgets.Placeholder.ContainerName", fallback: "Containy")
      /// Up 10 days
      internal static let containerStatus = Localizable.tr("Localizable", "Widgets.Placeholder.ContainerStatus", fallback: "Up 10 days")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localizable {
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
