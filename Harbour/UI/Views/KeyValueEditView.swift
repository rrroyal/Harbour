//
//  KeyValueEditView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

// MARK: - KeyValueEditView

struct KeyValueEditView: View {
	@Environment(\.dismiss) private var dismiss
	var entry: KeyValueEntry?
	var saveAction: (KeyValueEntry) -> Void
	var removeAction: () -> Void

	@FocusState private var focusedField: FocusedField?
	@State private var key: String
	@State private var value: String

	init(
		entry: KeyValueEntry?,
		saveAction: @escaping (KeyValueEntry) -> Void,
		removeAction: @escaping () -> Void
	) {
		self.entry = entry
		self.key = entry?.key ?? ""
		self.value = entry?.value ?? ""
		self.saveAction = saveAction
		self.removeAction = removeAction
	}

	private var canSave: Bool {
		!key.isReallyEmpty && !value.isReallyEmpty
	}

	@ViewBuilder @MainActor
	private var saveButton: some View {
		Button {
			Haptics.generateIfEnabled(.light)
			submitEntry()
		} label: {
			Label(
				entry != nil ? "Generic.Save" : "Generic.Add",
				systemImage: entry != nil ? SFSymbol.save : SFSymbol.plus
			)
		}
		.keyboardShortcut(.defaultAction)
		.disabled(!canSave)
		.transition(.opacity)
		.animation(.easeInOut, value: canSave)
	}

	@ViewBuilder @MainActor
	private var removeButton: some View {
		Button(role: .destructive) {
			Haptics.generateIfEnabled(.light)
			removeEntry()
		} label: {
			Label("Generic.Remove", systemImage: SFSymbol.remove)
		}
		.keyboardShortcut(.delete)
		.transition(.opacity)
	}

	var body: some View {
		Form {
			NormalizedSection {
				TextField("KeyValueEditView.Key", text: $key)
					.focused($focusedField, equals: .textfieldKey)
					.submitLabel(.next)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.labelsHidden()
					.onSubmit {
						Haptics.generateIfEnabled(.selectionChanged)
						focusedField = .textfieldValue
					}
			} header: {
				Text("KeyValueEditView.Key")
			}

			NormalizedSection {
				TextField("KeyValueEditView.Value", text: $value)
					.focused($focusedField, equals: .textfieldValue)
					.submitLabel(.done)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.labelsHidden()
					.onSubmit {
						focusedField = nil
						if canSave {
							Haptics.generateIfEnabled(.light)
							submitEntry()
						}
					}
			} header: {
				Text("KeyValueEditView.Value")
			}
		}
		.formStyle(.grouped)
		.scrollDisabled(true)
		.scrollDismissesKeyboard(.interactively)
//		.onAppear {
//			focusedField = .textfieldKey
//		}
		#if os(iOS)
		.safeAreaInset(edge: .bottom) {
			HStack {
				if entry != nil {
					removeButton
						.buttonStyle(.customPrimary(backgroundColor: .red))
				}

				saveButton
					.buttonStyle(.customPrimary)
			}
			.padding()
		}
		#endif
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .primaryAction) {
				saveButton
			}

			ToolbarItem(placement: .destructiveAction) {
				if entry != nil {
					removeButton
				}
			}
			#endif
		}
	}
}

// MARK: - KeyValueEditView+Actions

private extension KeyValueEditView {
	func submitEntry() {
		saveAction(.init(key, value))
		dismiss()
	}

	func removeEntry() {
		removeAction()
		dismiss()
	}
}

// MARK: - KeyValueEditView+FocusedField

private extension KeyValueEditView {
	enum FocusedField {
		case textfieldKey
		case textfieldValue
	}
}

// MARK: - Previews

#Preview("Create") {
	NavigationStack {
		KeyValueEditView(entry: nil, saveAction: { _ in }, removeAction: { })
	}
}

#Preview("Edit") {
	NavigationStack {
		KeyValueEditView(entry: .init("Key", "Value"), saveAction: { _ in }, removeAction: { })
	}
}
