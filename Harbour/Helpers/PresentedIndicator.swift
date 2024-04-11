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

enum PresentedIndicator: Identifiable {
	case containerActionExecuted(Container.ID, String?, ContainerAction)
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
