//
//  ContainerStatusWidgetView+SingleContainerView.swift
//  Harbour
//
//  Created by royal on 23/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

extension ContainerStatusWidget {
	struct SingleContainerView: View {
		var entry: ContainerStatusWidget.Provider.Entry

		private var intentContainer: IntentContainer? {
			entry.configuration.containers.first
		}

		private var containers: [Container?]? {
			if case .containers(let containers) = entry.result {
				return containers
			}
			return nil
		}

		var body: some View {
			Group {
				if let intentContainer {
					ContainerStatusWidget.ContainerView(
						entry: entry,
						intentContainer: intentContainer,
						container: containers?.first as? Container
					)
				} else {
					StatusFeedbackView(mode: .selectContainer())
				}
			}
			.containerBackground(for: .widget) {
				Color.widgetBackground
			}
		}
	}
}
