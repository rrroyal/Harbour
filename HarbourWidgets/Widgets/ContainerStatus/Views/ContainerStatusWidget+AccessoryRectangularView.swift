//
//  ContainerStatusWidget+AccessoryRectangularView.swift
//  Harbour
//
//  Created by royal on 23/06/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI
import WidgetKit

extension ContainerStatusWidget {
	struct AccessoryRectangularView: View {
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
				if let intentContainer {
					VStack(alignment: .leading) {
						Text(container?.displayName ?? intentContainer.name ?? String(localized: "Generic.Unknown"))
							.font(.headline)

						Label(container?.status ?? containerState.title, systemImage: containerState.icon)
							.font(.subheadline)
							.foregroundStyle(.secondary)
							.lineLimit(2)
					}
					.multilineTextAlignment(.leading)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
				} else {
					StatusFeedbackView(mode: .selectContainer())
				}
			}
			.containerBackground(for: .widget) {
				Color.clear
			}
		}
	}
}
