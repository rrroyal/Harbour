//
//  ContainerDetailsView+DetailsSection.swift
//  Harbour
//
//  Created by royal on 19/03/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerDetailsView+DetailsSection

extension ContainerDetailsView {
	struct DetailsSection: View {
		let container: Container?
		let details: ContainerDetails?

		var body: some View {
			// Status / State
			Section {
				let state = details?.status.state ?? ((!(container?._isStored ?? true) ? container?.state : nil) ?? ContainerState?.none)
				let title = container?.status ?? state.description.capitalized
				let icon = state.icon
				LabeledWithIcon(title, icon: icon)
					.font(ContainerDetailsView.sectionContentFont)
					.foregroundColor(state.color)
			} header: {
				Text("ContainerDetailsView.Section.State")
					.font(ContainerDetailsView.sectionHeaderFont)
			}
			.animation(.easeInOut, value: container?.state)
			.animation(.easeInOut, value: details?.status)

			// ID
			if let id = container?.id ?? details?.id {
				Section {
					Labeled(id)
						.font(ContainerDetailsView.sectionContentFont)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.ID")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: id)
			}

			// Created At
			if let createdAt = details?.created ?? container?.created {
				Section {
					Labeled(createdAt.formatted(.dateTime))
						.font(ContainerDetailsView.sectionContentFont)
				} header: {
					Text("ContainerDetailsView.Section.CreatedAt")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: createdAt)
			}

			// Finished At
			if let finishedAt = details?.status.finishedAt {
				Section {
					Labeled(finishedAt.formatted(.dateTime))
						.font(ContainerDetailsView.sectionContentFont)
				} header: {
					Text("ContainerDetailsView.Section.FinishedAt")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: finishedAt)
			}

			// Image
			if let image = container?.image {
				Section {
					Group {
						if let imageID = container?.imageID {
							Labeled("\(image)@\(imageID)")
						} else {
							Labeled(image)
						}
					}
					.font(ContainerDetailsView.sectionContentFont)
					.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Image")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: image)
			}

			// CMD
			if let command = details?.config?.cmd?.joined(separator: " ") {
				Section {
					Labeled(command)
						.font(ContainerDetailsView.sectionContentFont)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Cmd")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: command)
			}

			// Entrypoint
			if let entrypoint = details?.config?.entrypoint?.joined(separator: " ") {
				Section {
					Labeled(entrypoint)
						.font(ContainerDetailsView.sectionContentFont)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Entrypoint")
						.font(ContainerDetailsView.sectionHeaderFont)
				}
				.animation(.easeInOut, value: entrypoint)
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
