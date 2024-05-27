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
							LabeledContent(entry.key, value: entry.value)
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

					Button {
						Haptics.generateIfEnabled(.sheetPresentation)
						viewModel.editedEnvironmentEntry = nil
						viewModel.isEnvironmentEntrySheetPresented = true
					} label: {
						Label("Generic.Add", systemImage: SFSymbol.plus)
							#if os(macOS)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							#endif
					}
				}
				#if os(macOS)
				.foregroundStyle(.accent)
				.buttonStyle(.plain)
				#endif
			} header: {
				Text("CreateStackView.Environment")
			}
			.animation(.smooth, value: environmentSorted)
		}
	}
}

// MARK: - CreateStackView.StackEnvironmentView+RemoveButton

private extension CreateStackView.StackEnvironmentView {
	struct RemoveButton: View {
		var removeAction: () -> Void

		var body: some View {
			Button(role: .destructive) {
				removeAction()
			} label: {
				Label("Generic.Remove", systemImage: SFSymbol.remove)
			}
			.foregroundStyle(.red)
		}
	}
}

// MARK: - Previews

#Preview {
	CreateStackView.StackEnvironmentView()
		.environment(CreateStackView.ViewModel())
}
