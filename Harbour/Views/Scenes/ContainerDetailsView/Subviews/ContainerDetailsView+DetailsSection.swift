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
			Section("ContainerDetailsView.Section.State") {
				let state = details?.status.state ?? ((!(container?._isStored ?? true) ? container?.state : nil) ?? ContainerState?.none)
				let title = container?.status ?? state.description.capitalized
				let icon = state.icon
				LabeledWithIcon(title, icon: icon)
					.foregroundColor(state.color)
			}

			// ID
			if let id = container?.id ?? details?.id {
				Section("ContainerDetailsView.Section.ID") {
					Labeled(id)
						.fontDesign(.monospaced)
				}
			}

			// Created At
			if let createdAt = details?.created ?? container?.created {
				Section("ContainerDetailsView.Section.CreatedAt") {
					Labeled(createdAt.formatted(.dateTime))
				}
			}

			// Finished At
			if let finishedAt = details?.status.finishedAt {
				Section("ContainerDetailsView.Section.FinishedAt") {
					Labeled(finishedAt.formatted(.dateTime))
				}
			}

			// Image
			if let image = container?.image {
				Section("ContainerDetailsView.Section.Image") {
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
				Section("ContainerDetailsView.Section.Cmd") {
					Labeled(command)
						.fontDesign(.monospaced)
				}
			}

			// Entrypoint
			if let entrypoint = details?.config?.entrypoint?.joined(separator: " ") {
				Section("ContainerDetailsView.Section.Entrypoint") {
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
