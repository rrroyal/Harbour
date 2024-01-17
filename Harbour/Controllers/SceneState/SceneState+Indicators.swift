//
//  SceneState+Indicators.swift
//  Harbour
//
//  Created by royal on 29/01/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import Foundation
import IndicatorsKit
import PortainerKit

// MARK: - SceneState+Indicators

extension SceneState {
	typealias ShowIndicatorAction = (PresentedIndicator) -> Void

	@MainActor
	func showIndicator(_ presentedIndicator: PresentedIndicator) {
		let indicator: Indicator

		switch presentedIndicator {
		case .error(let error):
			indicator = Indicator(error: error)
		case .copied:
			let style: Indicator.Style = .default
			indicator = Indicator(
				id: presentedIndicator.id,
				icon: SFSymbol.copy,
				title: String(localized: "Indicators.Copied"),
				style: style
			)
		case .containerActionExecuted(let containerID, let containerName, let action):
			let style = Indicator.Style(iconStyle: .primary, tintColor: action.color)
			indicator = .init(
				id: presentedIndicator.id,
				icon: action.icon,
				title: containerName ?? containerID,
				subtitle: action.title,
				style: style
			)
		}

		Task { @MainActor in
			indicators.display(indicator)
		}
	}
}

// MARK: - SceneState+PresentedIndicator

extension SceneState {
	enum PresentedIndicator: Identifiable {
		case containerActionExecuted(Container.ID, String?, ExecuteAction)
		case copied
		case error(Error)

		var id: String {
			switch self {
			case .containerActionExecuted(let containerID, _, _):
				"ContainerActionExecutedIndicator.\(containerID)"
			case .copied:
				"CopiedIndicator.\(UUID().uuidString)"
			case .error(let error):
				"ErrorIndicator.\(String(describing: error).hashValue)"
			}
		}
	}
}
