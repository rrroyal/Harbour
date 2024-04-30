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

// MARK: - PresentedIndicator

enum PresentedIndicator {
	case containerActionExecuted(Container.ID, String?, ContainerAction)
	case copied
	case error(Error)
	case stackCreated(String)
	case stackRemoved(String)
	case stackStartedOrStopped(String, started: Bool)
}

// MARK: - PresentedIndicator+Identifiable

extension PresentedIndicator: Identifiable {
	var id: String {
		switch self {
		case .containerActionExecuted(let containerID, _, _):
			"ContainerActionExecutedIndicator.\(containerID)"
		case .copied:
			"CopiedIndicator.\(UUID().uuidString)"
		case .error(let error):
			"ErrorIndicator.\(String(describing: error).hashValue)"
		case .stackCreated(let stackName):
			"StackCreated.\(stackName)"
		case .stackRemoved(let stackName):
			"StackRemoved.\(stackName)"
		case .stackStartedOrStopped(let stackName, _):
			"StackStartedOrStopped.\(stackName)"
		}
	}
}

// MARK: - PresentedIndicator+Indicator

extension PresentedIndicator {
	var indicator: Indicator {
		switch self {
		case .error(let error):
			.init(error: error)
		case .copied:
			.init(
				id: self.id,
				icon: SFSymbol.copy,
				title: String(localized: "Indicators.Copied")
			)
		case .containerActionExecuted(let containerID, let containerName, let action):
			.init(
				id: self.id,
				icon: action.icon,
				title: action.title,
				subtitle: containerName ?? containerID,
				style: .init(
					iconStyle: .primary,
					tintColor: action.color
				)
			)
		case .stackCreated(let stackName):
			.init(
				id: self.id,
				icon: "sparkles",
				title: String(localized: "Indicators.Stack.Created"),
				subtitle: stackName,
				style: .init(
					iconStyle: .primary,
					tintColor: .blue
				)
			)
		case .stackRemoved(let stackName):
			.init(
				id: self.id,
				icon: SFSymbol.remove,
				title: String(localized: "Indicators.Stack.Removed"),
				subtitle: stackName,
				style: .init(
					iconStyle: .primary,
					tintColor: .red
				)
			)
		case .stackStartedOrStopped(let stackName, let started):
			.init(
				id: self.id,
				icon: started ? Stack.Status.active.icon : Stack.Status.inactive.icon,
				title: started ? String(localized: "Indicators.Stack.Started") : String(localized: "Indicators.Stack.Stopped"),
				subtitle: stackName,
				style: .init(
					iconStyle: .primary,
					tintColor: started ? Stack.Status.active.color : Stack.Status.inactive.color
				)
			)
		}
	}
}
