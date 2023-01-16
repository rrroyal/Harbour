//
//  ContainerStateWidget.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import SwiftUI
import WidgetKit
import PortainerKit

// MARK: - ContainerStateWidget

struct ContainerStateWidget: Widget {
	private typealias Localization = Localizable.Widgets.ContainerState

	let kind: String = "ContainerStateWidget"
	let provider = ContainerStateProvider()

	var body: some WidgetConfiguration {
		IntentConfiguration(kind: kind, intent: ContainerStateIntent.self, provider: provider) { entry in
			ContainerStateWidgetView(entry: entry)
				.widgetURL(widgetURL(for: entry))
		}
		.supportedFamilies([.systemSmall])
		.configurationDisplayName(Localization.displayName)
		.description(Localization.description)
	}
}

// MARK: - ContainerStateWidget+Helpers

private extension ContainerStateWidget {
	func widgetURL(for entry: ContainerStateProvider.Entry) -> URL? {
		guard let containerID = entry.container?.id ?? entry.configuration.identifier else { return nil }

		let endpointID: Endpoint.ID?
		if let endpointIDStr = entry.configuration.endpoint?.identifier {
			endpointID = Int(endpointIDStr)
		} else {
			endpointID = nil
		}

		let displayName = entry.container?.displayName ?? entry.configuration.container?.displayString

		return HarbourURLScheme.containerDetails(id: containerID, displayName: displayName, endpointID: endpointID).url
	}
}

// MARK: - Previews

struct ContainerStateWidget_Previews: PreviewProvider {
	static let errorEntry = ContainerStateProvider.Entry(date: Date(), configuration: .init(), error: GenericError.invalidURL)
	static let noConfigurationEntry = ContainerStateProvider.Entry(date: Date(), configuration: .init())
	static let unreachableEntry: ContainerStateProvider.Entry = {
		let configuration = ContainerStateIntent()
		configuration.container = .init(identifier: "ID", display: "Containy")
		return .init(date: Date(), configuration: configuration)
	}()
	static let successfulEntry: ContainerStateProvider.Entry = {
		let configuration = ContainerStateIntent()
		configuration.container = .init(identifier: "ID", display: "Containy")
		let container = ContainerStateProvider.placeholderContainer
		return .init(date: Date(), configuration: configuration, container: container)
	}()

	static var previews: some View {
		Group {
			ContainerStateWidgetView(entry: errorEntry)
				.previewDisplayName("Error")

			ContainerStateWidgetView(entry: noConfigurationEntry)
				.previewDisplayName("No Configuration")

			ContainerStateWidgetView(entry: unreachableEntry)
				.previewDisplayName("Unreachable")

			ContainerStateWidgetView(entry: successfulEntry)
				.previewDisplayName("Successful")
		}
		.previewContext(WidgetPreviewContext(family: .systemSmall))
		.previewLayout(.sizeThatFits)
	}
}
