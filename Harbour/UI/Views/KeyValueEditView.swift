//
//  KeyValueEditView.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonFoundation
import CommonHaptics
import SwiftUI

// MARK: - KeyValueEditView

struct KeyValueEditView: View {
	@Environment(\.dismiss) private var dismiss
	let entry: KeyValueEntry?
	let suggestions: Suggestions
	let fontDesign: Font.Design
	let saveAction: (KeyValueEntry) -> Void
	let removeAction: () -> Void

	@FocusState private var focusedField: FocusedField?
	@State private var key: String
	@State private var value: String

	init(
		entry: KeyValueEntry?,
		suggestions: Suggestions = .init(),
		fontDesign: Font.Design = .monospaced,
		saveAction: @escaping (KeyValueEntry) -> Void,
		removeAction: @escaping () -> Void
	) {
		self.entry = entry
		self.key = entry?.key ?? ""
		self.value = entry?.value ?? ""
		self.suggestions = suggestions
		self.fontDesign = fontDesign
		self.saveAction = saveAction
		self.removeAction = removeAction
	}

	var body: some View {
		Form {
			NormalizedSection {
				_TextField(label: "KeyValueEditView.Key", value: $key)
					.fontDesign(fontDesign)
					.focused($focusedField, equals: .key)
					.submitLabel(.next)
					.onSubmit {
						Haptics.generateIfEnabled(.selectionChanged)
						focusedField = .value
					}
			} header: {
				Text("KeyValueEditView.Key")
					.fontDesign(.default)
			} footer: {
				if !suggestions.key.isEmpty {
					SuggestionsRow(suggestions: suggestions.key) {
						selectSuggestion($0, for: $key)
					}
					.fontDesign(fontDesign)
				}
			}

			NormalizedSection {
				_TextField(label: "KeyValueEditView.Value", value: $value)
					.fontDesign(fontDesign)
					.focused($focusedField, equals: .value)
					.submitLabel(.done)
					.onSubmit {
						focusedField = nil
						if canSave {
							Haptics.generateIfEnabled(.light)
							submitEntry()
						}
					}
			} header: {
				Text("KeyValueEditView.Value")
					.fontDesign(.default)
			} footer: {
				if !suggestions.value.isEmpty {
					SuggestionsRow(suggestions: suggestions.value) {
						selectSuggestion($0, for: $value)
					}
					.fontDesign(fontDesign)
				}
			}
		}
		.formStyle(.grouped)
		.scrollDisabled(true)
		.scrollDismissesKeyboard(.interactively)
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				saveButton
			}

			ToolbarItem(placement: .destructiveAction) {
				if entry != nil {
					removeButton
				}
			}
		}
		.animation(.default, value: key)
		.animation(.default, value: value)
		.onAppear {
			if key.isEmpty && value.isEmpty {
				focusedField = .key
			}
		}
	}
}

// MARK: - Types

extension KeyValueEditView {
	struct Suggestions: Equatable, Hashable {
		var key: [String] = []
		var value: [String] = []
	}
}

// MARK: - Helpers

private extension KeyValueEditView {
	var canSave: Bool {
		!key.isReallyEmpty && !value.isReallyEmpty
	}
}

// MARK: - Actions

private extension KeyValueEditView {
	func submitEntry() {
		saveAction(.init(key: key, value: value))
		dismiss()
	}

	func removeEntry() {
		removeAction()
		dismiss()
	}

	func selectSuggestion(
		_ suggestion: String,
		for binding: Binding<String>
	) {
		Haptics.generateIfEnabled(.selectionChanged)
		withAnimation {
			binding.wrappedValue = suggestion
		}
	}
}

// MARK: - FocusedField

private extension KeyValueEditView {
	enum FocusedField {
		case key
		case value
	}
}

// MARK: - Subviews

private extension KeyValueEditView {
	@ViewBuilder @MainActor
	private var saveButton: some View {
		Button {
			Haptics.generateIfEnabled(.buttonPress)
			submitEntry()
		} label: {
			Label(
				entry != nil ? "Generic.Save" : "Generic.Add",
				systemImage: entry != nil ? SFSymbol.apply : SFSymbol.plus
			)
		}
		.keyboardShortcut(.defaultAction)
		.buttonStyle(.borderedProminent)
		.disabled(!canSave)
		.animation(.default, value: canSave)
	}

	@ViewBuilder @MainActor
	private var removeButton: some View {
		Button(role: .destructive) {
			Haptics.generateIfEnabled(.buttonPress)
			removeEntry()
		} label: {
			Label("Generic.Remove", systemImage: SFSymbol.remove)
		}
		.keyboardShortcut(.delete)
		.buttonStyle(.borderedProminent)
		.tint(.red)
	}

	struct _TextField: View {
		let label: LocalizedStringKey
		@Binding var value: String

		var body: some View {
			TextField("KeyValueEditView.Value", text: $value)
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
				.labelsHidden()
				.animation(.default, value: value)
		}
	}

	struct SuggestionsRow: View {
		let suggestions: [String]
		let onSuggestionSelect: (String) -> Void

		var body: some View {
			ScrollView(.horizontal) {
				LazyHStack {
					ForEach(suggestions, id: \.self) { suggestion in
						Button {
							onSuggestionSelect(suggestion)
						} label: {
							Text(suggestion)
								.foregroundStyle(.secondary)
						}
						.buttonStyle(.borderedProminent)
						.tint(Color.secondaryGroupedBackground)
					}
				}
				.scrollTargetLayout()
			}
			.scrollTargetBehavior(.viewAligned)
			.scrollBounceBehavior(.basedOnSize)
			.scrollClipDisabled()
			.scrollIndicators(.hidden)
			.listRowInsets(
				.init(
					top: 8,
					leading: 0,
					bottom: 8,
					trailing: 0
				)
			)
		}
	}
}

// MARK: - Previews

#Preview("Create") {
	NavigationStack {
		KeyValueEditView(
			entry: nil,
			saveAction: { _ in },
			removeAction: { }
		)
	}
}

#Preview("Create (with suggestions)") {
	NavigationStack {
		KeyValueEditView(
			entry: nil,
			suggestions: .init(
				key: ["key1", "key2"],
				value: ["value1", "value2", "value3", "value4", "value5", "value6", "value7"]
			),
			saveAction: { _ in },
			removeAction: { }
		)
	}
}

#Preview("Edit") {
	NavigationStack {
		KeyValueEditView(entry: .init(key: "Key", value: "Value"), saveAction: { _ in }, removeAction: { })
	}
}
