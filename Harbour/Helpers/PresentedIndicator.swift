//
//  PresentedIndicator.swift
//  Harbour
//
//  Created by royal on 11/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation
import IndicatorsKit
import PortainerKit
import SwiftUI

// MARK: - PresentedIndicator

enum PresentedIndicator {
	case error(Error)
	case copied
	case serverSwitched(String)
	// swiftlint:disable:next enum_case_associated_values_count
	case containerActionExecute(Container.ID, String?, ContainerAction, state: State, action: (() -> Void)? = nil)
	case containerRemove(String, state: State, action: (() -> Void)? = nil)
	case stackStartOrStop(String, started: Bool, state: State, action: (() -> Void)? = nil)
	case stackCreate(String, Stack.ID?, state: State, action: (() -> Void)? = nil)
	case stackRemove(String, Stack.ID?, state: State, action: (() -> Void)? = nil)
}

// MARK: - PresentedIndicator+State

extension PresentedIndicator {
	enum State: Equatable {
		static func == (lhs: PresentedIndicator.State, rhs: PresentedIndicator.State) -> Bool {
			switch (lhs, rhs) {
			case (.loading, .loading): true
			case (.success, .success): true
			case (.failure(let error1), .failure(let error2)): error1 == error2
			default: false
			}
		}

		case loading
		case success
		case failure(Error)
	}
}

// MARK: - PresentedIndicator+Identifiable

extension PresentedIndicator: Identifiable {
	var id: String {
		switch self {
		case .error(let error):
			"Error.\(String(describing: error).hashValue)"
		case .copied:
			"Copied.\(UUID().uuidString)"
		case .serverSwitched:
			"ServerSwitched"
		case .containerActionExecute(let containerID, _, _, _, _):
			"ContainerActionExecute.\(containerID)"
		case .containerRemove(let containerName, _, _):
			"ContainerRemove.\(containerName)"
		case .stackStartOrStop(let stackName, _, _, _):
			"StackStartOrStop.\(stackName)"
		case .stackCreate(let stackName, _, _, _):
			"StackCreate.\(stackName)"
		case .stackRemove(let stackName, _, _, _):
			"StackRemove.\(stackName)"
		}
	}
}

// MARK: - PresentedIndicator+Indicator

