//
//  CreateStackView+StackEnvironmentView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - CreateStackView+StackEnvironmentView

extension CreateStackView {
	struct StackEnvironmentView: View {
		@Environment(CreateStackView.ViewModel.self) private var viewModel

		var environmentSorted: [KeyValueEntry] {
			viewModel.stackEnvironment.sorted()
		}

		var body: some View {
			NormalizedSection {
				Group {
					ForEach(environmentSorted) { entry in
						Button {
							Haptics.generateIfEnabled(.sheetPresentation)
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
						Haptics.generateIfEnabled(.sheetPresentation)
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

// MARK: - CreateStackView.StackEnvironmentView+RemoveButton

private extension CreateStackView.StackEnvironmentView {
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
	CreateStackView.StackEnvironmentView()
		.environment(CreateStackView.ViewModel())
}
