//
//  CreateStackManualView+StackEnvironmentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - CreateStackManualView+StackEnvironmentView

extension CreateStackManualView {
	struct StackEnvironmentView: View {
		@Environment(CreateStackManualView.ViewModel.self) private var viewModel

		var environmentSorted: [KeyValueEntry] {
			viewModel.stackEnvironment.sorted()
		}

		var body: some View {
			NormalizedSection {
				Group {
					ForEach(environmentSorted) { entry in
						Button {
//							Haptics.generateIfEnabled(.sheetPresentation)
							viewModel.editedEnvironmentEntry = entry
							viewModel.isEnvironmentEntrySheetPresented = true
						} label: {
							LabeledContent {
								Text(entry.value)
									.multilineTextAlignment(.trailing)
							} label: {
								Text(entry.key)
							}
							#if os(macOS)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							#endif
						}
						.fontDesign(.monospaced)
						.contextMenu {
							RemoveButton {
								Haptics.generateIfEnabled(.light)
								viewModel.editEnvironmentEntry(old: entry, new: nil)
							}
							.labelStyle(.titleAndIcon)
						}
						.swipeActions(edge: .trailing) {
							RemoveButton {
								Haptics.generateIfEnabled(.light)
								viewModel.editEnvironmentEntry(old: entry, new: nil)
							}
						}
					}

					AddButton {
//						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.editedEnvironmentEntry = nil
						viewModel.isEnvironmentEntrySheetPresented = true
					}
				}
				#if os(macOS)
				.foregroundStyle(.accent)
				.buttonStyle(.plain)
				#endif
			} header: {
				Text("CreateStackView.Environment")
			}
			.animation(.default, value: environmentSorted)
		}
	}
}

// MARK: - CreateStackManualView.StackEnvironmentView+Buttons

private extension CreateStackManualView.StackEnvironmentView {
	struct AddButton: View {
		let action: () -> Void

		var body: some View {
			Button {
				action()
			} label: {
				Label("Generic.Add", systemImage: SFSymbol.plus)
					#if os(macOS)
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
					#endif
			}
		}
	}

	struct RemoveButton: View {
		let action: () -> Void

		var body: some View {
			Button(role: .destructive) {
				action()
			} label: {
				Label("Generic.Remove", systemImage: SFSymbol.remove)
			}
			.tint(.red)
		}
	}
}

// MARK: - Previews

#Preview {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	CreateStackManualView.StackEnvironmentView()
		.environment(CreateStackManualView.ViewModel(portainerStore: portainerStore))
}
