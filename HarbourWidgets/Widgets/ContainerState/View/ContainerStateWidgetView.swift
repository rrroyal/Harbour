//
//  ContainerStateWidgetView.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import SwiftUI
import WidgetKit
import UserNotifications

// MARK: - ContainerStateWidgetView

struct ContainerStateWidgetView: View {
	let entry: ContainerStateProvider.Entry

	init(entry: ContainerStateProvider.Entry) {
		self.entry = entry

//		#if DEBUG
//		let debugNotification = UNMutableNotificationContent()
//		debugNotification.title = "🚧 ContainerStateWidgetView()"
//		debugNotification.threadIdentifier = "debug"
//		if let error = entry.error, !(error is URLError) {
//			debugNotification.subtitle = "error: \(error.localizedDescription)"
//		} else if let confContainer = entry.configuration.container {
//			debugNotification.subtitle = "confContainer ID: \(confContainer.identifier ?? "nil")"
//			debugNotification.body = "containerID: \(entry.container?.id ?? "nil")"
//		} else {
//			debugNotification.subtitle = "?"
//		}
//
//		let debugNotificationIdentifier = "Debug.ContainerStateWidgetView.init.\(entry.date.timeIntervalSince1970)"
//		let debugNotificationRequest = UNNotificationRequest(identifier: debugNotificationIdentifier, content: debugNotification, trigger: nil)
//		UNUserNotificationCenter.current().add(debugNotificationRequest) { _ in }
//		#endif
	}

	var body: some View {
		Group {
			if let error = entry.error, !(error is URLError) {
				ErrorView(error: error)
			} else if entry.configuration.container != nil {
				ContainerStateView(entry: entry)
			} else {
				SelectContainerPlaceholder()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color("WidgetBackground"), ignoresSafeAreaEdges: .all)
	}
}

// MARK: - Previews

struct ContainerStateWidgetView_Previews: PreviewProvider {
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
				.previewDisplayName("No configuration")

			ContainerStateWidgetView(entry: unreachableEntry)
				.previewDisplayName("Unreachable")

			ContainerStateWidgetView(entry: successfulEntry)
				.previewDisplayName("Successful")
		}
		.previewContext(WidgetPreviewContext(family: .systemSmall))
		.previewLayout(.sizeThatFits)
	}
}
