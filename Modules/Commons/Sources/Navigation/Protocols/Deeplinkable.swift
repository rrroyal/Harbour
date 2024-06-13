//
//  Deeplinkable.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

/// A type that can be used for deeplinking and programmatic navigation.
///
/// Conform views to this protocol to make them applicable for deeplink navigation:
///
///     struct DetailsView: View {
///         @Bindable var navigationPath: NavigationPath
///         var navigationItem: NavigationItem
///
///         var body: some View {
///             NavigationStack(path: $navigationPath) {
///                 List {
///                     Text(navigationItem.id)
///
///                     NavigationLink(value: Subdestination.settings) {
///                         Text("Settings")
///                     }
///                 }
///                 .navigationDestination(for: Subdestination.self) { subdestination in
///                     switch subdestination {
///                     case .settings:
///                         SettingsView()
///                     }
///                 }
///             }
///         }
///     }
///
///     extension DetailsView: Deeplinkable {
///         struct NavigationItem: Hashable {
///             var id: String
///         }
///
///         enum Subdestination: String {
///             case settings
///         }
///
///         var destination: Deeplink.Destination {
///             .details(navigationItem.id)
///         }
///
///         @MainActor
///         static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: Deeplink) {
///             guard case .details(let id) = deeplink.destination else { return }
///
///             navigationPath.removeLast(navigationPath.count)
///
///             let navigationItem = NavigationItem(id: id)
///             navigationPath.append(navigationItem)
///
///				if let subdestination = deeplink.subdestination, !subdestination.isEmpty {
///                 subdestination
///                     .compactMap { Subdestination(rawValue: $0) }
///                     .forEach { navigationPath.append($0) }
///             }
///         }
///
public protocol Deeplinkable: Navigable {
	associatedtype DeeplinkDestination = Deeplink.Destination

	/// Deeplink destination for this object.
	@MainActor
	var deeplinkDestination: DeeplinkDestination { get }

	/// Handles the navigation for this object.
	///
	/// Typically, this function will validate that the received deeplink is applicable for this view, reset the navigation to root view, create `NavigationItem`
	/// and set the `navigationPath` with items navigating to the specified view.
	///
	/// - Parameters:
	///   - navigationPath: Root `NavigationPath`
	///   - deeplink: Deeplink to handle
	@MainActor
	static func handleNavigation(_ navigationPath: inout NavigationPath, with deeplink: DeeplinkDestination)
}
