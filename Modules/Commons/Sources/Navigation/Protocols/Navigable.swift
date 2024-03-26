//
//  Navigable.swift
//  Navigation
//
//  Created by royal on 26/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

/// A type that can be used for programmatic navigation.
///
/// Conform views to this protocol to make them applicable for programmatic navigation:
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
public protocol Navigable {
	/// Item navigating to this view.
	///
	/// Typically, this would be a struct containing the necessary properties needed to resolve item for this view:
	///
	///     struct NavigationItem: Hashable {
	///         let itemID: String
	///     }
	///
	associatedtype NavigationItem: Hashable

	/// Subdestinations available from this view.
	///
	/// Typically, this would be an enum with destinations available to naviagte to from this view:
	///
	///     enum Subdestination: String {
	///         case settings
	///     }
	///
	/// If there's no available subdestinations, set it to `Never`:
	///
	///     typealias Subdestination = Never
	///
	associatedtype Subdestination: Hashable
}
