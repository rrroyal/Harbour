//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

struct ContainerDetailsView: View {
	@Environment(\.sceneErrorHandler) var sceneErrorHandler
	@EnvironmentObject var portainerStore: PortainerStore

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
		.userActivity(HarbourUserActivity.containerDetails, element: item) { item, userActivity in
			createUserActivity(item, userActivity)
		}
		.task(getContainerDetails)
	}
}

private extension ContainerDetailsView {
	@MainActor
	func createUserActivity(_ item: ContainersView.ContainerNavigationItem, _ userActivity: NSUserActivity) {
		userActivity.isEligibleForHandoff = true
		userActivity.isEligibleForPrediction = true
		userActivity.isEligibleForSearch = true

		if let serverURL = PortainerStore.shared.serverURL,
		   let endpointID = item.endpointID {
			let portainerURLScheme = PortainerURLScheme(address: serverURL)
			let portainerURL = portainerURLScheme.containerURL(containerID: item.id, endpointID: endpointID)
			userActivity.webpageURL = portainerURL
		}

		let displayName = item.displayName ?? Localizable.ContainerDetails.UserActivity.unnamedContainerPlaceholder
		userActivity.title = Localizable.ContainerDetails.UserActivity.title(displayName)

		try? userActivity.setTypedPayload(item)
	}

	@Sendable
	func getContainerDetails() async {
		do {
			if !portainerStore.isSetup {
				await portainerStore.setupTask?.value
			}
			if portainerStore.selectedEndpointID == nil {
				try? await portainerStore.endpointsTask?.value
			}

			details = try await portainerStore.inspectContainer(item.id)
		} catch {
			sceneErrorHandler?(error, String.debugInfo())
		}
	}
}

struct ContainerDetailsView_Previews: PreviewProvider {
	static let item = ContainersView.ContainerNavigationItem(id: "id", displayName: "DisplayName", endpointID: nil)
	static var previews: some View {
		ContainerDetailsView(item: item)
	}
}
