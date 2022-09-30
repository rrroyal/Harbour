//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI

struct ContainerDetailsView: View {
	let item: ContainersView.ContainerNavigationItem

	var body: some View {
		Text(item.id)
			.navigationTitle(item.displayName ?? item.id)
			.userActivity(HarbourUserActivity.containerDetails, element: item) { item, userActivity in
				createUserActivity(item, userActivity)
			}
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
}

struct ContainerDetailsView_Previews: PreviewProvider {
	static let item = ContainersView.ContainerNavigationItem(id: "id", displayName: "DisplayName", endpointID: nil)
	static var previews: some View {
		ContainerDetailsView(item: item)
	}
}
