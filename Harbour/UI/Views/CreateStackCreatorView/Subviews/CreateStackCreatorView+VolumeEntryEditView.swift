//
//  CreateStackCreatorView+VolumeEntryEditView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView {
	struct VolumeEntryEditView: View {
		@Environment(\.dismiss) private var dismiss

		var entry: ViewModel.Service.VolumeEntry?
		var onSave: (ViewModel.Service.VolumeEntry) -> Void
		var removeAction: () -> Void

		@State private var source: String
		@State private var target: String
		@FocusState private var focusedField: Field?

		init(
			entry: ViewModel.Service.VolumeEntry?,
			onSave: @escaping (ViewModel.Service.VolumeEntry) -> Void,
			removeAction: @escaping () -> Void
		) {
			self.entry = entry
			self.onSave = onSave
			self.removeAction = removeAction
			self._source = State(initialValue: entry?.source ?? "")
			self._target = State(initialValue: entry?.target ?? "")
		}

		var body: some View {
			Form {
				NormalizedSection {
					TextField(
						String("/data"),
						value: $source.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .source)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.submitLabel(.next)
					.onSubmit {
						focusedField = .target
					}
				} header: {
					Text("CreateStackView.ServiceEditor.Volume.Source")
				} footer: {
					Text("CreateStackView.ServiceEditor.Volume.Source.Footer")
				}

				NormalizedSection {
					TextField(
						String("/usr/share/nginx/html"),
						value: $target.replacing(" ", with: "-"),
						formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
					)
					.focused($focusedField, equals: .target)
					.autocorrectionDisabled()
					.textInputAutocapitalization(.never)
					.fontDesign(.monospaced)
					.labelsHidden()
					.submitLabel(.done)
					.onSubmit {
						focusedField = nil
						if canSave { saveEntry() }
					}
				} header: {
					Text("CreateStackView.ServiceEditor.Volume.Target")
				} footer: {
					Text("CreateStackView.ServiceEditor.Volume.Target.Footer")
				}
			}
			.formStyle(.grouped)
			.scrollDismissesKeyboard(.interactively)
			.onAppear {
				if source.isEmpty {
					focusedField = .source
				}
			}
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button {
						saveEntry()
					} label: {
						Label(
							entry != nil ? "Generic.Save" : "Generic.Add",
							systemImage: entry != nil ? SFSymbol.apply : SFSymbol.plus
						)
					}
					.buttonStyle(.borderedProminent)
					.keyboardShortcut(.defaultAction)
					.disabled(!canSave)
				}

				if entry != nil {
					ToolbarItem(placement: .destructiveAction) {
						Button(role: .destructive) {
							removeAction()
							dismiss()
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.buttonStyle(.borderedProminent)
						.tint(.red)
						.keyboardShortcut(.delete)
					}
				}
			}
		}
	}
}

// MARK: - Helpers

private extension CreateStackCreatorView.VolumeEntryEditView {
	var canSave: Bool {
		!source.isReallyEmpty && !target.isReallyEmpty
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.VolumeEntryEditView {
	func saveEntry() {
		guard canSave else { return}

		let source = source
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: " ", with: "-")
		let target = target
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: " ", with: "-")

		let entry = CreateStackCreatorView.ViewModel.Service.VolumeEntry(
			source: source,
			target: target
		)
		onSave(entry)

		dismiss()
	}
}

// MARK: - Subtypes

private extension CreateStackCreatorView.VolumeEntryEditView {
	enum Field {
		case source
		case target
	}
}
