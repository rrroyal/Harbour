//
//  ContainerDetailsView+DetailsSection.swift
//  Harbour
//
//  Created by royal on 19/03/2023.
//

import SwiftUI
import PortainerKit

// MARK: - ContainerDetailsView+DetailsSection

extension ContainerDetailsView {
	struct DetailsSection: View {
		private typealias Localization = Localizable.ContainerDetails

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
							Labeled("\(image)@\(imageID)", monospaced: true, smaller: true)
						} else {
							Labeled(image, monospaced: true, smaller: true)
						}
					}
				}
			}

			// CMD
			if let command = details?.config?.cmd?.joined(separator: " ") {
				Section(Localization.Section.cmd) {
					Labeled(command, monospaced: true, smaller: true)
				}
			}

			// Entrypoint
			if let entrypoint = details?.config?.entrypoint?.joined(separator: " ") {
				Section(Localization.Section.entrypoint) {
					Labeled(entrypoint, monospaced: true, smaller: true)
				}
			}

			// Env
			if let env = details?.config?.env.sorted(by: { $0.caseInsensitiveCompare($1) == .orderedAscending }) {
				Section {
					DisclosureGroup(content: {
						ForEach(env, id: \.self) { envKey in
							Labeled(envKey, monospaced: true, smaller: true)
						}
					}, label: {
						Label(Localization.Section.environment, systemImage: "list.bullet.rectangle")
					})
				}
			}

			// Labels
			if let labels = details?.config?.labels.sorted(by: { $0.key.caseInsensitiveCompare($1.key) == .orderedAscending }) {
				Section {
					DisclosureGroup(content: {
						ForEach(labels.map({ ($0, $1) }), id: \.0) { key, value in
							Labeled("\(key)=\(value)", monospaced: true, smaller: true)
								.fontDesign(.monospaced)
						}
					}, label: {
						Label(Localization.Section.labels, systemImage: "tag")
					})
				}
			}

			// Mounts
			if let mounts = details?.mounts.sorted(by: { $0.source.caseInsensitiveCompare($1.source) == .orderedAscending }) {
				Section {
					DisclosureGroup(content: {
						ForEach(mounts, id: \.destination) { mount in
							Labeled("\(mount.source):\(mount.destination)", monospaced: true, smaller: true)
						}
					}, label: {
						Label(Localization.Section.mounts, systemImage: "externaldrive")
					})
				}
			}

			// Network
//			if let network = container?.networkSettings.network {
//				Section {
//					DisclosureGroup(content: {
//						ForEach(labels.map({ ($0, $1) }), id: \.0) { key, value in
//							Labeled("\(key)=\(value)")
//								.font(.callout)
//								.fontDesign(.monospaced)
//						}
//					}, label: {
//						Label("Labels", systemImage: "tag")
//					})
//				}
//			}
		}
	}
}

// MARK: - Previews

/*
struct ContainerDetailsView_DetailsSection_Previews: PreviewProvider {
	static var previews: some View {
		ContainerDetailsView.DetailsSection(details: <#T##ContainerDetails#>)
	}
}
*/
