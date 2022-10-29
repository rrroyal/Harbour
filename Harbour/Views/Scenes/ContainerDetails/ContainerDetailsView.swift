//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// TODO: Rebuild this view

// MARK: - ContainerDetailsView

struct ContainerDetailsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneState.ErrorHandler?

	let item: ContainersView.ContainerNavigationItem

	@State private var details: ContainerDetails?

	var body: some View {
		List {
			Section {
				Text(String(describing: item))
			}

			Section {
				Text(String(describing: details))
			}

			LogsSection(item: item)
		}
		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
		.animation(.easeInOut, value: details != nil)
		.navigationTitle(item.displayName ?? item.id)
		.userActivity(HarbourUserActivity.containerDetails, element: item, createUserActivity)
		.task(id: "\(item.endpointID ?? -1)-\(item.id)", getContainerDetails)
	}
}

// MARK: - ContainerDetailsView+Actions

private extension ContainerDetailsView {
	func createUserActivity(for item: ContainersView.ContainerNavigationItem, userActivity: NSUserActivity) {
		typealias Localization = Localizable.ContainerDetails.UserActivity

		userActivity.isEligibleForHandoff = true
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true

		if let serverURL = PortainerStore.shared.serverURL,
		   let endpointID = item.endpointID {
			let portainerURLScheme = PortainerURLScheme(address: serverURL)
			let portainerURL = portainerURLScheme.containerURL(containerID: item.id, endpointID: endpointID)
			userActivity.webpageURL = portainerURL
		}

		let displayName = item.displayName ?? Localization.unnamedContainerPlaceholder
		userActivity.title = Localization.title(displayName)

		try? userActivity.setTypedPayload(item)
	}

	@Sendable
	func getContainerDetails() async {
		do {
			details = nil

			if !portainerStore.isSetup {
				try await portainerStore.setupTask?.value
			}
//			if portainerStore.selectedEndpointID == nil {
//				_ = try? await portainerStore.endpointsTask?.value
//			}

			details = try await portainerStore.inspectContainer(item.id, endpointID: item.endpointID)
		} catch {
			sceneErrorHandler?(error, String.debugInfo())
		}
	}
}

// MARK: - ContainerDetailsView+Components

private extension ContainerDetailsView {
	struct LogsSection: View {
		let item: ContainersView.ContainerNavigationItem

		var body: some View {
			Section {
				NavigationLink(destination: ContainerLogsView(item: item)) {
					Label("Logs", systemImage: "text.alignleft")
				}
			}
		}
	}
}

// MARK: - Previews

struct ContainerDetailsView_Previews: PreviewProvider {
	static let item = ContainersView.ContainerNavigationItem(id: "id", displayName: "DisplayName", endpointID: nil)
	static var previews: some View {
		ContainerDetailsView(item: item)
	}
}
