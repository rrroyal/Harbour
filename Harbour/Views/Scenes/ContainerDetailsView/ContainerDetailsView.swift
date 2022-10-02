//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainerDetailsView

struct ContainerDetailsView: View {
	@EnvironmentObject var portainerStore: PortainerStore
	@Environment(\.sceneErrorHandler) var sceneErrorHandler

	let item: ContainersView.ContainerNavigationItem

	@State private var details: ContainerDetails?

	var body: some View {
		VStack {
			Text(item.id)
			if let details {
				Text(String(describing: details))
			}
		}
		.navigationTitle(item.displayName ?? item.id)
		.userActivity(HarbourUserActivity.containerDetails, element: item, createUserActivity)
		.task(getContainerDetails)
	}
}

// MARK: - ContainerDetailsView+Actions

private extension ContainerDetailsView {
	func createUserActivity(for item: ContainersView.ContainerNavigationItem, userActivity: NSUserActivity) {
		typealias Localization = Localizable.ContainerDetails.UserActivity

		Task {
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
	}

	@Sendable
	func getContainerDetails() async {
		do {
			if !portainerStore.isSetup {
				await portainerStore.setupTask?.value
			}
//			if portainerStore.selectedEndpointID == nil {
//				_ = try? await portainerStore.endpointsTask?.value
//			}

			details = try await portainerStore.inspectContainer(item.id)
		} catch {
			sceneErrorHandler?(error, String.debugInfo())
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
