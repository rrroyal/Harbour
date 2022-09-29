// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Localizable {
  /// Harbour
  internal static let appName = Localizable.tr("Localizable", "AppName")

  internal enum ContainerCell {
    ///  • 
    internal static let stateJoiner = Localizable.tr("Localizable", "ContainerCell.StateJoiner")
    /// Unknown
    internal static let unknownState = Localizable.tr("Localizable", "ContainerCell.UnknownState")
    /// Unnamed
    internal static let unnamed = Localizable.tr("Localizable", "ContainerCell.Unnamed")
  }

  internal enum ContainersView {
    /// Loading...
    internal static let loadingPlaceholder = Localizable.tr("Localizable", "ContainersView.LoadingPlaceholder")
    /// No containers
    internal static let noContainersPlaceholder = Localizable.tr("Localizable", "ContainersView.NoContainersPlaceholder")
    /// No endpoints
    internal static let noEndpointsPlaceholder = Localizable.tr("Localizable", "ContainersView.NoEndpointsPlaceholder")
    /// No endpoint selected
    internal static let noSelectedEndpointPlaceholder = Localizable.tr("Localizable", "ContainersView.NoSelectedEndpointPlaceholder")
  }

  internal enum Generic {
    /// Error!
    internal static let error = Localizable.tr("Localizable", "Generic.Error")
    /// Loading...
    internal static let loading = Localizable.tr("Localizable", "Generic.Loading")
  }

  internal enum Indicators {
    /// Expand to read more
    internal static let expandToReadMore = Localizable.tr("Localizable", "Indicators.ExpandToReadMore")
  }

  internal enum Landing {
    /// Beam me up, Scotty!
    internal static let continueButton = Localizable.tr("Localizable", "Landing.ContinueButton")
    /// Hi! Welcome to
    internal static let titlePrefix = Localizable.tr("Localizable", "Landing.TitlePrefix")
    internal enum Feature1 {
      /// Feature1_Description
      internal static let description = Localizable.tr("Localizable", "Landing.Feature1.Description")
      /// Feature1_Title
      internal static let title = Localizable.tr("Localizable", "Landing.Feature1.Title")
    }
    internal enum Feature2 {
      /// Feature2_Description
      internal static let description = Localizable.tr("Localizable", "Landing.Feature2.Description")
      /// Feature2_Title
      internal static let title = Localizable.tr("Localizable", "Landing.Feature2.Title")
    }
    internal enum Feature3 {
      /// Feature3_Description
      internal static let description = Localizable.tr("Localizable", "Landing.Feature3.Description")
      /// Feature3_Title
      internal static let title = Localizable.tr("Localizable", "Landing.Feature3.Title")
    }
  }

  internal enum Settings {
    /// Settings
    internal static let title = Localizable.tr("Localizable", "Settings.Title")
    internal enum General {
      /// General
      internal static let title = Localizable.tr("Localizable", "Settings.General.Title")
    }
    internal enum Interface {
      /// Interface
      internal static let title = Localizable.tr("Localizable", "Settings.Interface.Title")
      internal enum EnableHaptics {
        /// You can tone them down if you don't like them as much as I do :]
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.EnableHaptics.Description")
        /// Enable Haptics
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.EnableHaptics.Title")
      }
      internal enum UseGridView {
        /// You can fit more containers, but it's worse for accessibility
        internal static let description = Localizable.tr("Localizable", "Settings.Interface.UseGridView.Description")
        /// Use Grid view
        internal static let title = Localizable.tr("Localizable", "Settings.Interface.UseGridView.Title")
      }
    }
    internal enum Other {
      /// Made with ❤️ (and ☕) by @rrroyal
      internal static let footer = Localizable.tr("Localizable", "Settings.Other.Footer")
      /// Other
      internal static let title = Localizable.tr("Localizable", "Settings.Other.Title")
    }
    internal enum Portainer {
      /// Portainer
      internal static let title = Localizable.tr("Localizable", "Settings.Portainer.Title")
    }
  }

  internal enum Setup {
    /// How to log in?
    internal static let howToLogin = Localizable.tr("Localizable", "Setup.HowToLogin")
    /// Log in
    internal static let login = Localizable.tr("Localizable", "Setup.Login")
    internal enum Button {
      /// Log in
      internal static let login = Localizable.tr("Localizable", "Setup.Button.Login")
      /// Success!
      internal static let success = Localizable.tr("Localizable", "Setup.Button.Success")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localizable {
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
