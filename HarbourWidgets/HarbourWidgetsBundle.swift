//
//  HarbourWidgetsBundle.swift
//  HarbourWidgets
//
//  Created by royal on 10/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import AppIntents
import SwiftUI
import WidgetKit

@main
struct HarbourWidgetsBundle: WidgetBundle {
	init() {
		AppDependencyManager.shared.add { IntentPortainerStore() }
	}

	var body: some Widget {
		ContainerStatusWidget()
	}
}
