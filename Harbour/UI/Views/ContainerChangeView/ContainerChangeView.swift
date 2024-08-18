//
//  ContainerChangeView.swift
//  Harbour
//
//  Created by royal on 27/05/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - ContainerChangeView

struct ContainerChangeView: View {
	@State private var searchText = ""
	@State private var showChangesAfter = false
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
					ViewForChange(change: change, showAfter: showChangesAfter)
						.listSectionSpacing(.zero)
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
			.animation(.default, value: changesFiltered)
			.animation(.default, value: showChangesAfter)
			.toolbar {
				ToolbarItem(placement: .status) {
					Picker("ContainerChangeView.BeforeAfterPicker.Title", selection: $showChangesAfter) {
						Text("ContainerChangeView.BeforeAfterPicker.Before")
							.tag(false)

						Text("ContainerChangeView.BeforeAfterPicker.After")
							.tag(true)
					}
					.pickerStyle(.segmented)
					.labelsHidden()
				}
			}
		}
	}
}

// MARK: - ContainerChangeView+ViewForChange

private extension ContainerChangeView {
	struct ViewForChange: View {
		@Environment(SceneDelegate.self) private var sceneDelegate
		var change: ContainerChange
		var showAfter: Bool

		private var changeDetails: ContainerChange.ChangeDetails? {
			showAfter ? change.new : change.old
		}

		@ViewBuilder @MainActor
		private var showContainerButton: some View {
			if let containerID = change.new?.id {
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
						#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						#endif
				}
				#if os(macOS)
				.buttonStyle(.plain)
				#endif
			}
		}

		var body: some View {
			NormalizedSection {
				LabeledContent("ContainerChangeView.ID") {
					let hasValue = changeDetails?.id != nil
					Text(changeDetails?.id ?? "-")
						.foregroundStyle(hasValue ? .primary : .secondary)
						.fontDesign(hasValue ? .monospaced : .default)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				LabeledContent("ContainerChangeView.State") {
					let hasValue = changeDetails?.state != nil
					let state = (changeDetails?.state ?? Container.State?.none)
					Text(hasValue ? state.title : "-")
						.foregroundStyle(state.color)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				LabeledContent("ContainerChangeView.Status") {
					let hasValue = changeDetails?.status != nil
					Text(changeDetails?.status ?? "-")
						.foregroundStyle(hasValue ? .primary : .secondary)
						.textSelection(.enabled)
						.multilineTextAlignment(.trailing)
				}

				showContainerButton
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
