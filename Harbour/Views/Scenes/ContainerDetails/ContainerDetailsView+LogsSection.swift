//
//  ContainerDetailsView+LogsSection.swift
//  Harbour
//
//  Created by royal on 03/12/2022.
//

import SwiftUI

// MARK: - ContainerDetailsView+LogsSection

extension ContainerDetailsView {
	struct LogsSection: View {
		private typealias Localization = Localizable.ContainerDetails

		let item: ContainersView.ContainerNavigationItem

		var body: some View {
			Section {
				NavigationLink(destination: ContainerDetailsView.LogsView(item: item)) {
					Label(Localization.logs, systemImage: "text.alignleft")
				}
			}
		}
	}
}

// MARK: - Previews

struct ContainerDetailsView_LogsSection_Previews: PreviewProvider {
	static var previews: some View {
		ContainerDetailsView.LogsSection(item: .init(id: "id", displayName: "Container", endpointID: nil))
	}
}
