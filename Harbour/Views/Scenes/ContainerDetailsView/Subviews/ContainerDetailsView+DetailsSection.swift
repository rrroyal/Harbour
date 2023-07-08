//
//  ContainerDetailsView+DetailsSection.swift
//  Harbour
//
//  Created by royal on 19/03/2023.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView+DetailsSection

extension ContainerDetailsView {
	struct DetailsSection: View {
		private typealias Localization = Localizable.ContainerDetailsView

		let container: Container?
		let details: ContainerDetails?

		var body: some View {
			// Status / State
			Section(Localization.Section.state) {
				let state = details?.status.state ?? container?.state ?? ContainerState?.none
				let title = container?.status ?? state.description.capitalized
				let icon = state.icon
				LabeledWithIcon(title, icon: icon)
					.foregroundColor(state.color)
			}

			// ID
			if let id = container?.id ?? details?.id {
				Section(Localization.Section.id) {
					Labeled(id)
						.fontDesign(.monospaced)
				}
			}

			// Created At
			if let createdAt = details?.created ?? container?.created {
				Section(Localization.Section.createdAt) {
					Labeled(createdAt.formatted(.dateTime))
				}
			}

			// Finished At
			if let finishedAt = details?.status.finishedAt {
				Section(Localization.Section.finishedAt) {
					Labeled(finishedAt.formatted(.dateTime))
				}
			}

			// Image
			if let image = container?.image {
				Section(Localization.Section.image) {
					Group {
						if let imageID = container?.imageID {
							Labeled("\(image)@\(imageID)")
						} else {
							Labeled(image)
						}
					}
					.fontDesign(.monospaced)
				}
			}

			// CMD
			if let command = details?.config?.cmd?.joined(separator: " ") {
				Section(Localization.Section.cmd) {
					Labeled(command)
						.fontDesign(.monospaced)
				}
			}

			// Entrypoint
			if let entrypoint = details?.config?.entrypoint?.joined(separator: " ") {
				Section(Localization.Section.entrypoint) {
					Labeled(entrypoint)
						.fontDesign(.monospaced)
				}
			}

			// Network
//			if let networkSettings = container?.networkSettings?.network {
//				let _ = print(networkSettings)
//			}
		}
	}
}

// MARK: - Previews

/*
 #Preview {
 ContainerDetailsView.DetailsSection(details: <#T##ContainerDetails#>)
 }
 */
