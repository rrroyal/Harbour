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
	case stackRemoved(String)
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
		case .stackRemoved(let stackName):
			"StackRemoved.\(stackName)"
		}
	}
}

// MARK: - PresentedIndicator+Indicator

extension PresentedIndicator {
	var indicator: Indicator {
		switch self {
		case .error(let error):
			return Indicator(error: error)
		case .copied:
			return Indicator(
				id: self.id,
				icon: SFSymbol.copy,
				title: String(localized: "Indicators.Copied")
			)
		case .containerActionExecuted(let containerID, let containerName, let action):
			let style = Indicator.Style(iconStyle: .primary, tintColor: action.color)
			return .init(
				id: self.id,
				icon: action.icon,
				title: containerName ?? containerID,
				subtitle: action.title,
				style: style
			)
		case .stackRemoved(let stackName):
			return .init(
				id: self.id,
				title: String(localized: "Indicators.StackRemoved"),
				subtitle: stackName
			)
		}
	}
}