extension PresentedIndicator {
	var indicator: Indicator {
		switch self {
		case .error(let error):
			return .init(error: error)
		case .copied:
			return .init(
				id: self.id,
				icon: .systemImage(SFSymbol.copy),
				title: String(localized: "Indicators.Copied")
			)
		case .serverSwitched(let serverURL):
			return .init(
				id: self.id,
				title: String(localized: "Indicators.ServerSwitched"),
				subtitle: serverURL
			)
		case .containerActionExecute(let containerID, let containerName, let containerAction, let state, let action):
			let (icon, title, subtitle, tintColor) = switch state {
			case .loading:
				(Indicator.Icon.progressIndicator, containerAction.title, containerName ?? containerID, containerAction.color)
			case .success:
				(Indicator.Icon.systemImage(containerAction.icon), containerAction.title, containerName ?? containerID, containerAction.color)
			case .failure(let error):
				(Indicator.Icon.systemImage(SFSymbol.error), String(localized: "Indicators.Error"), error.localizedDescription.localizedCapitalized, Color.red)
			}

			// let expandedText: String? = if case let .failure(error) = state {
			// 	error.localizedDescription.localizedCapitalized
			// } else { nil }

			let indicatorAction: Indicator.ActionType? = if let action {
				.execute(action)
			} else {
				.none
			}

			return .init(
				id: self.id,
				icon: icon,
				title: title,
				subtitle: subtitle,
				expandedText: nil,
				dismissType: state != .loading ? .automatic : .manual,
				style: .init(
					iconStyle: state != .loading ? .primary : .secondary,
					tintColor: state != .loading ? tintColor : .gray
				),
				action: indicatorAction
			)
		case .containerRemove(let containerName, let state, let action):
			let (icon, title, subtitle) = switch state {
			case .loading:
				(Indicator.Icon.progressIndicator, String(localized: "Indicators.Container.Remove"), containerName)
			case .success:
				(Indicator.Icon.systemImage(SFSymbol.remove), String(localized: "Indicators.Container.Remove"), containerName)
			case .failure(let error):
				(Indicator.Icon.systemImage(SFSymbol.error), String(localized: "Indicators.Error"), error.localizedDescription.localizedCapitalized)
			}

			// let expandedText: String? = if case let .failure(error) = state {
			// 	error.localizedDescription.localizedCapitalized
			// } else { nil }

			let indicatorAction: Indicator.ActionType? = if let action {
				.execute(action)
			} else {
				.none
			}

			return .init(
				id: self.id,
				icon: icon,
				title: title,
				subtitle: subtitle,
				expandedText: nil,
				dismissType: state != .loading ? .automatic : .manual,
				style: .init(
					iconStyle: state != .loading ? .primary : .secondary,
					tintColor: state != .loading ? .red : .gray
				),
				action: indicatorAction
			)
		case .stackStartOrStop(let stackName, let started, let state, let action):
			let (icon, title, subtitle, tintColor) = switch state {
			case .loading:
				(
					Indicator.Icon.progressIndicator,
					started ? String(localized: "Indicators.Stack.Start") : String(localized: "Indicators.Stack.Stop"),
					stackName,
					(started ? Stack.Status.active.color : Stack.Status.inactive.color)
				)
			case .success:
				(
					Indicator.Icon.systemImage(started ? Stack.Status.active.icon : Stack.Status.inactive.icon),
					started ? String(localized: "Indicators.Stack.Start") : String(localized: "Indicators.Stack.Stop"),
					stackName,
					(started ? Stack.Status.active.color : Stack.Status.inactive.color)
				)
			case .failure(let error):
				(Indicator.Icon.systemImage(SFSymbol.error), String(localized: "Indicators.Error"), error.localizedDescription.localizedCapitalized, Color.red)
			}

			// let expandedText: String? = if case let .failure(error) = state {
			// 	error.localizedDescription.localizedCapitalized
			// } else { nil }

			let indicatorAction: Indicator.ActionType? = if let action {
				.execute(action)
			} else {
				.none
			}

			return .init(
				id: self.id,
				icon: icon,
				title: title,
				subtitle: subtitle,
				expandedText: nil,
				dismissType: state != .loading ? .automatic : .manual,
				style: .init(
					iconStyle: state != .loading ? .primary : .secondary,
					tintColor: state != .loading ? tintColor : .gray
				),
				action: indicatorAction
			)
		case .stackCreate(let stackName, _, let state, let action):
			let (icon, title, subtitle, tintColor) = switch state {
			case .loading:
				(Indicator.Icon.progressIndicator, String(localized: "Indicators.Stack.Create"), stackName, Color.blue)
			case .success:
				(Indicator.Icon.systemImage("sparkles"), String(localized: "Indicators.Stack.Create"), stackName, Color.blue)
			case .failure(let error):
				(Indicator.Icon.systemImage(SFSymbol.error), String(localized: "Indicators.Error"), error.localizedDescription.localizedCapitalized, Color.red)
			}

			// let expandedText: String? = if case let .failure(error) = state {
			// 	error.localizedDescription.localizedCapitalized
			// } else { nil }

			let indicatorAction: Indicator.ActionType? = if let action {
				.execute(action)
			} else {
				.none
			}

			return .init(
				id: self.id,
				icon: icon,
				title: title,
				subtitle: subtitle,
				expandedText: nil,
				dismissType: state != .loading ? .automatic : .manual,
				style: .init(
					iconStyle: state != .loading ? .primary : .secondary,
					tintColor: state != .loading ? tintColor : .gray
				),
				action: indicatorAction
			)
		case .stackRemove(let stackName, _, let state, let action):
			let (icon, title, subtitle) = switch state {
			case .loading:
				(Indicator.Icon.progressIndicator, String(localized: "Indicators.Stack.Remove"), stackName)
			case .success:
				(Indicator.Icon.systemImage(SFSymbol.remove), String(localized: "Indicators.Stack.Remove"), stackName)
			case .failure(let error):
				(Indicator.Icon.systemImage(SFSymbol.error), String(localized: "Indicators.Error"), error.localizedDescription.localizedCapitalized)
			}

			// let expandedText: String? = if case let .failure(error) = state {
			// 	error.localizedDescription.localizedCapitalized
			// } else { nil }

			let indicatorAction: Indicator.ActionType? = if let action {
				.execute(action)
			} else {
				.none
			}

			return .init(
				id: self.id,
				icon: icon,
				title: title,
				subtitle: subtitle,
				expandedText: nil,
				dismissType: state != .loading ? .automatic : .manual,
				style: .init(
					iconStyle: state != .loading ? .primary : .secondary,
					tintColor: state != .loading ? .red : .gray
				),
				action: indicatorAction
			)
		}
	}
}
