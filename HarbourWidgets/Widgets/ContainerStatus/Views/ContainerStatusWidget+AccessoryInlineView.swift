//
//  ContainerStatusWidget+AccessoryInlineView.swift
//  Harbour
//
//  Created by royal on 23/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

extension ContainerStatusWidget {
	struct AccessoryInlineView: View {
		var entry: ContainerStatusWidget.Provider.Entry

		private var intentContainer: IntentContainer? {
			entry.configuration.containers.first
		}

		private var container: Container? {
			if case .containers(let containers) = entry.result {
				return containers.first as? Container
			}
			return nil
		}

		private var containerState: Container.State? {
			container?.state ?? Container.State?.none
		}

		var body: some View {
			Group {
				if intentContainer != nil {
					Label(container?.status ?? containerState.title, systemImage: containerState.icon)
						.font(.callout)
//						.fontWeight(.medium)
				} else {
					StatusFeedbackView(mode: .selectContainer(long: false))
				}
			}
			.frame(maxWidth: .infinity)
			.containerBackground(for: .widget) {
				Color.clear
			}
		}
	}
}
