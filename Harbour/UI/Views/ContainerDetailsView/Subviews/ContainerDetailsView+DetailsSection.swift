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
			NormalizedSection {
				let state = details?.status.state ?? ((!(container?._isStored ?? true) ? container?.state : nil) ?? Container.State?.none)
				let title = container?.status ?? state.description.capitalized
				let icon = state.icon
				LabeledWithIcon(title, icon: icon)
					.foregroundColor(state.color)
			} header: {
				Text("ContainerDetailsView.Section.State")
			}
			.animation(.easeInOut, value: container?.state)
			.animation(.easeInOut, value: details?.status)

			// ID
			if let id = container?.id ?? details?.id {
				NormalizedSection {
					Labeled(id)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.ID")
				}
				.animation(.easeInOut, value: id)
			}

			// Created At
			if let createdAt = details?.created ?? container?.created {
				NormalizedSection {
					Labeled(createdAt.formatted(.dateTime))
				} header: {
					Text("ContainerDetailsView.Section.CreatedAt")
				}
				.animation(.easeInOut, value: createdAt)
			}

			// Finished At
			if let finishedAt = details?.status.finishedAt, !(details?.status.running ?? false) {
				NormalizedSection {
					Labeled(finishedAt.formatted(.dateTime))
				} header: {
					Text("ContainerDetailsView.Section.FinishedAt")
				}
				.animation(.easeInOut, value: finishedAt)
			}

			// Image
			if let image = container?.image {
				NormalizedSection {
					Group {
						if let imageID = container?.imageID {
							Labeled("\(image)@\(imageID)")
						} else {
							Labeled(image)
						}
					}
					.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Image")
				}
				.animation(.easeInOut, value: image)
			}

			// CMD
			if let command = details?.config?.cmd?.joined(separator: " ") {
				NormalizedSection {
					Labeled(command)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Cmd")
				}
				.animation(.easeInOut, value: command)
			}

			// Entrypoint
			if let entrypoint = details?.config?.entrypoint?.joined(separator: " ") {
				NormalizedSection {
					Labeled(entrypoint)
						.fontDesign(.monospaced)
				} header: {
					Text("ContainerDetailsView.Section.Entrypoint")
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
