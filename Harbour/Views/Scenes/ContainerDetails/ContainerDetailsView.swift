//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI
import PortainerKit

// MARK: - ContainerDetailsView

/// View fetching and displaying details for associated container ID.
struct ContainerDetailsView: View {
	private typealias Localization = Localizable.ContainerDetails

	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(\.sceneErrorHandler) private var sceneErrorHandler: SceneState.ErrorHandler?

	let item: ContainersView.ContainerNavigationItem

	@State private var isLoading = false
	@State private var details: ContainerDetails?

	var body: some View {
		List {
			if let details {
				StatusSection(status: details.status)
			} else if isLoading {
				// TODO: loading view
				Text("loading")
			}

			LogsSection(item: item)
		}
		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
		.animation(.easeInOut, value: details != nil)
		.animation(.easeInOut, value: isLoading)
		.navigationTitle(item.displayName ?? item.id)
		.userActivity(HarbourUserActivityIdentifier.containerDetails, element: item, createUserActivity)
		.task(id: "\(item.endpointID ?? -1)-\(item.id)", getContainerDetails)
	}

//	var _body: some View {
//		ScrollView {
//			Grid(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 10) {
//				GridRow {
//					Text("something")
//						.frame(maxWidth: .infinity, maxHeight: .infinity)
//						.gridCellColumns(2)
//						.background(Color.mint)
//					Text("asd")
//						.frame(maxWidth: .infinity, maxHeight: .infinity)
//						.gridCellColumns(1)
//						.background(Color.green)
//					Text("dsadas")
//						.frame(maxWidth: .infinity, maxHeight: .infinity)
//						.gridCellColumns(1)
//						.background(Color.red)
//				}
//				GridRow {
//					Text("dsa")
//						.frame(maxWidth: .infinity, maxHeight: .infinity)
//						.gridCellColumns(3)
//						.background(Color.blue)
//				}
//			}
//		}
//		.background(Color(uiColor: .systemGroupedBackground), ignoresSafeAreaEdges: .all)
//		.animation(.easeInOut, value: details != nil)
//		.animation(.easeInOut, value: isLoading)
//		.navigationTitle(item.displayName ?? item.id)
//		.userActivity(HarbourUserActivityIdentifier.containerDetails, element: item, createUserActivity)
//		.task(id: "\(item.endpointID ?? -1)-\(item.id)", getContainerDetails)
//	}
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
		isLoading = true
		defer { isLoading = false }

		do {
			if item.id != details?.id {
				details = nil
			}

			if !portainerStore.isSetup {
				await portainerStore.setupTask?.value
			}

			details = try await portainerStore.inspectContainer(item.id, endpointID: item.endpointID)
		} catch {
			sceneErrorHandler?(error, ._debugInfo())
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
