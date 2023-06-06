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
		private typealias Localization = Localizable.ContainerDetailsView

		let navigationItem: ContainerNavigationItem

		var body: some View {
			Section {
				NavigationLink {
					ContainerLogsView(navigationItem: navigationItem)
				} label: {
					Label(Localization.Section.logs, systemImage: SFSymbol.logs)
						.font(.body)
				}
			}
		}
	}
}

// MARK: - Previews

#Preview {
	ContainerDetailsView.LogsSection(navigationItem: .init(id: "", displayName: "Container", endpointID: nil))
}
