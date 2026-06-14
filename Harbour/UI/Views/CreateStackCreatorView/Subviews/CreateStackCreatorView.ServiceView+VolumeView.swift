//
//  CreateStackCreatorView.ServiceView+VolumeView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

extension CreateStackCreatorView.ServiceView {
	struct VolumeView: View {
		@Environment(\.dismiss) private var dismiss

		var entry: CreateStackCreatorView.ViewModel.Service.Volume?
		var onSave: (CreateStackCreatorView.ViewModel.Service.Volume) -> Void
		var removeAction: () -> Void

		@State private var source: String
		@State private var target: String
		@FocusState private var focusedField: Field?

		init(
			entry: CreateStackCreatorView.ViewModel.Service.Volume?,
			onSave: @escaping (CreateStackCreatorView.ViewModel.Service.Volume) -> Void,
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
					Text("CreateStackCreatorView.ServiceView.VolumeView.Source.Header")
				} footer: {
					Text("CreateStackCreatorView.ServiceView.VolumeView.Source.Footer")
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
						if canSave {
							saveEntry()
						}
					}
				} header: {
					Text("CreateStackCreatorView.ServiceView.VolumeView.Target.Header")
				} footer: {
					Text("CreateStackCreatorView.ServiceView.VolumeView.Target.Footer")
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

private extension CreateStackCreatorView.ServiceView.VolumeView {
	var canSave: Bool {
		!source.isReallyEmpty && !target.isReallyEmpty
	}
}

// MARK: - Actions

private extension CreateStackCreatorView.ServiceView.VolumeView {
	func saveEntry() {
		guard canSave else { return}

		let source = source
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: " ", with: "-")
		let target = target
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: " ", with: "-")

		let entry = CreateStackCreatorView.ViewModel.Service.Volume(
			source: source,
			target: target
		)
		onSave(entry)

		dismiss()
	}
}

// MARK: - Subtypes

private extension CreateStackCreatorView.ServiceView.VolumeView {
	enum Field {
		case source
		case target
	}
}
