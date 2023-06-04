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

		let navigationItem: ContainerNavigationItem

		var body: some View {
			Section {
				NavigationLink(destination: ContainerLogsView(navigationItem: navigationItem)) {
					Label(Localization.Section.logs, systemImage: SFSymbol.logs)
						.font(.body)
				}
			}
		}
	}
}

// MARK: - Previews

struct ContainerDetailsView_LogsSection_Previews: PreviewProvider {
	static var previews: some View {
		ContainerDetailsView.LogsSection(navigationItem: .init(id: "", displayName: "Container", endpointID: nil))
	}
}
