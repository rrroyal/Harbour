//
//  ContainerChangeView.swift
//  Harbour
//
//  Created by royal on 27/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ContainerChangeView

struct ContainerChangeView: View {
	@State private var searchText = ""
	var changes: [ContainerChange]

	private var changesFiltered: [ContainerChange] {
		guard !searchText.isReallyEmpty else {
			return changes.localizedSorted(by: \.containerName)
		}

		return changes
			.filter {
				$0.containerName.localizedCaseInsensitiveContains(searchText)
			}
			.localizedSorted(by: \.containerName)
	}

	@ViewBuilder
	private var placeholderView: some View {
		if changesFiltered.isEmpty {
			if !searchText.isReallyEmpty {
				ContentUnavailableView.search(text: searchText)
			} else {
				ContentUnavailableView("Generic.Empty", systemImage: "ellipsis")
			}
		}
	}

	var body: some View {
		NavigationStack {
			Form {
				ForEach(changesFiltered, id: \.hashValue) { change in
					ViewForChange(change: change)
				}
			}
			.formStyle(.grouped)
			.scrollContentBackground(.hidden)
			.searchable(text: $searchText)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background {
				placeholderView
			}
			#if os(iOS)
			.background(Color.groupedBackground, ignoresSafeAreaEdges: .all)
			#endif
			.navigationTitle("ContainerChangeView.Title")
			.animation(.smooth, value: changesFiltered)
		}
	}
}

// MARK: - ContainerChangeView+ViewForChange

private extension ContainerChangeView {
	struct ViewForChange: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		var change: ContainerChange

		@ViewBuilder @MainActor
		private var showContainerButton: some View {
			if let containerID = change.newID {
				Button {
					let navigationItem = ContainerDetailsView.NavigationItem(
						id: containerID,
						displayName: change.containerName,
						endpointID: change.endpointID
					)
					sceneDelegate.resetSheets()
					sceneDelegate.navigate(to: .containers, with: navigationItem)
				} label: {
					Label("ContainerChangeView.ShowContainer", image: SFSymbol.Custom.container)
				}
			}
		}

		@ViewBuilder @MainActor
		private var viewForCreated: some View {
			if let id = change.newID ?? change.oldID {
				LabeledContent("ContainerChangeView.ID") {
					Text(id)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}
			}

			LabeledContent("ContainerChangeView.State") {
				Text(change.newState.description.localizedCapitalized)
					.foregroundStyle(change.newState.color)
					.textSelection(.enabled)
					.multilineTextAlignment(.trailing)
			}

			if let status = change.newStatus {
				LabeledContent("ContainerChangeView.Status") {
					Text(status)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}
			}

			showContainerButton
		}

		@ViewBuilder @MainActor
		private var viewForRecreated: some View {
			DisclosureGroup("ContainerChangeView.Previously") {
				if let oldID = change.oldID {
					LabeledContent("ContainerChangeView.ID") {
						Text(oldID)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}

				LabeledContent("ContainerChangeView.State") {
					Text(change.oldState.description.localizedCapitalized)
						.foregroundStyle(change.oldState.color)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				if let status = change.oldStatus {
					LabeledContent("ContainerChangeView.Status") {
						Text(status)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}
			}

			DisclosureGroup("ContainerChangeView.Currently") {
				if let newID = change.newID {
					LabeledContent("ContainerChangeView.ID") {
						Text(newID)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}

				LabeledContent("ContainerChangeView.State") {
					Text(change.newState.description.localizedCapitalized)
						.foregroundStyle(change.newState.color)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				if let status = change.newStatus {
					LabeledContent("ContainerChangeView.Status") {
						Text(status)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}
			}

			showContainerButton
		}

		@ViewBuilder @MainActor
		private var viewForChanged: some View {
			if let id = change.newID ?? change.oldID {
				LabeledContent("ContainerChangeView.ID") {
					Text(id)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}
			}

			DisclosureGroup("ContainerChangeView.Previously") {
				LabeledContent("ContainerChangeView.State") {
					Text(change.oldState.description.localizedCapitalized)
						.foregroundStyle(change.oldState.color)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				if let status = change.oldStatus {
					LabeledContent("ContainerChangeView.Status") {
						Text(status)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}
			}

			DisclosureGroup("ContainerChangeView.Currently") {
				LabeledContent("ContainerChangeView.State") {
					Text(change.newState.description.localizedCapitalized)
						.foregroundStyle(change.newState.color)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				if let status = change.newStatus {
					LabeledContent("ContainerChangeView.Status") {
						Text(status)
							.textSelection(.enabled)
							.multilineTextAlignment(.trailing)
					}
				}
			}

			showContainerButton
		}

		@ViewBuilder @MainActor
		private var viewForRemoved: some View {
			if let id = change.oldID ?? change.newID {
				LabeledContent("ContainerChangeView.ID") {
					Text(id)
						.fontDesign(.monospaced)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}
			}

			LabeledContent("ContainerChangeView.State") {
				Text(change.oldState.description.localizedCapitalized)
//					.foregroundStyle(.secondary)
					.textSelection(.enabled)
					.multilineTextAlignment(.trailing)
			}

			if let status = change.oldStatus {
				LabeledContent("ContainerChangeView.Status") {
					Text(status)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}
			}
		}

		var body: some View {
			NormalizedSection {
				switch change.changeType {
				case .created:
					viewForCreated
				case .recreated:
					viewForRecreated
				case .changed:
					viewForChanged
				case .removed:
					viewForRemoved
				}
			} header: {
				Text(change.containerName)
					.fontDesign(.monospaced)
					.textCase(.none)
			} footer: {
				Label(change.changeType.title, systemImage: change.changeType.icon)
					.textCase(.none)
			}
		}
	}
}

// MARK: - Previews

// swiftlint:disable force_unwrapping
#Preview("Changes") {
	ContainerChangeView(
		changes: [
			.init(
				oldContainer: nil,
				newContainer: .preview(id: "1", name: "Container1", state: .running),
				endpointID: 0,
				changeType: .created
			)!,
			.init(
				oldContainer: .preview(id: "2a", name: "Container2", state: .running),
				newContainer: .preview(id: "2b", name: "Container2", state: .running),
				endpointID: 0,
				changeType: .recreated
			)!,
			.init(
				oldContainer: .preview(id: "3", name: "Container3", state: .exited),
				newContainer: .preview(id: "3", name: "Container3", state: .running),
				endpointID: 0,
				changeType: .changed
			)!,
			.init(
				oldContainer: .preview(id: "4", name: "Container4", state: .running),
				newContainer: nil,
				endpointID: 0,
				changeType: .removed
			)!
		]
	)
	.environment(SceneDelegate())
}

#Preview("Changes - Empty") {
	ContainerChangeView(changes: [])
		.environment(SceneDelegate())
}
// swiftlint:enable force_unwrapping
